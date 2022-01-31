import ../melee

const
    OldHitboxCount* = 4
    NewHitboxCount* = 8
    AddedHitCount = NewHitboxCount - OldHitboxCount

type
    GameHeaderInfo* = object
        name*: string
        fighterDataSize*: int
        itemDataSize*: int
    HitFlag {.size: sizeof(uint32).} = enum
        hfSetWeight,
        hfAngleFlipOpposite,
        hfAngleFlipCurrent,
        hfStretch,
        hfFlinchless,
        hfNoMeteorCancel,
        hfNoStale
    HitFlags = set[HitFlag]

    FighterFlag {.size: sizeof(uint32).} = enum
        ffHitByFlinchless,
        ffSetWeight,
        ffDisableMeteorCancel,
        ffForceHitlagOnThrown
    FighterFlags = set[FighterFlag]

    SpecialHit = object
        hitlagMultiplier: float32
        sdiMultiplier: float32
        shieldStunMultiplier: float32
        hitstunModifier: float32
        hitFlags: HitFlags

    ExtData* = object
        specialHits*: array[NewHitboxCount, SpecialHit]
        hitlagMultiplier*: float32

    ExtItemData* = object
        sharedData*: ExtData
        newHits*: array[AddedHitCount * ItHitSize, byte]

    ExtFighterData* = object
        sharedData*: ExtData
        newHits*: array[AddedHitCount * FtHitSize, byte]
        sdiMultiplier*: float32
        shieldstunMultiplier*: float32
        hitstunModifier*: float32
        fighterFlags*: FighterFlags

template extFtDataOff*[T](gameInfo: GameHeaderInfo; t: typedesc[T] = ExtFighterData; member: untyped): int = gameInfo.fighterDataSize + offsetOf(t, member)
template extItDataOff*[T](gameInfo: GameHeaderInfo; t: typedesc[T] = ExtItemData; member: untyped): int = gameInfo.itemDataSize + offsetOf(t, member)

proc initGameHeaderInfo(name: string; fighterDataSize, itemDataSize: int): GameHeaderInfo =
    result.name = name
    result.fighterDataSize = fighterDataSize
    result.itemDataSize = itemDataSize

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

            # patch size
            gecko 0x800679BC, li r4, {allocSize}

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
        createCode "sushie's Ft/ItData Expansion":
            description: "Must be on for codes like Hitbox Extension & 8Box to work"
            authors: ["sushie"]
            code:
                %createFighterDataAllocationPatch(gameInfo, ExtFighterData)
                %createItemDataAllocationPatch(gameInfo, ExtItemData)

when isMainModule:    
    generate "./generated/dataexpansion.asm", createPatchFor(MexHeaderInfo)
