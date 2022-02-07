import ../melee
import sugar, strutils
import ../common/dataexpansion
#[- code: 0xF1
  name: Hitbox Extension
  parameters:
  - name: Hitbox ID
    bitCount: 3
  - name: Apply to Hitbox IDs 0-7
    bitCount: 1
    enums:
    - false
    - true
  - name: Hitlag Multiplier %
    bitCount: 12
  - name: SDI Multiplier %
    bitCount: 12
  - name: Shieldstun Multiplier %
    bitCount: 12
  - name: Hitstun Modifier
    bitCount: 8
    signed: true
  - name: Set Weight
    bitCount: 1
    enums:
      - false
      - true
  - name: Angle Flipper
    bitCount: 2
    enums:
      - Regular
      - Current Facing Direction
      - Opposite Current Facing Direction
  - name: Stretch
    bitCount: 1
    enums:
      - false
      - true
  - name: Flinchless
    bitCount: 1
    enums:
      - false
      - true
  - name: Disable Meteor Cancel
    bitCount: 1
    enums:
      - false
      - true
  - name: No Stale
    bitCount: 1
    enums:
      - false
      - true
  - name: Affect Only Throw Hitbox
    bitCount: 1
    enums:
      - false
      - true]#

const
    CodeVersion = "v1.8.0"
    CodeName = "Hitbox Extension " & CodeVersion
    CodeAuthors = ["sushie"]
    CodeDescription = "Allows you to modify hitlag, SDI, hitstun and more!"
    HeaderInfo = MexHeaderInfo
    ExtFighterDataOffset = HeaderInfo.fighterDataSize
    ExtItemDataOffset = HeaderInfo.itemDataSize

const
    CustomFunctionReadEvent = "0x801510e0"
    CustomFunctionInitDefaultEventVars = "0x801510e4"
    CustomFuncResetGravityAndFallSpeed = "0x801510e8"

