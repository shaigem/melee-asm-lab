import ../melee

const
    DataExpansionDir = "de/"
    OldHitboxCount* = 4
    NewHitboxCount* = 8
    AddedHitCount = NewHitboxCount - OldHitboxCount
    # version MAJOR.MINOR.PATCH increment based on the following:
    # major version = m-ex header changes or incompatible changes
    # minor version = new property changes
    # patch version = bug fixes
    Version* = "2.0.0"

    
type
    GameHeaderInfo* = object
        name*: string
        fighterDataSize*: int
        itemDataSize*: int

    DamageReactionMode* = enum
        drmNormal
        drmAlways
        drmReactionValue
        drmReactionValueSub
        drmDamagePower
        drmHpDamagePower

    HitFlag* {.size: sizeof(uint32).} = enum
        hfAffectOnlyThrow,
        hfNoStale,
        hfNoMeteorCancel,
        hfFlinchless,
        hfDisableHitlag,
        hfAngleFlipCurrent,
        hfAngleFlipOpposite,
        hfSetWeight
    HitFlags = set[HitFlag]

    HitAdvFlag* {.size: sizeof(uint32).} = enum
        hafUnk1,
        hafUnk2,
        hafUnk3,
        hafUnk4,
        hafUnk5,
        hafUnk6,
        hafUnk7,
        hafNoHitstunCancel
    HitAdvFlags = set[HitAdvFlag]

    HitStdFlag* {.size: sizeof(uint32).} = enum
        hsfUnk1,
        hsfUnk2,
        hsfUnk3,
        hsfUnk4,
        hsfUnk5,
        hsfUnk6,
        hsfUnk7,
        hsfStretch
    HitStdFlags = set[HitStdFlag]

    HitVecTargetPosFlag* {.size: sizeof(uint8).} = enum
        hvtfIsSet
        hvtfUnk2
        hvtfLerpAtkMom
        hvtfLerpSpeedCap
        hvtfCalcVecPull
        hvtfCalcVecTargetPos
        hvtfOverrideSpeed
        hvtfAfterHitlag
    HitVecTargetPosFlags = set[HitVecTargetPosFlag]

    FighterFlag* {.size: sizeof(uint8).} = enum
        ffHitByFlinchless,
        ffSetWeight,
        ffDisableMeteorCancel,
        ffForceHitlagOnThrown,
        ffAttackVecTargetPos
        ffDisableHitlag
        ffNoHitstunCancel
    FighterFlags = set[FighterFlag]

    SpecialHitAdvanced* = object
        padding*: array[3, float32] # spots for a few more variables
        hitAdvFlags*: HitAdvFlags

    SpecialHitNormal* = object
        hitlagMultiplier*: float32
        sdiMultiplier*: float32
        shieldStunMultiplier*: float32
        hitstunModifier*: float32
        hitFlags*: HitFlags

    SpecialHitAttackCapsule* = object
        offsetX2*: float32
        offsetY2*: float32
        offsetZ2*: float32

    SpecialHitSetVecTargetPos* = object
        targetPosNode*: float32
        targetPosFrame*: float32
        targetPosOffsetX*: float32
        targetPosOffsetY*: float32
        targetPosOffsetZ*: float32
        targetPosFlags*: HitVecTargetPosFlags
        targetPosPadding: int8

    SpecialHit* = object
        hitNormal*: SpecialHitNormal
        hitCapsule*: SpecialHitAttackCapsule
        hitAdvanced*: SpecialHitAdvanced
        hitStdFlags*: HitStdFlags
        hitTargetPos*: SpecialHitSetVecTargetPos
        padding*: array[2, float32] # spots for a few more variables

    # variables should be added at the end of each ExtItem/FighterData struct
    # should not delete or insert between

    ExtItemData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]
        newHits*: array[AddedHitCount * ItHitSize, byte]
        hitlagMultiplier*: float32

    ExtFighterData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]
        specialThrowHit*: SpecialHit
        newHits*: array[AddedHitCount * FtHitSize, byte]
        sdiMultiplier*: float32
        hitstunModifier*: float32
        shieldstunMultiplier*: float32
        fighterFlags*: FighterFlags
        noReactionMode*: int8
        padding2*: int16
        # autolink related
        vecTargetPosFrame*: float32
        vecTargetPosX*: float32
        vecTargetPosY*: float32
        vecTargetAttackerSpeedX*: float32        
        vecTargetAttackerSpeedY*: float32
        vecTargetPosFlags*: HitVecTargetPosFlags
        padding3*: array[3, int8]

template extFtDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.fighterDataSize + offsetOf(ExtFighterData, member)
template extItDataOff*(gameInfo: GameHeaderInfo; member: untyped): int = gameInfo.itemDataSize + offsetOf(ExtItemData, member)
template extHitOff*(member: untyped): int = offsetOf(SpecialHit, member)
template extHitNormOff*(member: untyped): int = extHitOff(hitNormal) + offsetOf(SpecialHitNormal, member)
template extHitAtkCapOff*(member: untyped): int = extHitOff(hitCapsule) + offsetOf(SpecialHitAttackCapsule, member)
template extHitAdvOff*(member: untyped): int = extHitOff(hitAdvanced) + offsetOf(SpecialHitAdvanced, member)
template extHitTargetPosOff*(member: untyped): int = extHitOff(hitTargetPos) + offsetOf(SpecialHitSetVecTargetPos, member)

proc initGameHeaderInfo(name: string; fighterDataSize, itemDataSize: int): GameHeaderInfo =
    result.name = name
    result.fighterDataSize = fighterDataSize
    result.itemDataSize = itemDataSize

func flag*(f: enum): int = 1 shl f.ord

template flagOrd*(f: enum): string = $f.ord & ", " & $flag(f)

const
    VanillaHeaderInfo* = initGameHeaderInfo("Vanilla", fighterDataSize = 0x23EC, itemDataSize = 0xFCC)
    # as of commit #f779005 Nov-29-2021 @ 1:28 AM EST
    MexHeaderInfo* = initGameHeaderInfo("m-ex", fighterDataSize = 
        VanillaHeaderInfo.fighterDataSize + 52, 
            itemDataSize = VanillaHeaderInfo.itemDataSize + 4)

proc createFighterDataAllocationPatch(gameInfo: GameHeaderInfo, t: typedesc): string =
    let allocSize = gameInfo.fighterDataSize + sizeof(t)
    result = ppc:
            # patch init values
            gecko 0x80068EEC
            addi r30, r3, 0 # backup data pointer
            load r4, 0x80458fd0
            lwz r4, 0x20(r4)
            bla r12, {ZeroDataLength}
            # exit
            mr r3, r30
            lis r4, 0x8046

            # patch init values result screen
            # from: https://github.com/UnclePunch/Training-Mode/blob/master/ASM/m-ex/Custom%20Playerdata%20Variables/Initialize%20Extended%20Playerblock%20Values%20(Result%20Screen).asm
            gecko 0x800BE830
            #Backup Data Pointer After Creation
            addi r30, r3, 0
            #Get Player Data Length
            load r4,0x80458fd0
            lwz r4, 0x20(r4)
            #Zero Entire Data Block
            bla r12, 0x8000c160
            exit:
                mr r3,r30
                lis r4, 0x8046

            # patch size
            gecko 0x800679BC, li r4, {allocSize}
            gecko.end

proc createItemDataAllocationPatch(gameInfo: GameHeaderInfo, t: typedesc): string =
    let allocSize = gameInfo.itemDataSize + sizeof(t)
    result = ppc:
            # size patch
            gecko 0x80266FD8, li r4, {allocSize}
            # init extended item data patch
            gecko 0x80268754
            addi r29, r3, 0 # backup r3
            li r4, {allocSize}
            bla r12, {ZeroDataLength}
            # _return
            mr r3, r29 # restore r3
            "mr." r6, r3
            gecko.end

proc createPatchFor(gameInfo: GameHeaderInfo): GeckoCodeScript =
    result = 
        createCode "sushie's Ft/ItData Expansion v1.1.1":
            description: "Must be on for codes like Hitbox Extension & 8Box to work"
            authors: ["sushie"]
            code:
                %createFighterDataAllocationPatch(gameInfo, ExtFighterData)
                %createItemDataAllocationPatch(gameInfo, ExtItemData)


when isMainModule:
    generate "./generated/" & DataExpansionDir & "dataexpansion.asm", createPatchFor(MexHeaderInfo)
    # generate all mods that rely on the same extended data structures
    import ../hitbox/[autolink/autolink367, eight/eighthitbox, specialflagsfthit], customcmdscript
    import ../noreactioncmd
    generate "./generated/" & DataExpansionDir & "customcmdscript.asm", CustomCmdScript
    generate "./generated/" & DataExpansionDir & "autolink367.asm", AutoLink367
    generate "./generated/" & DataExpansionDir & "eighthitboxes.asm", EightHitboxes
    generate "./generated/" & DataExpansionDir & "specialflagsfthit.asm", SpecialFlagsFtHitScript
    generate "./generated/" & DataExpansionDir & "noreactioncmd.asm", DamageNoReactionScript