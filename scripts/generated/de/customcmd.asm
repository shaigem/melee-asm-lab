.include "punkpc.s"
punkpc ppc
# Set Vec Target Pos
# authors: @["sushie"]
# description: 
ppc:
gecko 2147955476
cmpwi r28, 62
bne+ OriginalExit_80073314
prolog rExtHit, rFighterData, rScriptPtr, rCmdPtr, xTempUpper, (0x00000002), xTempLower, (0x00000002)
lwz rCmdPtr, 0x00000008(rScriptPtr)
lbz r4, 0x00000001(rCmdPtr)
rlwinm r4, r4, 27, 29, 31
mulli r4, r4, 60
addi r4, r4, 9248
add rExtHit, rFighterData, r4
lbz r4, 0x00000001(rCmdPtr)
rlwinm r4, r4, 28, 31, 31
stw r4, 52(rExtHit)
lbz r4, 0x00000001(rCmdPtr)
rlwinm r4, r4, 29, 31, 31
stw r4, 56(rExtHit)
lbz r3, 0x00000002(rCmdPtr)
lwz r4, 0x000005E8(rFighterData)
rlwinm r0, r3, 4, 0, 27
lwzx r3, r4, r0
stw r3, 20(rExtHit)
lfs f1, 0xFFFF88C0(rtoc)
lhz r0, 0x00000003(rCmdPtr)
sth r0, sp.xTempUpper(sp)
lhz r0, 0x00000005(rCmdPtr)
sth r0, sp.xTempLower(sp)
psq_l f0, sp.xTempUpper(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 24(rExtHit), 0, 0
stfs f0, 32(rExtHit)
lbz r0, 0x00000007(rCmdPtr)
stw r0, 36(rExtHit)
lwz r3, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r3)
lbz r0, 0x00000008(rCmdPtr)
sth r0, sp.xTempUpper(sp)
psq_l f0, sp.xTempUpper(sp), 0, 5
fmuls f0, f0, f1
stfs f0, 40(rExtHit)
addi r3, rCmdPtr, 12
stw r3, 0x00000008(rScriptPtr)
epilog
ba r12, 2147955500
OriginalExit_80073314:
add r3, r31, r0
gecko 2147955760
subi r0, r28, 10
cmpwi r28, 62
bne OriginalExit_80073430
lwz r4, 0x00000008(r29)
addi r4, r4, 12
stw r4, 0x00000008(r29)
ba r12, 2147955792
OriginalExit_80073430:

gecko 2147956088
cmpwi r28, 62
bne OriginalExit_80073578
addi r4, r4, 12
stw r4, 0x00000008(r29)
ba r12, 2147956104
OriginalExit_80073578:
lbz r0, 0xFFFFFFF6(r3)
gecko.end