proc patchInitVars(info: GameHeaderInfo): string =
    result = ppc:
       # Reset Custom Variables for Items
        gecko 0x80269cdc
        # r5 = itdata

        # reset custom vars to 1.0
        lfs f0, -0x7790(rtoc) # 1.0            
        stfs f0, {extItDataOff(HeaderInfo, hitlagMultiplier)}(r5)

        # reset custom vars to 0.0
        lfs f0, -0x33A8(rtoc) # 0.0, original code line

        # Init Default Values for ExtHit - Projectiles
        # SubactionEvent_0x2C_HitboxProjectile_StoreInfoToDataOffset
        gecko 0x802790fc
        # r4 = hitbox id
        # r30 = item data??
        mulli r3, r4, {sizeof(SpecialHit)}
        addi r3, r3, {ExtItemDataOffset}
        add r3, r30, r3
        bla r12, {CustomFunctionInitDefaultEventVars}
        lwz r0, 0(r29) # orig code line

        # Init Default Values for ExtHit - Melee
        # SubactionEvent_0x2C_HitboxMelee_StoreInfoToDataOffset
        gecko 0x80071288
        # r0 = hitbox ID
        # r31 = fighter data
        mulli r3, r0, {sizeof(SpecialHit)}
        addi r3, r3, {ExtFighterDataOffset}
        add r3, r31, r3
        bla r12, {CustomFunctionInitDefaultEventVars}
        lwz r0, 0(r30) # orig code line

        # Init Default Values for ExtHit - Throws
        # SubactionEvent_0x88_Throw
        gecko 0x80071e48
        # r0 = hitbox ID
        # r6 = fighter data
        # only throws are supported, release hitboxes are not
        cmplwi r0, 1 # throw type = Release
        bge Exit_80071e48
        # reset ExtHit vars
        addi r3, r6, {extFtDataOff(HeaderInfo, specialThrowHit)}
        bla r12, {CustomFunctionInitDefaultEventVars}
        # r3 still contains ExtHit
        # r0 contains 0
        # default hitlag multiplier for all throws is 0x
        stw r0, {extHitOff(hitlagMultiplier)}(r3)

        Exit_80071e48:
            addi r3, r31, 0 # orig code line

        # Reset Custom ExtFighterData vars that are involved at the end of Hitlag for Fighters
        gecko 0x8006d1d8
        # reset vars that need to be 1
        # r31 = fighter data
        lfs f0, -0x7790(rtoc) # 1
        stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
        lwz r0, 0x24(sp)

        # Fix for Hitlag multipliers not affecting hits within grabs
        # TODO what about for item related hitlag?
        gecko 0x8006d95c
        # reset multiplier ONLY when there isn't a grabbed_attacker ptr
        # r30 = fighter data
        lwz r0, 0x1A58(r30) # grab_attacker ptr
        cmplwi r0, 0
        bne Exit_8006d95c # if someone is grabbing us, don't reset the multiplier
        stfs f0, 0x1960(r30) # else reset it to 1.0
        Exit_8006d95c:
            ""

        # Reset Custom ExtFighterData vars that are involved with PlayerThink_Shield/Damage
        gecko 0x8006d8fc
        # reset custom ExtData vars for fighter
        # f1 = 0.0
        # r3 = 0
        # r30 = fighter data
        # reset vars to 0

        # reset flinchless flag to 0
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        rlwimi r0, r3, 0, {flag(ffHitByFlinchless)}
        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

        # reset disable meteor cancel flag to 0
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        rlwimi r0, r3, 2, {flag(ffDisableMeteorCancel)}
        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

        # reset throw hitlag flag to 0
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        rlwimi r0, r3, 3, {flag(ffForceHitlagOnThrown)}
        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

        # reset hitstun modifier to 0
        stfs f1, {extFtDataOff(HeaderInfo, hitstunModifier)}(r30)

        # reset vars to 1.0
        lfs f0, -0x7790(rtoc) # 1.0
        stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r30)

        stfs f1, 0x1838(r30) # original code line

        # Custom Non-Standalone Function For Initing Default Values in ExtHit
        gecko 0x801510e4
        # inputs
        # r3 = ExtHit
        # TODO samus create hitbox?
        cmpwi r4, 343
        beq- OriginalExit_801510e4

        # reset vars that need to be 1
        lfs f0, -0x7790(rtoc) # 1
        stfs f0, {extHitOff(hitlagMultiplier)}(r3)
        stfs f0, {extHitOff(sdiMultiplier)}(r3)
        stfs f0, {extHitOff(shieldstunMultiplier)}(r3)

        # reset vars that need to be 0
        lfs f0, -0x778C(rtoc) # 0.0
        stfs f0, {extHitOff(hitstunModifier)}(r3)
        li r0, 0
        stw r0, {extHitOff(hitFlags)}(r3)
        blr

        OriginalExit_801510e4:
            lfs f2, -0x5B3C(rtoc) # orig code line
        gecko.end

