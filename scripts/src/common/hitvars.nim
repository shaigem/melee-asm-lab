import dataexpansion
import ../melee

# custom functions
const 
    SetHitVarsUponHitFunc* = 0x801510dc
    GetExtHitForNormalFunc* = 0x801510d4

proc patchSetHitVarsOnHit*(): string =
    result = ppc:
        gecko {SetHitVarsUponHitFunc}
        cmpwi r4, 343
        beq- OriginalExit_SetHitVarsOnHit

        # both items and fighters can experience hitlag
        # only defender fighter experience SDI & Hitstun mods

        # inputs
        # r3 = source gobj
        # r4 = defender gobj
        # r5 = source hit ft/it hit struct ptr
        # r6 = optional calculated ExtHit
        # source cannot be a null ptr
        cmplwi r3, 0
        beq EpilogReturn_SetHitVarsOnHit

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
        bne CalculateTypes_SetHitVarsOnHit

        # calculate ExtHit offset for given ft/it hit ptr
        CalculateExtHitOffset_SetHitVarsOnHit:
            mr r3, r27
            mr r4, r29
            bla r12, {GetExtHitForNormalFunc}
        # r3 now has offset
        cmplwi r3, 0
        beq Epilog_SetHitVarsOnHit
        mr r28, r3 # ExtHit off

        CalculateTypes_SetHitVarsOnHit:
            # r25 = source type
            # r24 = defender type
            mr r3, r27
            bl IsItemOrFighter_SetHitVarsOnHit
            cmplwi r3, 0
            beq Epilog_SetHitVarsOnHit
            mr r25, r3 # backup source type

            mr r3, r26
            bl IsItemOrFighter_SetHitVarsOnHit
            cmplwi r3, 0
            beq Epilog_SetHitVarsOnHit
            mr r24, r3 # backup def type

        # store vars for both fighters and items
        %getHooks(CallBack(kind: cbkSetHitVarsOnHit, shvRegSrcData: r31, shvRegDefData: r30, shvRegExtHit: r28, shvRegHitStruct: r29))
        # now we store other variables for defenders who are fighters ONLY
        cmpwi r24, 1 # fighter
        bne Epilog_SetHitVarsOnHit # not fighter, skip this section      

        Epilog_SetHitVarsOnHit:
            epilog
            EpilogReturn_SetHitVarsOnHit:
                blr

        IsItemOrFighter_SetHitVarsOnHit:
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

        Constants_SetHitVarsOnHit:
            blrl

        OriginalExit_SetHitVarsOnHit:
            lwz r5, 0x010C(r31)

        gecko {GetExtHitForNormalFunc}
        cmpwi r4, 343
        beq- OriginalExit_GetExtHit
        
        # inputs
        # r3 = attacker gobj
        # r4 = attacker hit ft/it hit struct ptr
        # returns
        # r3 = ptr to ExtHit of attacker
        cmplwi r3, 0
        beq Invalid_GetExtHit
        cmplwi r4, 0
        beq Invalid_GetExtHit

        li r0, 4 # set loop 4 times
        mtctr r0

        # check attacker type
        lhz r0, 0(r3)
        lwz r3, 0x2C(r3) # fighter data
        cmplwi r0, 4 # fighter type
        beq GetExtHitForFighter
        cmplwi r0, 6 # item type
        beq GetExtHitForItem
        b Invalid_GetExtHit

        GetExtHitForItem:
            addi r5, r3, 1492 # attacker data ptr + hit struct offset
            addi r3, r3, {MexHeaderInfo.itemDataSize} # attacker data ptr + Exthit struct offset
            li r0, 316
        b GetExtHitLoop

        GetExtHitForFighter:
            addi r5, r3, 2324 # attacker data ptr + hit struct offset
            addi r3, r3, {MexHeaderInfo.fighterDataSize} # attacker data ptr + Exthit struct offset
            li r0, 312

        GetExtHitLoop:
            # uses
            # r3 = points to ExtHit struct offset
            # r4 = target hit struct ptr
            # r5 = temp var holding our current hit struct ptr
            # r0 = sizeof hit struct ptr
            b Comparison_GetExtHit
            Loop_GetExtHit:
                add r5, r5, r0 # point to next hit struct
                addi r3, r3, {sizeof(SpecialHit)} # point to next ExtHit struct
                Comparison_GetExtHit:
                    cmplw r5, r4 # hit struct ptr != given hit struct ptr
                    bdnzf eq, Loop_GetExtHit

        beq Exit_GetExtHit
    
        Invalid_GetExtHit:
            li r3, 0

        Exit_GetExtHit:
            blr

        OriginalExit_GetExtHit:
            lwz r31, 0x002C(r3)

        # CalculateKnockback Patch Beginning
        # Set 0x90(sp) to 0 - This is later used for storing our calculated ExtHit
        gecko 0x8007a0ec
        # r24 = 0
        stw r24, 0x90(sp)
        lis r29, 0x4330 # orig code

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
            bla r12, {SetHitVarsUponHitFunc}
        li r0, 0 # skip the setting of electric hitlag multiplier
        gecko.end

