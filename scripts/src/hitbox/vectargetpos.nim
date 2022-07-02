import ../melee
import ../common/dataexpansion
import ../common/customcmds

const 
    HeaderInfo = MexHeaderInfo

proc getParseCmdCode*(): string =
    ppc:
        prolog xParseFunc, (0x4), xStartCopyOff, (0x4), xNumVarsCopy, (0x4), xAfterCopyFunc, (0x4), xEventLen, (0x4), xApplyType, (0x4)
        
        bl SetTargetPosCmd_Parse
        mflr r0
        stw r0, sp.xParseFunc(sp)

        li r0, {extHitOff(hitTargetPos)}
        stw r0, sp.xStartCopyOff(sp)

        li r0, {(sizeof(SpecialHitSetVecTargetPos) / sizeof(uint32)).uint32}
        stw r0, sp.xNumVarsCopy(sp) 

        li r0, 0
        stw r0, sp.xAfterCopyFunc(sp)

        li r0, {SetVecTargetPosCmd.eventLen}
        stw r0, sp.xEventLen(sp)

        lwz r3, 0x8(r29)
        lbz r0, 0x1(r3)
        rlwinm r0, r0, 29, 30, 31
        stw r0, sp.xApplyType(sp)

        mr r3, r27
        mr r4, r29
        addi r5, sp, sp.xParseFunc
        bla r12, 0x801510e0    

        epilog
        blr

        SetTargetPosCmd_Parse:
            # r3 = ExtHit
            # r4 = Normal Hit
            # r5 = cmd data pointer
            blrl
            sp.push
            sp.temp +2, ru, rl
            
            # r4 is free since we aren't working with the normal hit structs
            regs (3), rExtHit, rNormHit, rCmdData

            # get bone JObj and store it
            lbz r0, 0x4(rCmdData) # bone id
            lwz r4, 0x5E8(r30)
            rlwinm r0, r0, 4, 0, 27
            lwzx r4, r4, r0 # bone jobj ptr
            stw r4, {extHitTargetPosOff(targetPosNode)}(rExtHit)

            # get vec pos offsets
            lfs f1, -0x7740(rtoc) # ~1/256
            # load and store x & y
            lhz r0, 0x5(rCmdData) # x offset
            sth r0, sp.ru(sp)
           
            lhz r0, 0x7(rCmdData) # y offset
            sth r0, sp.rl(sp)
           
            psq_l f0, sp.ru(sp), 0, 5
            ps_mul f0, f1, f0
            psq_st f0, {extHitTargetPosOff(targetPosOffsetX)}(rExtHit), 0, 0 # store x and y offsets

            # load z and store it
            lhz r0, 0x9(rCmdData) # z offset
            sth r0, sp.ru(sp)
            psq_l f0, sp.ru(sp), 1, 5
            fmuls f0, f1, f0
            stfs f0, {extHitTargetPosOff(targetPosOffsetZ)}(rExtHit)

            # read and store frame
            lbz r0, 0xB(rCmdData)
            cmplwi r0, 0
            "bf- eq, 0f"
            li r0, 1
            0:
                stw r0, {extHitTargetPosOff(targetPosFrame)}(rExtHit)

            # store flags
            lbz r0, 0x2(rCmdData)
            li r4, 1
            rlwimi r0, r4, 0, {flag(hvtfIsSet)}
            stb r0, {extHitTargetPosOff(targetPosFlags)}(rExtHit)

            sp.pop
            
            blr