proc patchSubactionParsing(info: GameHeaderInfo): string =
    result = ppc:

        # Custom Non-Standalone Function For Reading Subaction Event Data
        gecko 0x801510e0
        cmpwi r4, 343
        beq- OriginalExit_801510e0

        # inputs
        # r3 = ExtHit struct ptr
        # r4 = Hit struct ptr
        # r5 = ExtItem/FighterDataOffset
        # r6 = Hit struct offset
        # r7 = Hit struct size
        # r8 = New Hit Struct Offset
        # r30 = item/fighter data
        # r27 = item/fighter gobj
        mflr r0
        stw r0, 0x4(sp)
        stwu sp, -0x50(sp)

        lwz r9, 0x8(r29) # load current subaction ptr
        li r10, 0 # used for checking if we need to loop for all hitboxes

        cmplwi r4, 0
        bne BeginReadData_801510e0

        CheckApplyToPrevious_801510e0:
            lbz r0, 0x1(r9)
            "rlwinm." r10, r0, 0, 27, 27 # 0x10, apply to all hitboxes 0-3
            rlwinm r3, r0, 27, 29, 31 # 0xE0 hitbox id/type
            beq CalculateHitStructs_801510e0 # if not set, just loop once
            # otherwise, apply the properties to the given hitbox id
            li r3, 0 # set starting id to 0

        CalculateHitStructs_801510e0:
            # input:
            # r3 = hitbox id
            # calculate normal Hit struct ptr
            mullw r4, r3, r7
            cmplwi r3, {OldHitboxCount}
            blt CalcNormal_801510e0
            add r4, r4, r8
            CalcNormal_801510e0:
                add r4, r4, r6
                add r4, r30, r4                
            # calculate ExtHit ptr offset in Ft/It data
            mulli r3, r3, {sizeof(SpecialHit)}
            add r3, r3, r5
            add r3, r30, r3

        BeginReadData_801510e0:
            # r3 = ExtHit ptr
            # r4 = Hit struct
            # load 0.01 to use for multipliying our multipliers
            lwz r5, -0x514C(r13) # static vars??
            lfs f1, 0xF4(r5) # load 0.01 into f1
            # hitlag & SDI multipliers
            lhz r5, 0x1(r9)
            rlwinm r5, r5, 0, 0xFFF # 0xFFF, load hitlag multiplier
            sth r5, 0x44(sp)
            lhz r5, 0x3(r9)
            rlwinm r5, r5, 28, 0xFFF # load SDI multiplier
            sth r5, 0x46(sp)
            psq_l f0, 0x44(sp), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
            ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
            psq_st f0, {extHitOff(hitlagMultiplier)}(r3), 0, 7 # store calculated hitlag & sdi multipliers next to each other

            # read shieldstun multiplier & hitstun modifier
            lwz r5, -0x514C(r13)
            psq_l f1, 0xF4(r5), 1, 7 # load 0.01 in f1(ps0), 1.0 in f1(ps1)
            lhz r5, 0x4(r9)
            rlwinm r5, r5, 0, 0xFFF # load shieldstun multiplier
            sth r5, 0x40(sp)
            lbz r5, 0x6(r9) # read hitstun modifier byte
            slwi r5, r5, 24
            srawi r5, r5, 24
            sth r5, 0x42(sp)
            psq_l f0, 0x40(sp), 0, 5 # load shieldstun multi in f0(ps0), hitstun mod in f0(ps1) ]#
            ps_mul f0, f1, f0 # shieldstun multi * 0.01, hitstun mod * 1.00
            psq_st f0, {extHitOff(shieldstunMultiplier)}(r3), 0, 7 # store results next to each other
            # read isSetWeight & Flippy bits & store it
            lbz r0, 0x7(r9)
            stb r0, {extHitOff(hitFlags)}(r3)
            bl SetBaseDamage_801510e0

        # don't loop if apply to all hitboxes is not enabled
        cmplwi r10, 0
        beq Exit_801510e0

        CopyToAllHitboxes_801510e0:
            # r5 = ptr to next ExtHit
            # r4 = ptr to Ft/ItHit
            # r3 = ptr to old ExtHit
            # r10 = index loop counter
            li r10, 1 # hitbox id to 1
            addi r5, r3, {sizeof(SpecialHit)} # next ExtHit struct
            add r4, r4, r7 # next Ft/It Hit struct
            Loop_801510e0:
                cmpwi r10, 4
                bne Body_801510e0
                add r4, r4, r8
                Body_801510e0:
                    lwz r0, {extHitOff(hitlagMultiplier)}(r3)
                    stw r0, {extHitOff(hitlagMultiplier)}(r5)

                    lwz r0, {extHitOff(sdiMultiplier)}(r3)
                    stw r0, {extHitOff(sdiMultiplier)}(r5)

                    lwz r0, {extHitOff(shieldstunMultiplier)}(r3)
                    stw r0, {extHitOff(shieldstunMultiplier)}(r5)

                    lwz r0, {extHitOff(hitstunModifier)}(r3)
                    stw r0, {extHitOff(hitstunModifier)}(r5)

                    lbz r0, {extHitOff(hitFlags)}(r3)
                    stb r0, {extHitOff(hitFlags)}(r5)
                    bl SetBaseDamage_801510e0

                addi r5, r5, {sizeof(SpecialHit)} # point to next ExtHit struct
                add r4, r4, r7 # point to next Ft/It Hit struct
                addi r10, r10, 1 # hitboxId++
                cmplwi r10, {NewHitboxCount}
                blt+ Loop_801510e0

        Exit_801510e0:
            # advance script
            addi r9, r9, 8 # TODO create a function to calculate this
            stw r9, 0x8(r29) # store current pointing ptr
            lwz r0, 0x54(sp)
            addi sp, sp, 0x50
            mtlr r0
            blr

        SetBaseDamage_801510e0:
            # r0 = flags
            # r4 = ft/it hit
            "rlwinm." r0, r0, 0, {flag(hfNoStale)}
            beq Return_SetBaseDamage_801510e0
            # if no staling == true, set Ft/It hit's damage_f to its base damage
            lwz r0, 0x8(r4)
            sth r0, 0x40(sp)
            psq_l f1, 0x40(sp), 1, 5
            stfs f1, 0xC(r4)
            Return_SetBaseDamage_801510e0:                
                blr

        OriginalExit_801510e0:
            fmr f3, f1

        # Patch for Subaction_FastForward
        gecko 0x80073430
        subi r0, r28, 10 # orig code line
        cmpwi r28, 0x3C # Hitbox Extension Custom ID
        bne OriginalExit_80073430
        lwz r4, 0x8(r29) # current action ptr
        addi r4, r4, 8
        stw r4, 0x8(r29)
        ba r12, 0x80073450
        OriginalExit_80073430:
            ""

        # Patch for FastForwardSubactionPointer2
        gecko 0x80073574
        # fixes a crash with Kirby when using inhale with a custom subaction event
        lwz r4, 0x8(r29) # orig code line, current action ptr
        cmpwi r28, 0x3C # Hitbox Extension Custom ID
        bne OriginalExit_80073574
        addi r4, r4, 8
        stw r4, 0x8(r29)
        ba r12, 0x80073588
        OriginalExit_80073574:
            ""

        # Custom Fighter Subaction Event
        gecko 0x80073318
        # use 0xF1 as code, make sure r28 == 0x3c
        # r27 = item/fighter gobj
        # r29 = script struct ptr
        # r30 = item/fighter data
        cmpwi r28, 0x3C
        bne+ OriginalExit_80073318

        # use throw hitbox if flag is set to true (only for players)
        lwz r3, 0x8(r29)
        lbz r3, 0x7(r3) # flags 1
        "rlwinm." r3, r3, 0, {flag(hfAffectOnlyThrow)}
        li r3, 0
        li r4, 0
        beq ReadEvent_80073318
        addi r3, r30, {extFtDataOff(HeaderInfo, specialThrowHit)}
        addi r4, r30, 0xDF4
        ReadEvent_80073318:
            li r5, {ExtFighterDataOffset}
            li r6, 2324
            li r7, {FtHitSize}
            li r8, {extFtDataOff(HeaderInfo, newHits) - ((OldHitboxCount * FtHitSize) + 2324)}
            bla r12, {CustomFunctionReadEvent}
            ba r12, 0x8007332c
        OriginalExit_80073318:
            lwz r12, 0(r3)

        # Custom Item Subaction Event
        gecko 0x80279abc
        # use 0xF1 as code, make sure r28 == 0x3c
        # r27 = item/fighter gobj
        # r29 = script struct ptr
        # r30 = item/fighter data
        cmpwi r28, 0x3C
        bne+ OriginalExit_80279abc
        li r3, 0
        li r4, 0
        li r5, {ExtItemDataOffset}
        li r6, 1492
        li r7, {ItHitSize}
        li r8, {extItDataOff(HeaderInfo, newHits) - ((OldHitboxCount * ItHitSize) + 1492)}
        bla r12, {CustomFunctionReadEvent}
        ba r12, 0x80279ad0
        OriginalExit_80279abc:
            lwz r12, 0(r3)        
        gecko.end


