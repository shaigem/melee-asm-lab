import ../melee
import ../common/dataexpansion
import ../common/customcmds

const 
    HeaderInfo = MexHeaderInfo
    CustomFunctionReadEvent = "0x801510e0"

# TODO provide the fighter data for callback funcs
proc parseHitboxExt*(): string =
    ppc:
        # inputs
        # r3 = fighter/item gobj
        # r4 = command info
        # r5 = stack obj (parseFunc, startCopyOff, copyLen, afterCopyFunc, scriptLen, applyType (0 = single, 1 = all active, 2 = throw))
        prolog rGObj, rData, rCmdInfo, rEventParse, rCmdData, rHitStructSize, rEightHitOff, rCurrentId, rExtHitTemplate, rCurExtHit, rCurHit
        mr rGObj, r3
        lwz rData, 0x2C(rGObj)
        mr rCmdInfo, r4
        mr rEventParse, r5
        lwz rCmdData, 0x8(rCmdInfo)
        li rCurrentId, -1
        li rExtHitTemplate, 0
        li rCurExtHit, 0
        li rCurHit, 0

        lhz r0, 0(rGObj)
        cmplwi r0, 0x4
        beq ParseHitboxExt_SetFighterVars
        cmplwi r0, 0x6
        bne ParseHitboxExt_Exit

        ParseHitboxExt_SetItemVars:
            lwz r5, 0x14(rEventParse)
            cmplwi r5, 2 # exit if trying to apply to throws for items
            beq ParseHitboxExt_Exit

            li r5, {HeaderInfo.itemDataSize}
            li r6, {ItemData.idItHit.int}
            li rHitStructSize, {ItHitSize}
            li rEightHitOff, {extItDataOff(HeaderInfo, newHits) - ((OldHitboxCount * ItHitSize) + ItemData.idItHit.int)}
            b ParseHitboxExt_Begin

        ParseHitboxExt_SetFighterVars:
            lwz r5, 0x14(rEventParse)
            cmplwi r5, 2
            beq ParseHitboxExt_SetForThrow

            li r5, {HeaderInfo.fighterDataSize}
            li r6, {FighterData.fdFtHit.int}
            li rHitStructSize, {FtHitSize}
            li rEightHitOff, {extFtDataOff(HeaderInfo, newHits) - ((OldHitboxCount * FtHitSize) + FighterData.fdFtHit.int)}
            b ParseHitboxExt_Begin

        ParseHitboxExt_SetForThrow:
            lwz r12, 0(rEventParse)
            cmplwi r12, 0
            beq ParseHitboxExt_Exit
            mtlr r12
            addi r3, rData, {extFtDataOff(HeaderInfo, specialThrowHit)}
            addi r4, rData, 0xDF4
            mr r5, rCmdData
            blrl
            b ParseHitboxExt_Exit

        ParseHitboxExt_Begin:
            # parse generic header that consists of the hitbox ID
            lbz r0, 0x1(rCmdData)
            rlwinm r3, r0, 27, 29, 31 # 0xE0 hitbox id
            lwz r0, 0x14(rEventParse)
            cmplwi r0, 0 # apply single
            beq ParseHitboxExt_GetHitStructs

            # applying to all hitboxes is true, so start with hitbox 0
            li r3, 0
            li rCurrentId, 0
            ParseHitboxExt_GetHitStructs:
                # inputs
                # r3 = hitbox id
                # cmpwi cr1, r3, 0
                mullw rCurHit, r3, rHitStructSize
                cmplwi r3, {OldHitboxCount}
                blt CalcNormal
                add rCurHit, rCurHit, rEightHitOff
                CalcNormal:
                    add rCurHit, rCurHit, r6
                    add rCurHit, rData, rCurHit                
                # calculate ExtHit ptr offset in Ft/It data
                mulli rCurExtHit, r3, {sizeof(SpecialHit)}
                add rCurExtHit, rCurExtHit, r5
                add rCurExtHit, rData, rCurExtHit

            ParseHitboxExt_FindActiveHitboxes:
                lwz r0, 0(rCurHit) # hitbox active
                cmpwi r0, 0
                beq ParseHitboxExt_FindActiveHitboxes_Next # if inactive, skip

                mr r3, rCurExtHit
                mr r4, rCurHit

                cmplwi rExtHitTemplate, 0
                bne ParseHitboxExt_FindActiveHitboxes_Copy

                ParseHitboxExt_FindActiveHitboxes_Parse:
                    # inputs
                    # r3 = ExtHit
                    # r4 = Normal Hit
                    lwz r12, 0(rEventParse)
                    cmplwi r12, 0
                    beq ParseHitboxExt_FindActiveHitboxes_Next
                    mtlr r12
                    mr r5, rCmdData
                    blrl
                    mr rExtHitTemplate, r3
                    b ParseHitboxExt_FindActiveHitboxes_Next

                ParseHitboxExt_FindActiveHitboxes_Copy:
                    # inputs
                    # r3 = ExtHit
                    # r4 = Normal Hit
                    subi r5, rExtHitTemplate, 4
                    subi r6, r3, 4

                    lwz r0, 0x4(rEventParse) # startCopyOffset
                    add r5, r5, r0
                    add r6, r6, r0

                    lwz r0, 0x8(rEventParse) # vars to copy
                    cmpwi r0, 0
                    beq- ParseHitboxExt_FindActiveHitboxes_Next

                    mtctr r0
                    ParseHitboxExt_FindActiveHitboxes_CopyLoop:
                        lwzu r0, 0x4(r5)
                        stwu r0, 0x4(r6)
                        bdnz+ ParseHitboxExt_FindActiveHitboxes_CopyLoop

                    # run after copy functions, if any
                    lwz r12, 0xC(rEventParse)
                    cmplwi r12, 0
                    beq ParseHitboxExt_FindActiveHitboxes_Next
                    mtlr r12
                    mr r5, rCmdData
                    blrl

                ParseHitboxExt_FindActiveHitboxes_Next:
                    cmpwi rCurrentId, 0
                    blt- ParseHitboxExt_Exit
                    addi rCurrentId, rCurrentId, 1
                    cmplwi rCurrentId, {OldHitboxCount}
                    bne+ Advance # != 4, continue
                    # switch to using the new hit offset (for ids >= 4)
                    add rCurHit, rCurHit, rEightHitOff
                    Advance:
                        cmplwi rCurrentId, {NewHitboxCount}
                        add rCurHit, rCurHit, rHitStructSize # next Ft/ItHit struct
                        addi rCurExtHit, rCurExtHit, {sizeof(SpecialHit)} # next ExtHit struct
                        blt+ ParseHitboxExt_FindActiveHitboxes

        ParseHitboxExt_Exit:
