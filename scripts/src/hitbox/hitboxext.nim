import geckon
import ../melee

# Variable offsets in our new ExtHit struct
const
    ExtHitHitlagOffset = 0x0 # float
    ExtHitSDIMultiplierOffset = ExtHitHitlagOffset + 0x4 # float
    ExtHitShieldstunMultiplierOffset = ExtHitSDIMultiplierOffset + 0x4 # float
    ExtHitHitstunModifierOffset = ExtHitShieldstunMultiplierOffset + 0x4 # float
    ExtHitFlags1Offset = ExtHitHitstunModifierOffset + 0x4 # char

    ExtHitFlags1Stretch = 0x80
    ExtHitFlags1AngleFlipOpposite= 0x40
    ExtHitFlags1AngleFlipCurrent= 0x20
    ExtHitFlags1SetWeight = 0x10
    ExtHitFlags1Flinchless = 0x8
    ExtHitFlags1DisableMeteorCancel = 0x4

# Size of new hitbox data = last var offset + last var offset.size
const ExtHitSize = ExtHitFlags1Offset + 0x4

# New variable pointer offsets for both ITEMS & FIGHTERS
const
    ExtHit0Offset = 0x0
    ExtHit1Offset = ExtHit0Offset + ExtHitSize
    ExtHit2Offset = ExtHit1Offset + ExtHitSize
    ExtHit3Offset = ExtHit2Offset + ExtHitSize

# New variable pointer offsets for FIGHTERS only
const
    SDIMultiplierOffset = ExtHit3Offset + ExtHitSize # float
    HitstunModifierOffset = SDIMultiplierOffset + 0x4 # float
    ShieldstunMultiplierOffset = HitstunModifierOffset + 0x4 # float

    Flags1Offset = ShieldstunMultiplierOffset + 0x4 # byte
    FlinchlessFlag = 0x1
    TempGravityFallSpeedFlag = 0x2
    DisableMeteorCancelFlag = 0x4

# New variable pointer offsets for ITEMS only
const
    ExtItHitlagMultiplierOffset = ExtHit3Offset + ExtHitSize # float

const 
    ExtFighterDataSize = (Flags1Offset + 0x4)
    ExtItemDataSize = (ExtItHitlagMultiplierOffset + 0x4)

const 
    CustomEventID = 0x3C
    EventLength = 0x8

func getExtHitOffset(regFighterData, regHitboxId: Register; extraDataOffset: int|Register; regOutput: Register = r3): string =
    if regOutput == regFighterData:
        raise newException(ValueError, "output register (" & $regOutput & ") cannot be the same as the fighter data register")
    result = ppc:
        mulli %regOutput, %regHitboxId, %ExtHitSize # hitbox id * ext hit size
        block:
            if extraDataOffset is Register:
                ppc: add %regOutput, %regOutput, %extraDataOffset
            else:
                ppc: addi %regOutput, %regOutput, %extraDataOffset
        add %regOutput, %regFighterData, %regOutput

func patchFighterDataAllocation(gameData: GameData; dataSizeToAdd: int): string =
    result = ppc:
        # patch init player block values
        gecko 0x80068EEC
        # extra stuff for 20XX
        block:
            if gameData.dataType == GameDataType.A20XX:
                ppc:
                    li r4, 0
                    stw r4, 0x20(r31)
                    stw r4, 0x24(r31)
                    stb r4, 0x0D(r3)
                    sth r4, 0x0E(r3)
                    stb r4, 0x21FD(r3)
                    sth r4, 0x21FE(r3)
            else:
                ""
        addi r30, r3, 0 # backup data pointer
        load r4, 0x80458fd0
        lwz r4, 0x20(r4)
        bla r12, %ZeroDataLength
        # exit
        mr r3, r30
        lis r4, 0x8046

        # next patch, adjust the fighter data size
        gecko 0x800679BC, li r4, %(gameData.fighterDataSize + dataSizeToAdd)

        # finally, any specific game mod patches
        block:
            if gameData.dataType == GameDataType.A20XX:
                # fixes crash for 20XX when loading marth & roy
                # NOTE: this will break the 'Marth and Roy Sword Swing File Colors'!!!
                ppc: gecko 0x8013651C, blr
            else:
                ""
        gecko.end