proc patchMain(gameInfo: GameHeaderInfo): string =
    result = ppc:
        %patchSubactionParsing(gameInfo)
        %patchInitVars(gameInfo)

        # Hitbox_ItemLogicOnPlayer Patch for Skipping On Hit GFX for Windboxes
        # Called when fighter defender is attacked by another fighter
        gecko 0x80078538
        # actually this patch works for fighter on fighter
        # doesn't have to be item on player
        lwz r3, 0x2C(r3)
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r3)
        "rlwinm." r0, r0, 0, {flag(ffHitByFlinchless)}
        beq OriginalExit_80078538 # not flinchless, show GFX
        blr
        OriginalExit_80078538:
            lwz r3, 0(r3) # restore r3
            mflr r0 # orig code line

        # CalculateKnockback patch for setting hit variables that affect the defender and attacker after all calculations are done
        gecko 0x8007aaf4
        # 0x90 of sp contains calculated ExtHit
        # r12 = source ftdata
        # r25 = defender ftdata
        # r31 = ptr ft hit
        # r30 = gobj of defender
        # r4 = gobj of src
        # original: check if hit element is electric and if it is, set the hitlag multiplier of the defender to 1.5x
        # this part is here as a failsafe if the SetVars function below somehow returns early due to invalid data
        lwz r0, 0x1C(r31)
        cmplwi r0, 2
        bne SetVars_8007aaf4
        lwz r3, -0x514C(r13)
        lfs f0, 0x1A4(r3)
        stfs f0, 0x1960(r25)
        SetVars_8007aaf4:
            lwz r3, 0x8(r19)
            mr r4, r30
            lwz r5, 0xC(r19) # ptr fthit of source
            lwz r6, 0x90(sp)
            bla r12, 0x801510dc
        li r0, 0 # skip the setting of electric hitlag multiplier

        # Hitbox Entity Vs Melee - Set Variables
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
        li r6, 0
        bla r12, 0x801510dc
        lwz r0, 0xCA0(r30) # original code line

        # 8026fe68 - proj vs proj 
        # Hitbox Entity Vs Projectiles - Set Variables
        gecko 0x80270bb8
        # eg. when a player hits an item (eg. goomba) with projectile
        # r31 = itdata
        # r19 = hit struct
        # r26 = gobj of defender
        # r30 = gobj of attacker
        mr r3, r30 # atk
        mr r4, r26 # def
        mr r5, r19 # ithit
        li r6, 0
        bla r12, 0x801510dc
        lwz r0, 0xCA0(r31) # original code line

        # ASDI multiplier mechanics patch
        gecko 0x8008e7a4
        # ASDI distance is increased or decreased based on multiplier
        # r31 = fighter data
        # f2 = 3.0 multiplier
        # f0 = free to use
        lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
        fmuls f2, f2, f0 # 3.0 * our custom sdi multiplier
        lfs f0, 0x63C(r31) # original code line

        # ASDI multiplier mechanics patch 2
        gecko 0x8008e7c0
        # ASDI distance is increased or decreased based on multiplier
        # r31 = fighter data
        # f2 = 3.0 multiplier
        # f0 = free to use
        lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)
        fmuls f2, f2, f0 # 3.0 * our custom sdi multiplier
        lfs f0, 0x624(r31) # original code line

        # SDI multiplier mechanics patch
        gecko 0x8008e558
        # SDI distance is increased or decreased based on multiplier
        # r3 = fighter data
        # f4 = 6.0 multiplier
        lfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r3)
        fmuls f4, f4, f0 # 6.0 * our custom sdi multiplier
        li r0, 254 # original code line

        # Hitstun mechanics patch
        gecko 0x8008dd70
        # Adds or removes frames of hitstun
        # 8008dd68: loads global hitstun multiplier of 0.4 from plco
        # f30 = calculated hitstun after multipling by 0.4
        # r29 = fighter data
        # f0 = free
        lfs f0, {extFtDataOff(HeaderInfo, hitstunModifier)}(r29) # load modifier
        fadds f30, f30, f0 # hitstun + modifier
        fctiwz f0, f30 # original code line

        # Shieldstun multiplier mechanics patch
        gecko 0x8009304c
        # note: yoshi's shield isn't affected... let's keep his shield unique
        # Shieldstun for defender is increased or decreased based on multiplier
        # f4 = 1.5
        # f0 is free here
        # r31 = fighter data
        lfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r31) # load modifier
        fmuls f4, f4, f0 # 1.5 * our multiplier
        fsubs f2, f2, f3 # orig code line

        # PlayerThink_Shield/Damage Patch - Apply Hitlag on Thrown Opponents
        gecko 0x8006d6e0
        # r30 = fighter data
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        "rlwinm." r0, r0, 0, {flag(ffForceHitlagOnThrown)}
        beq OriginalExit_8006d6e0
        lwz r29, 0x183C(r30) # thrown damage applied
        OriginalExit_8006d6e0:
            mr r3, r30 # orig code line

        # Throw_ThrowVictim Patch - Set ExtHit Vars & Hitlag on Thrown Victim
        gecko 0x800ddf88
        # r25 = always grabbed victim's gobj
        # r24 = grabber source gobj
        # r30 = always victim's fighter data
        # r31 = source's fighter data
        mr r3, r24
        mr r4, r25
        addi r5, r31, 0xDF4 # source throw hitbox
        addi r6, r31, {extFtDataOff(HeaderInfo, specialThrowHit)}
        bla r12, 0x801510dc

        # do hitlag vibration
        lfs f1, 0x1960(r30) # victim's hitlag multiplier
        mr r3, r30
        lwz r4, 0xE24(r28) # hitbox attribute
        lwz r5, 0xDFC(r28) # hitbox dmg
        lwz r6, 0x10(r30) # state id of victim
        bla r12, 0x80090594 # hitlag calculate

        # check if there are hitlag vibration frames
        # if there is vibration, the thrown victim should experience hitlag
        lhz r0, 0x18FA(r30) # model shift frames
        cmplwi r0, 0
        beq Exit_800ddf88

        # enable flag that forces hitlag for the thrown victim
        li r3, 1
        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        rlwimi r0, r3, 3, {flag(ffForceHitlagOnThrown)}
        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
        
        Exit_800ddf88:
            lbz r0, 0x2226(r27) # orig code line

        # Custom Non-Standalone Function For Handling Setting the Appropriate Hitlag & Hitstun & SDI Multipliers
        gecko 0x801510dc
        cmpwi r4, 343
        beq- OriginalExit_801510dc

        # both items and fighters can experience hitlag
        # only defender fighter experience SDI & Hitstun mods

        # inputs
        # r3 = source gobj
        # r4 = defender gobj
        # r5 = source hit ft/it hit struct ptr
        # r6 = optional calculated ExtHit
        # source cannot be a null ptr
        cmplwi r3, 0
        beq EpilogReturn_801510dc

        prolog r31, r30, r29, r28, r27, r26, r25, r24
        # backup regs
        # r31 = source data
        # r30 = defender data
        # r29 = r5 ft/it hit
        # r28 = ExtHit offset
        # r27 = r3 source gobj
        # r26 = r4 defender gobj

        lwz r31, 0x2C(r3)
        lwz r30, 0x2C(r4)
        mr r29, r5
        mr r27, r3
        mr r26, r4

        # if ExtHit was already given to us, don't calculate ExtHit again
        cmplwi r6, 0
        mr r28, r6
        bne CalculateTypes_801510dc

        # calculate ExtHit offset for given ft/it hit ptr
        mr r3, r27
        mr r4, r29
        bla r12, 0x801510d4
        # r3 now has offset
        cmplwi r3, 0
        beq Epilog_801510dc
        mr r28, r3 # ExtHit off

        CalculateTypes_801510dc:
            # r25 = source type
            # r24 = defender type
            mr r3, r27
            bl IsItemOrFighter_801510dc
            cmplwi r3, 0
            beq Epilog_801510dc
            mr r25, r3 # backup source type

            mr r3, r26
            bl IsItemOrFighter_801510dc
            cmplwi r3, 0
            beq Epilog_801510dc
            mr r24, r3 # backup def type

        StoreHitlag_801510dc:
            lfs f0, {extHitOff(hitlagMultiplier)}(r28) # load hitlag mutliplier

            # store hitlag multi for attacker depending on entity type
            cmpwi r25, 1
            addi r3, r31, {extItDataOff(HeaderInfo, hitlagMultiplier)}
            bne StoreHitlagMultiForAttacker_801510dc
            addi r3, r31, 0x1960
            
            StoreHitlagMultiForAttacker_801510dc:
                stfs f0, 0(r3)

            # store hitlag multi for defender depending on entity type                
            cmpwi r24, 1
            addi r3, r30, {extItDataOff(HeaderInfo, hitlagMultiplier)}
            bne ElectricHitlagCalculate_801510dc
            addi r3, r30, 0x1960

            # defenders can experience 1.5x more hitlag if hit by an electric attack
            ElectricHitlagCalculate_801510dc:
                lwz r0, 0x30(r29) # dmg hit attribute
                cmplwi r0, 2 # electric
                bne+ StoreHitlagMultiForDefender_801510dc # not electric, just store the orig multiplier
                # Electric
                lwz r4, -0x514C(r13) # PlCo values
                lfs f1, 0x1A4(r4) # 1.5 electric hitlag multiplier
                fmuls f0, f1, f0 # 1.5 * multiplier
                # store extra hitlag for DEFENDER ONLY in Melee

            StoreHitlagMultiForDefender_801510dc:
                stfs f0, 0(r3)

        # now we store other variables for defenders who are fighters ONLY
        cmpwi r24, 1 # fighter
        bne Epilog_801510dc # not fighter, skip this section      

        StoreHitstunModifier_801510dc:
            lfs f0, {extHitOff(hitstunModifier)}(r28)
            stfs f0, {extFtDataOff(HeaderInfo, hitstunModifier)}(r30)
            
        StoreSDIMultiplier_801510dc:
            lfs f0, {extHitOff(sdiMultiplier)}(r28)
            stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r30)
        
        CalculateFlippyDirection_801510dc:
            # TODO flippy for items such as goombas??
            lbz r3, {extHitOff(hitFlags)}(r28)
            lfs f0, 0x2C(r31) # facing direction of attacker
            "rlwinm." r0, r3, 0, 26, 26 # check FlippyTypeForward
            bne FlippyForward_801510dc
            "rlwinm." r0, r3, 0, 25, 25 # check opposite flippy
            bne StoreCalculatedDirection_801510dc
            b SetWeight_801510dc
            FlippyForward_801510dc:
                fneg f0, f0
            StoreCalculatedDirection_801510dc:
                stfs f0, 0x1844(r30)

        SetWeight_801510dc:
            # handles the setting and reseting of temp gravity & fall speed
            lbz r3, {extHitOff(hitFlags)}(r28)
            "rlwinm." r3, r3, 0, {flag(hfSetWeight)}
            beq ResetTempGravityFallSpeed_801510dc # hit isn't set weight, check to reset vars

            SetTempGravityFallSpeed_801510dc:
                # hit is set weight, set temp vars
                bl Constants_801510dc
                mflr r3
                addi r4, r30, 0x110 # ptr attributes of defender
                # set gravity
                lfs f0, 0(r3)
                stfs f0, 0x5C(r4)
                # set fall speed
                lfs f0, 4(r3)
                stfs f0, 0x60(r4)
                # set our temp gravity and fall speed flag to true
                li r3, 1
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                rlwimi r0, r3, 1, {flag(ffSetWeight)}
                stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                b StoreDisableMeteorCancel_801510dc

            ResetTempGravityFallSpeed_801510dc:
                # reset gravity and fall speed only if the temp flag is true
                lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                "rlwinm." r3, r3, 0, {flag(ffSetWeight)}
                beq StoreDisableMeteorCancel_801510dc
                # call custom reset func
                mr r3, r30
                bla r12, {CustomFuncResetGravityAndFallSpeed}

        StoreDisableMeteorCancel_801510dc:
            lbz r3, {extHitOff(hitFlags)}(r28)
            "rlwinm." r0, r3, 0, {flag(hfNoMeteorCancel)}
            li r3, 0
            beq MeteorCancelSet
            li r3, 1
            MeteorCancelSet:
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)
                rlwimi r0, r3, 2, {flag(ffDisableMeteorCancel)}
                stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(r30)

        Epilog_801510dc:
            epilog
            EpilogReturn_801510dc:
                blr

        IsItemOrFighter_801510dc:
            # input = gobj in r3
            # returns 0 = ?, 1 = fighter, 2 = item, in r3
            lhz r0, 0(r3)
            cmplwi r0,0x4
            li r3, 1
            beq Result
            li r3, 2
            cmplwi r0,0x6
            beq Result
            li r3, 0
            Result:
                blr

        Constants_801510dc:
            blrl
            ".float" 0.095 # mario's gravity
            ".float" 1.7 # mario's fall speed

        OriginalExit_801510dc:
            lwz r5, 0x010C(r31)


        # Patch PlayerThink_Shield/Damage Calculate Hitlag
        # If calculated hitlag is < 1.0, skip going into hitlag which disables A/S/DI
        gecko 0x8006d708
        lfs f0, -0x7790(rtoc) # 1.0
        fcmpo cr0, f1, f0
        bge+ OriginalExit_8006d708
        # TODO add checks if callbacks are for SDI & ASDI functions?
        # we set the callback ptrs to 0 because it's possible for an attacker who is stuck in hitlag from attacking something
        # to be able to A/S/DI. In vBrawl, attackers hit by a move that does 0 hitlag does not reset their initial freeze frames but allows for only DI
        li r3, 0
        stw r3, 0x21D0(r30) # hitlag frame-per-frame cb
        stw r3, 0x21D8(r30) # hitlag exit cb
        ba r12, 0x8006d7e0 # skip set hitlag functions
        OriginalExit_8006d708:
            stfs f1, 0x195C(r30)

        # Patch Damage_BranchToDamageHandler Calculate Hitlag for Pummels/Throw Related
        # If calculated hitlag is < 1.0, skip going into hitlag
        gecko 0x8008f030
        lfs f0, -0x7790(rtoc) # 1.0
        fcmpo cr0, f1, f0
        bge+ OriginalExit_8008f030
        ba r12, 0x8008f078 # skip set hitlag functions
        OriginalExit_8008f030:
            stfs f1, 0x195C(r27)            

        # Hitbox_MeleeLogicOnShield - Set Hit Vars
        gecko 0x80076dec
        # r31 = defender data
        # r30 = hit struct
        # r29 = src data
        # free regs to use: r0, f1, f0
        # get ExtHit
        lwz r3, 0(r29) # src gobj
        mr r4, r30 # hit struct
        bla r12, 0x801510d4
        cmplwi r3, 0
        beq Exit_80076dec

        # r3 = exthit
        lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
        stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r31)

        Exit_80076dec:
            # restore r3
            lwz r3, 0x24(sp)
            lwz r0, 0x30(r30) # original code line

        # Hitbox_ProjectileLogicOnShield - Set Hit Vars
        gecko 0x80077914
        # r29 = defender data
        # r28 = hit struct
        # r27 = src data
        # free regs to use f1, f0
        lwz r3, 0x4(r27) # src gobj
        mr r4, r28 # hit struct
        bla r12, 0x801510d4
        cmplwi r3, 0
        beq Exit_80077914

        # r3 = exthit
        lfs f0, {extHitOff(shieldstunMultiplier)}(r3)
        stfs f0, {extFtDataOff(HeaderInfo, shieldstunMultiplier)}(r29)

        Exit_80077914:
            lwz r0, 0x30(r28) # original code line

        # ItemThink_Shield/Damage Hitlag Function For Other Entities
        # Patch Hitlag Multiplier
        gecko 0x8026b454
        # patch hitlag function used by other entities
        # r31 = itdata
        # f0 = floored hitlag frames
        lfs f1, {extItDataOff(HeaderInfo, hitlagMultiplier)}(r31)
        fmuls f0, f0, f1 # calculated hitlag frames * multiplier
        fctiwz f0, f0

        # ItemThink_Shield/Damage After Hitlag Calculation
        # If calculated hitlag is < 1.0, skip going into hitlag
        gecko 0x8026a5f8
        lfs f0, -0x7790(rtoc) # 1.0
        fcmpo cr0, f1, f0
        bge+ OriginalExit_8026a5f8
        bla r12, 0x8026a68c # skip hitlag TODO why is this a branch link?? prob shouldn't be
        OriginalExit_8026a5f8:
            lfs f0, 0xCBC(r31)

        gecko.end

const HitboxExt* =
    createCode "Hitbox Extension":
        code:
            %patchMain(MexHeaderInfo)

proc main() =
    generate "./generated/hitboxext.asm", HitboxExt

when isMainModule:
    main()