import ../melee
import sugar, strutils

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

type
    CallbackHookKind* = enum
        chkResetVarsPlayerThinkShieldDamage
        chkSetDefenderFighterVarsOnHit

    Callback = ref CallbackObj
    CallbackObj = object
        case kind: CallbackHookKind
        of chkResetVarsPlayerThinkShieldDamage:
            regFloatZero, regFloatOne, regIntZero, regFighterData: Register
        of chkSetDefenderFighterVarsOnHit:
            regDefData, regExtHitOff: Register

    CallbackHookHandler* = proc (cb: Callback): string {.closure.}
    CallbackHookHandlers* = seq[(CallbackHookKind, CallbackHookHandler)]
    HitboxExtContext* = ref object
        gameData*: GameData
        callbackHookHandlers*: CallBackHookHandlers

proc addCallbackHook*(hitboxExt: HitboxExtContext; hookKind: CallbackHookKind; handler: CallbackHookHandler) =
    hitboxExt.callbackHookHandlers.add((hookKind, handler))
proc getFormattedCallbackHooks(hitboxExt: HitboxExtContext; cb: Callback): string =
    let handlers = hitboxExt.callbackHookHandlers
    result = (collect(newSeq) do:
        for h in handlers:
            if h[0] == cb.kind: h[1](cb)).join("\n")
        
func calcOffsetFtData*(ctx: HitboxExtContext, varOff: int): int = ctx.gameData.fighterDataSize + varOff
func calcOffsetItData*(ctx: HitboxExtContext, varOff: int): int = ctx.gameData.itemDataSize + varOff

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

func patchSubactionCommandParsing(ctx: HitboxExtContext): string =
    result = ppc:
        # custom fighter subaction event injection
        gecko 0x80073318
        cmpwi r28, %CustomEventID
        bne+ OriginalExit_80073318
        li r5, %(ctx.gameData.fighterDataSize)
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
        li r5, %(ctx.gameData.itemDataSize)
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

func patchDefaultValuesForExtHit(ctx: HitboxExtContext): string =
    result = ppc:
        # init default values for ExtHit variables - Melee Hitboxes
        gecko 0x8007127c
        # r0 = hitbox id
        # r31 = fighter data
        %getExtHitOffset(regFighterData = r31, regHitboxId = r0, extraDataOffset = ctx.gameData.fighterDataSize)
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
        %getExtHitOffset(regFighterData = r30, regHitboxId = r4, extraDataOffset = ctx.gameData.itemDataSize)
        bl InitDefaultValuesExtHit
        # restore r0
        mr r0, r30
        mulli r3, r4, 316 # orig line
        gecko.end

proc patchResetVarsPlayerThinkShieldDamage(ctx: HitboxExtContext): string =
    # f1 = 0.0
    # f0 = 1.0
    # r3 = 0
    # r30 = fighter data
    result = ppc:
        gecko 0x8006D8FC
        lfs f0, -0x7790(rtoc) # 1.0
        stfs f1, 0x1838(r30) # original code line
        %getFormattedCallbackHooks(ctx, Callback(kind: chkResetVarsPlayerThinkShieldDamage, regFloatZero: f1, regFloatOne: f0, regIntZero: r3, regFighterData: r30))
        gecko.end

