.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147985512
regs (3), rHitStruct, (15), rAttackerData, (25), rDefenderData
lwz r0, 0x00000020(rHitStruct)
cmplwi r0, 367
bne+ OriginalExit_8007a868
stwu sp, 0xFFFFFFE0(sp)
li r0, 0
stw r0, 0x00000014(sp)
stw r0, 0x00000018(sp)
stw r0, 0x0000001C(sp)
lfs f1, 0x0000004C(rHitStruct)
lfs f0, 0x00001854(rDefenderData)
fsubs f2, f1, f0
lfs f1, 0x000000B0(rDefenderData)
lfs f0, 0x000000B0(rAttackerData)
fsubs f1, f1, f0
lfs f0, 0xFFFF8900(rtoc)
fcmpo cr0, f1, f0
bge+ CalculateDiffY_8007a868
fneg f2, f2
CalculateDiffY_8007a868:
lfs f1, 0x00000050(rHitStruct)
lfs f0, 0x00001858(rDefenderData)
fsubs f1, f1, f0
lfs f0, 0xFFFFC2A0(rtoc)
fmuls f5, f2, f0
stfs f5, 0x00000014(sp)
fmuls f5, f1, f0
stfs f5, 0x00000018(sp)
bla r12, 2147626032
lfs f0, 0xFFFF893C(rtoc)
fmuls f0, f0, f1
fctiwz f0, f0
stfd f0, 0x0000000C(sp)
lwz r0, 0x00000010(sp)
stw r0, 0x00000004(r31)
addi r3, sp, 0x00000014
bla r12, 2150903292
fmr f5, f1
lfs f0, 0x000000C8(rAttackerData)
stfs f0, 0x00000014(sp)
lfs f0, 0x000000CC(rAttackerData)
stfs f0, 0x00000018(sp)
bla r12, 2150903292
lwz rHitStruct, 0x0000000C(r17)
lwz r0, 0x00000024(rHitStruct)
sth r0, 0x0000000C(sp)
psq_l f3, 0x0000000C(sp), 1, 5
lfs f0, 0xFFFF8934(rtoc)
fmuls f0, f3, f0
fmadds f1, f1, f0, f5
lfs f0, 0xFFFFC5C8(rtoc)
fdivs f26, f1, f0
lwz r0, 0x00000028(rHitStruct)
sth r0, 0x0000000C(sp)
psq_l f0, 0x0000000C(sp), 1, 5
fcmpo cr0, f26, f0
ble Epilog_8007a868
fmr f26, f0
Epilog_8007a868:
addi sp, sp, 0x00000020
ba r12, 2147985720
OriginalExit_8007a868:

gecko.end
