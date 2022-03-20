import dataexpansion
import ../melee

const
    EventCode = 0x3E
    EventLength = 12

    SetVecTargetPos* =
        createCode "Set Vec Target Pos":
        description: ""
        authors: ["sushie"]
        code:
            ppc:
                # Subaction Event Parsing (0xF9)
                gecko 0x80073314
                cmpwi r28, {EventCode}
                bne+ OriginalExit_80073314
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data

                prolog rExtHit, rFighterData, rScriptPtr, rCmdPtr, xTempUpper, (0x2), xTempLower, (0x2)

                lwz rCmdPtr, 0x8(rScriptPtr) # load current subaction ptr

                lbz r4, 0x1(rCmdPtr)
                rlwinm r4, r4, 27, 29, 31 # 0xE0
                # get hitbox struct from ID
                mulli r4, r4, {sizeof(SpecialHit)}
                addi r4, r4, {extFtDataOff(MexHeaderInfo, specialHits)}
                add rExtHit, rFighterData, r4

                # get bone JObj
                lbz r3, 0x2(rCmdPtr) # bone id
                lwz r4, 0x5E8(rFighterData)
                rlwinm r0, r3, 4, 0, 27
                lwzx r3, r4, r0 # bone jobj ptr
                stw r3, {extHitOff(targetPosNode)}(rExtHit)

                # get vec pos offsets
                lfs f1, -0x7740(rtoc) # ~1/256
                # load and store x & y
                lhz r0, 0x3(rCmdPtr) # x offset
                sth r0, sp.xTempUpper(sp)
                lhz r0, 0x5(rCmdPtr) # y offset
                sth r0, sp.xTempLower(sp)
                psq_l f0, sp.xTempUpper(sp), 0, 5
                ps_mul f0, f1, f0
                psq_st f0, {extHitOff(targetPosOffsetX)}(rExtHit), 0, 0
                stfs f0, {extHitOff(targetPosOffsetZ)}(rExtHit)
                #li r0, 0
                #stw r0, {extHitOff(targetPosOffsetZ)}(rExtHit) # TODO should i just make it an option?

                # read & store frame
                lbz r0, 0x7(rCmdPtr)
                stw r0, {extHitOff(targetPosFrame)}(rExtHit)
                
                # read & store pull speed %
                lwz r3, -0x514C(r13) # static vars??
                lfs f1, 0xF4(r3) # load 0.01 into f1
                lbz r0, 0x8(rCmdPtr)
                sth r0, sp.xTempUpper(sp)
                psq_l f0, sp.xTempUpper(sp), 0, 5
                fmuls f0, f0, f1
                stfs f0, {extHitOff(targetPosPullSpeedMultiplier)}(rExtHit)

                # skip to next cmd event
                addi r3, rCmdPtr, {EventLength}
                stw r3, 0x8(rScriptPtr)
                epilog
                ba r12, 0x8007332c

                OriginalExit_80073314:
                    add r3, r31, r0 # original code line

                # Patch for Subaction_FastForward
                gecko 0x80073430
                subi r0, r28, 10 # orig code line
                cmpwi r28, {EventCode}
                bne OriginalExit_80073430
                lwz r4, 0x8(r29) # current action ptr
                addi r4, r4, {EventLength}
                stw r4, 0x8(r29)
                ba r12, 0x80073450
                OriginalExit_80073430:
                    ""

                # Patch for FastForwardSubactionPointer2
                gecko 0x80073578 # TODO gotta add another spot since altimor uses it
                cmpwi r28, {EventCode}
                bne OriginalExit_80073578
                addi r4, r4, {EventLength}
                stw r4, 0x8(r29)
                ba r12, 0x80073588
                OriginalExit_80073578:
                    lbz r0, -0xA(r3)
                gecko.end


when isMainModule:
    generate "./generated/customcmd.asm", SetVecTargetPos