proc patchSetVarsOnHit(ctx: HitboxExtContext): string =
    ## Set ExtHit vars that affect defender and attacker
    result = ppc:
        # CalculateKnockback patch
        gecko 0x8007aaf4
        # r12 = source ftdata
        # r25 = defender ftdata
        # r31 = ptr ft hit
        # r30 = gobj of defender
        # r4 = gobj of src
        lwz r3, 0x8(r19) # src gobj
        mr r4, r30 # def gobj
        lwz r5, 0xC(r19) # ptr fthit of source
        bl SetVarsOnHit
        ba r12, 0x8007ab0c # done, so skip to end of func

        SetVarsOnHit:
            # inputs
            # r3 = source gobj
            # r4 = defender gobj
            # r5 = source hit ft/it hit struct ptr
            prolog rSrcData, rDefData, rHitStruct, rExtHitStruct, rSrcGObj, rDefGObj, rSrcType, rDefType
            lwz rSrcData, 0x2C(r3)
            lwz rDefData, 0x2C(r4)
            mr rHitStruct, r5
            mr rSrcGObj, r3
            mr rDefGObj, r4

            # calculate ExtHit offset for given ft/it hit ptr
            mr r3, rSrcGObj # src gobj
            bl IsItemOrFighter
            mr rSrcType, r3 # backup source type
            cmpwi r3, 1
            beq SetupFighterVars
            cmpwi r3, 2
            bne Epilog_SetVarsOnHit

            SetupItemVars:
                li r5, 1492
                li r6, 316
                li r7, %(ctx.gameData.itemDataSize)
            b CalculateExtHitOffset

            SetupFighterVars:
                li r5, 2324
                li r6, 312
                li r7, %(ctx.gameData.fighterDataSize)

            CalculateExtHitOffset:
                mr r3, rSrcData
                mr r4, rHitStruct
                bl GetExtHitForHitboxStruct

            # r3 now has offset
            cmpwi r3, 0
            beq Epilog_SetVarsOnHit

            mr rExtHitStruct, r3 # ExtHit off

            # r25 = source type
            # r24 = defender type
            # r28 = ExtHit offset

            # set vars for def & attackers

            # now we store other variables for defenders who are fighters ONLY
            cmpwi rDefType, 1 # fighter
            bne Epilog_SetVarsOnHit # not fighter, skip this section

            %getFormattedCallbackHooks(ctx, Callback(kind: chkSetDefenderFighterVarsOnHit, regDefData: r30, regExtHitOff: r28))

            Epilog_SetVarsOnHit:
                epilog
                blr

            CalculateHitlagMultiOffset:
                cmpwi r3, 1
                beq Return1960
                cmpwi r3, 2
                bne Exit_CalculateHitlagMultiOffset
                li r3, %(calcOffsetItData(ctx, ExtItHitlagMultiplierOffset))
                b Exit_CalculateHitlagMultiOffset
                Return1960:
                    li r3, 0x1960
                Exit_CalculateHitlagMultiOffset:
                    blr

            IsItemOrFighter:
                # input = gobj in r3
                # returns 0 = ?, 1 = fighter, 2 = item, in r3
                lhz r0, 0(r3)
                cmpwi r0,0x4
                li r3, 1
                beq Result_IsItemOrFighter
                li r3, 2
                cmpwi r0,0x6
                beq Result_IsItemOrFighter
                li r3, 0
                Result_IsItemOrFighter:
                    blr

            GetExtHitForHitboxStruct:
                # uses
                # r3, r4, r5, r6, r7, r8
                # inputs
                # r3 = ft/itdata
                # r4 = ft/ithit
                # r5 = ft/ithit start offset relative to ft/itdata
                # r6 = ft/ithit struct size
                # r7 = ExtItem/Fighter offset
                # outputs
                # r3 = ptr to ExtHit
                add r8, r3, r5
                # r5 is now free to use
                li r5, 0
                b Comparison_GetExtHitForHitboxStruct
                Loop_GetExtHitForHitboxStruct:
                    addi r5, r5, 1
                    cmpwi r5, 3
                    bgt- NotFound_GetExtHitForHitboxStruct
                    add r8, r8, r6
                    Comparison_GetExtHitForHitboxStruct:
                        cmplw r8, r4
                        bne+ Loop_GetExtHitForHitboxStruct
                # found
                mulli r5, r5, %ExtHitSize
                add r5, r5, r7
                add r5, r3, r5
                mr r3, r5
                blr
                NotFound_GetExtHitForHitboxStruct:
                    li r3, 0
                    blr

        # Hitbox Entity Vs Melee - Patch Set Variables
        gecko 0x802705ac
        # eg. when a player hits an item with melee
        # r30 = itdata
        # r26 = fthit
        # r28 = attacker data ptr
        # r24 = gobj of itdata
        # r29 = gobj of attacker
        mr r3, r29 # src
        mr r4, r24 # def
        mr r5, r26 # ithit
        bl SetVarsOnHit
        OriginalExit_802705ac:
            lwz r0, 0xCA0(r30)

        # 8026fe68 - proj vs proj 
        # Hitbox Entity Vs Projectiles - Set Variables
        gecko 0x80270BB8
        # eg. when a player hits an item (eg. goomba) with projectile
        # r31 = itdata
        # r19 = hit struct
        # r26 = gobj of defender
        # r30 = gobj of attacker
        mr r3, r30 # atk
        mr r4, r26 # def
        mr r5, r19 # ithit
        bl SetVarsOnHit
        OriginalExit_80270BB8:
            lwz r0, 0xCA0(r31)
        gecko.end

const PropertyPatches = proc(ctx: HitboxExtContext): string =
    include property/hitstunmod

proc patchMain(gameData: GameData): string =
    let ctx = HitboxExtContext(gameData: gameData)
    result = ppc:
        %PropertyPatches(ctx)
        %patchSubactionCommandParsing(ctx)
        %patchDefaultValuesForExtHit(ctx)
        %patchSetVarsOnHit(ctx)
        %patchResetVarsPlayerThinkShieldDamage(ctx)
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