func patchItemDataAllocation(gameData: GameData; dataSizeToAdd: int): string =
    let newDataSize = gameData.itemDataSize + dataSizeToAdd
    result = ppc:
        # size patch
        gecko 0x80266FD8, li r4, %newDataSize
        # init extended item data patch
        gecko 0x80268754
        addi r29, r3, 0 # backup r3
        li r4, %newDataSize
        bla r12, %ZeroDataLength
        # _return
        mr r3, r29 # restore r3
        `mr.` r6, r3
        gecko.end

func patchSubactionCommandParsing(gameData: GameData): string =
    result = ppc:
        # custom fighter subaction event injection
        gecko 0x80073318
        cmpwi r28, %CustomEventID
        bne+ OriginalExit_80073318
        li r5, %(gameData.fighterDataSize)
        bl ParseEventData
        ba r12, 0x8007332C
        # local func for parsing the custom subaction event (items will use this too)
        ParseEventData:
            # r27 = item/fighter gobj
            # r29 = script struct ptr
            # r30 = item/fighter data
            # r5 = ExtItem/FighterDataOffset
            stwu sp, -0x50(sp)
            lwz r3, 0x8(r29) # current subaction ptr
            lbz r4, 0x1(r3)
            `rlwinm.` r0, r4, 0, 27, 27 # 0x10, apply to all previous hitboxes
            bne ApplyToAllPreviousHitboxes
            # otherwise, apply the properties to the given hitbox id
            li r0, 1 # loop once
            rlwinm r4, r4, 27, 29, 31 # 0xE0 hitbox id
            b SetLoopCount
            ApplyToAllPreviousHitboxes:
                li r0, 4 # loop 4 times
                li r4, 0

            SetLoopCount:
                mtctr r0
            # calculate ExtHit ptr offset in Ft/It data
            %getExtHitOffset(regFighterData = r30, regHitboxId = r4, extraDataOffset = r5, regOutput = r4)

            b BeginReadData

            CopyToAllHitboxes:
                # r6 = ptr to next ExtHit
                # r4 = ptr to old ExtHit
                addi r6, r4, %ExtHitSize
                Loop:
                    lwz r0, %%ExtHitHitlagOffset(r4)
                    stw r0, %%ExtHitHitlagOffset(r6)

                    lwz r0, %%ExtHitSDIMultiplierOffset(r4)
                    stw r0, %%ExtHitSDIMultiplierOffset(r6)

                    lwz r0, %%ExtHitShieldstunMultiplierOffset(r4)
                    stw r0, %%ExtHitShieldstunMultiplierOffset(r6)

                    lwz r0, %%ExtHitHitstunModifierOffset(r4)
                    stw r0, %%ExtHitHitstunModifierOffset(r6)

                    lwz r0, %%ExtHitFlags1Offset(r4)
                    stw r0, %%ExtHitFlags1Offset(r6)
                    addi r6, r6, %ExtHitSize
                    bdnz+ Loop
                b ExitParseEventData

            BeginReadData:
                # load 0.01 to use for multipliying our multipliers
                lwz r6, -0x514C(r13) # static vars??
                lfs f1, 0xF4(r6) # load 0.01 into f1
                # hitlag & SDI multipliers
                lhz r6, 0x1(r3)
                rlwinm r6, r6, 0, 0xFFF # 0xFFF, load hitlag multiplier
                sth r6, 0x44(sp)
                lhz r6, 0x3(r3)
                rlwinm r6, r6, 28, 0xFFF # load SDI multiplier
                sth r6, 0x46(sp)
                psq_l f0, 0x44(sp), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
                ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
                psq_st f0, %%ExtHitHitlagOffset(r4), 0, 7 # store calculated hitlag & sdi multipliers next to each other

                # read shieldstun multiplier & hitstun modifier
                lwz r6, -0x514C(r13)
                psq_l f1, 0xF4(r6), 1, 7 # load 0.01 in f1(ps0), 1.0 in f1(ps1)
                lhz r6, 0x4(r3)
                rlwinm r6, r6, 0, 0xFFF # load shieldstun multiplier
                sth r6, 0x40(sp)
                lbz r6, 0x6(r3) # read hitstun modifier byte
                slwi r6, r6, 24
                srawi r6, r6, 24
                sth r6, 0x42(sp)
                psq_l f0, 0x40(sp), 0, 5 # load shieldstun multi in f0(ps0), hitstun mod in f0(ps1) ]#
                ps_mul f0, f1, f0 # shieldstun multi * 0.01, hitstun mod * 1.00
                psq_st f0, %%ExtHitShieldstunMultiplierOffset(r4), 0, 7 # store results next to each other
                # read isSetWeight & Flippy bits & store it
                lbz r6, 0x7(r3)
                stb r6, %%ExtHitFlags1Offset(r4)

            bdnz+ CopyToAllHitboxes

            ExitParseEventData:
                # advance script
                addi r3, r3, %EventLength
                stw r3, 0x8(r29) # store current pointing ptr
                addi sp, sp, 80
                blr
        OriginalExit_80073318:
            lwz r12, 0(r3)

        # custom item subaction event injection
        gecko 0x80279ABC
        cmpwi r28, %CustomEventID
        bne+ OriginalExit_80279ABC
        li r5, %(gameData.itemDataSize)
        bl ParseEventData
        ba r12, 0x80279ad0 # we handled our custom event, now go to end of parsing
        
        OriginalExit_80279ABC:
            lwz r12, 0(r3)

        # patch for FastForwardSubactionPointer2
        # this is needed or else certain actions such as kirby's inhale will crash when
        # it contains the hitbox extension event
        gecko 0x80073574
        lwz r4, 0x8(r29) # orig code line, current action ptr
        cmpwi r28, %CustomEventID # Hitbox Extension Custom ID
        bne OriginalExit_80073574
        addi r4, r4, %EventLength
        stw r4, 0x8(r29)
        ba r12, 0x80073588
        OriginalExit_80073574:
            ""    
        gecko.end