#            lwz r0, 0x10(rEventParse)
#            add rCmdData, rCmdData, r0
#            stw rCmdData, 0x8(rCmdInfo)
            epilog
            blr

proc getParseCmdCode*(): string =
    # r27 = fighter/item gobj
    ppc:

        prolog xParseFunc, (0x4), xStartCopyOff, (0x4), xNumVarsCopy, (0x4), xAfterCopyFunc, (0x4), xEventLen, (0x4), xApplyType, (0x4)

        cmpwi r3, 1
        bne ParseStandard

        # setup the following
        # r3 = parse func cb
        # r4 = start copy offset
        # r5 = # of vars to copy
        # r6 = afterCopy func cb
        # r7 = cmd event length
        # r8 = apply hitbox type (0 = single, 1 = all active, 2 = throw hitbox only)

        ParseAdvanced:
            bl HitboxExtCmd_Advanced_Parse
            mflr r3
            li r4, {extHitOff(hitAdvanced)}
            li r5, {(sizeof(SpecialHitAdvanced) / sizeof(uint32)).uint32} 
            li r6, 0
            li r7, {HitboxExtensionAdvancedCmd.eventLen}
            lwz r8, 0x8(r29)
            lbz r0, 0x1(r8)
            rlwinm r8, r0, 29, 30, 31
            b ParseSetupStack

        ParseStandard:
            bl HitboxExtCmd_Standard_Parse
            mflr r3
            li r4, 0
            li r5, {(sizeof(SpecialHitNormal) / sizeof(uint32)).uint32}
            bl HitboxExtCmd_Standard_Copy
            mflr r6
            li r7, {HitboxExtensionCmd.eventLen}
            # determine throw bit first
            lwz r9, 0x8(r29)
            lbz r0, 0x7(r9)
            "rlwinm." r8, r0, 1, 30, 30 # returns 2 if apply to throw bit is set
            bne ParseSetupStack
            lbz r0, 0x1(r9)
            rlwinm r8, r0, 28, 31, 31 # if apply to all active hitboxes bit is set, then return 1

        ParseSetupStack:
            stw r3, sp.xParseFunc(sp)
            stw r4, sp.xStartCopyOff(sp)
            stw r5, sp.xNumVarsCopy(sp)
            stw r6, sp.xAfterCopyFunc(sp)
            stw r7, sp.xEventLen(sp)
            stw r8, sp.xApplyType(sp)

        mr r3, r27
        mr r4, r29
        addi r5, sp, sp.xParseFunc
        bla r12, 0x801510e0
                
        HitboxExtCmd_Exit:
            epilog
            blr

        HitboxExtCmd_Standard_Copy:
            # r3 = ExtHit
            # r4 = Normal Hit
            # r5 = cmd data pointer
            blrl
            HitboxExtCmd_Standard_Copy_Begin:        
                lbz r0, 0x7(r5)
                "rlwinm." r0, r0, 0, {flag(hfNoStale)}
                beqlr
                sp.push 
                sp.temp +2, rg
                # if no staling == true, set Ft/It hit's damage_f to its base damage
                lwz r0, 0x8(r4)
                sth r0, sp.rg(sp)
                psq_l f1, sp.rg(sp), 1, 5
                stfs f1, 0xC(r4)
                sp.pop
                blr
    
        HitboxExtCmd_Standard_Parse:
            # r3 = ExtHit
            # r4 = Normal Hit
            # r5 = cmd data pointer
            blrl
            sp.push 
            sp.temp +2, rg, ba
            # load 0.01 to use for multipliying our multipliers
            lwz r6, -0x514C(r13) # static vars??
            lfs f1, 0xF4(r6) # load 0.01 into f1
            # hitlag & SDI multipliers
            lhz r6, 0x1(r5)
            rlwinm r6, r6, 0, 0xFFF # 0xFFF, load hitlag multiplier
            sth r6, sp.rg(sp)
            lhz r6, 0x3(r5)
            rlwinm r6, r6, 28, 0xFFF # load SDI multiplier
            sth r6, sp.ba(sp)
            psq_l f0, sp.rg(sp), 0, 5 # load both hitlag & sdi multipliers into f0 (ps0 = hitlag multi, ps1 = sdi multi)
            ps_mul f0, f1, f0 # multiply both hitlag & sdi multipliers by f1 = 0.01
            psq_st f0, {extHitNormOff(hitlagMultiplier)}(r3), 0, 7 # store calculated hitlag & sdi multipliers next to each other

            # read shieldstun multiplier & hitstun modifier
            lwz r6, -0x514C(r13)
            psq_l f1, 0xF4(r6), 1, 7 # load 0.01 in f1(ps0), 1.0 in f1(ps1)
            lhz r6, 0x4(r5)
            rlwinm r6, r6, 0, 0xFFF # load shieldstun multiplier
            sth r6, sp.rg(sp)
            lbz r6, 0x6(r5) # read hitstun modifier byte
            slwi r6, r6, 24
            srawi r6, r6, 24
            sth r6, sp.ba(sp)
            psq_l f0, sp.rg(sp), 0, 5 # load shieldstun multi in f0(ps0), hitstun mod in f0(ps1) ]#
            ps_mul f0, f1, f0 # shieldstun multi * 0.01, hitstun mod * 1.00
            psq_st f0, {extHitNormOff(shieldstunMultiplier)}(r3), 0, 7 # store results next to each other
            # read isSetWeight & Flippy bits & store it
            lbz r0, 0x7(r5)
            stb r0, {extHitNormOff(hitFlags)}(r3)
            sp.pop
            "rlwinm." r0, r0, 0, {flag(hfDisableHitlag)}
            beq HitboxExtCmd_Standard_Copy_Begin

            # if DisableHitlag flag is true, set the hitlag multiplier to 0
            li r0, 0
            stw r0, {extHitNormOff(hitlagMultiplier)}(r3)

            b HitboxExtCmd_Standard_Copy_Begin

        HitboxExtCmd_Advanced_Parse:
            # r3 = ExtHit
            # r4 = Normal Hit
            # r5 = cmd data pointer
            blrl
            lbz r0, 0x7(r5)
            stb r0, {extHitAdvOff(hitAdvFlags)}(r3)
            blr