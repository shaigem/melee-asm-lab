import ../melee
import ../common/dataexpansion
import ../common/customcmds

const 
    HeaderInfo = MexHeaderInfo

proc getParseCmdCode*(): string =
    # r27 = fighter/item gobj
    # r30 = item/fighter data
    # r29 = command info
    ppc:
        li r3, {HeaderInfo.fighterDataSize}
        lhz r0, 0(r27)
        cmplwi r0, 0x4
        beq AttackCapsuleCmd_Read
        cmplwi r0, 0x6
        li r3, {HeaderInfo.itemDataSize}
        bne AttackCapsuleCmd_Exit
        
        regs (3), rExtHit, rCmdPtr, (29), rCmdInfo, rData
        
        AttackCapsuleCmd_Read:
            # inputs
            # r3 = ExtHit offset
            lwz rCmdPtr, 0x8(rCmdInfo) # subaction ptr

            lbz r0, 0x1(rCmdPtr) # load first byte
            rlwinm r5, r0, 27, 29, 31 # 0xE0 hitbox id/type

            # get ExtHit for hitbox ID
            mulli r5, r5, {sizeof(SpecialHit)}
            add r3, r5, r3
            add rExtHit, rData, r3

            sp.push
            sp.temp +2, x1, x2

            lfs f1, -0x7740(rtoc) # ~1/256
            # load and store x2 & y2 offsets
            lhz r0, 0x2(rCmdPtr) # x2 offset
            sth r0, sp.x1(sp)

            lhz r0, 0x4(rCmdPtr) # y2 offset
            sth r0, sp.x2(sp)

            psq_l f0, sp.x1(sp), 0, 5 # load both x2 and y2 offsets into f0
            ps_mul f0, f1, f0 # multiply by ~1/256
            psq_st f0, {extHitAdvOff(offsetX2)}(rExtHit), 0, 0

            # load and store z2 offset
            lhz r0, 0x6(rCmdPtr) # z2 offset
            sth r0, sp.x1(sp)
            psq_l f0, sp.x1(sp), 1, 5
            ps_mul f0, f1, f0 # multiply by ~1/256
            stfs f0, {extHitAdvOff(offsetZ2)}(rExtHit)

            # enable stretch flag
            li r5, 1
            lbz r0, {extHitAdvOff(hitAdvFlags)}(rExtHit)
            rlwimi r0, r5, 7, {flag(hafStretch)}
            stb r0, {extHitAdvOff(hitAdvFlags)}(rExtHit)

            sp.pop

        AttackCapsuleCmd_Exit:
            lwz r4, 0x8(rCmdInfo)
            addi r4, r4, {AttackCapsuleCmd.eventLen}
            stw r4, 0x8(rCmdInfo)
            blr