func patchDefaultValuesForExtHit(gameData: GameData): string =
    result = ppc:
        # init default values for ExtHit variables - Melee Hitboxes
        gecko 0x8007127c
        # r0 = hitbox id
        # r31 = fighter data
        %getExtHitOffset(regFighterData = r31, regHitboxId = r0, extraDataOffset = gameData.fighterDataSize)
        # backup hitbox id to r30
        mr r30, r0
        bl InitDefaultValuesExtHit
        b OriginalExit_8007127C

        InitDefaultValuesExtHit:
            # inputs
            # r3 = fighter data
            # uses: r0, r3, f0
            # reset vars that need to be 1
            lfs f0, -0x7790(rtoc) # 1.0
            stfs f0, %%ExtHitHitlagOffset(r3)
            stfs f0, %%ExtHitSDIMultiplierOffset(r3)
            stfs f0, %%ExtHitShieldstunMultiplierOffset(r3)
            # reset vars that need to be 0
            lfs f0, -0x778C(rtoc) # 0.0
            stfs f0, %%ExtHitHitstunModifierOffset(r3)
            li r0, 0
            stw r0, %%ExtHitFlags1Offset(r3)
            blr

        OriginalExit_8007127C:
            mulli r3, r30, 312 # original line used r0 instead of r30

        # next, patch for Item hitboxes
        gecko 0x802790f0
        # r4 = hitbox id
        # r30 = item data
        # r0 = r30
        %getExtHitOffset(regFighterData = r30, regHitboxId = r4, extraDataOffset = gameData.itemDataSize)
        bl InitDefaultValuesExtHit
        # restore r0
        mr r0, r30
        mulli r3, r4, 316 # orig line
        gecko.end

func patchMain(gameData: GameData): string =
    result = ppc:
        %patchSubactionCommandParsing(gameData)
        %patchDefaultValuesForExtHit(gameData)
        gecko.end

const HitboxExtA20XX* =
    createCode "Hitbox Extension A20XX":
        code:
            %patchFighterDataAllocation(A20XXGameData, ExtFighterDataSize)
            %patchItemDataAllocation(A20XXGameData, ExtItemDataSize)
            %patchMain(A20XXGameData)

proc main() =
    generate "./generated/hitboxext.asm", HitboxExtA20XX

when isMainModule:
    main()