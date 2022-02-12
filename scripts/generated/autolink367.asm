.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147925504
regs (r31), rFighterData
lbz r0, 10688(rFighterData)
rlwinm. r0, r0, 0, 16
beq OriginalExit_8006BE00
prolog xDiffX, (0x00000004), xDiffY, (0x00000004), xDiffZ, (0x00000004)
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, 5
bge StopPullIn_8006BE00
addi r3, rFighterData, 10692
addi r4, rFighterData, 0x000000B0
addi r5, sp, sp.xDiffX
bla r12, 2147538168
lfs f3, 0xFFFFC2A0(rtoc)
lfs f2, sp.xDiffX(sp)
lfs f1, sp.xDiffY(sp)
bl AddAtkMomentum_8006BE00
b StoreNewSpeeds_8006BE00
AddAtkMomentum_8006BE00:
lwz r3, 0x00001868(rFighterData)
cmplwi r3, 0
beqlr-
regs (3), rAttackerData
lwz rAttackerData, 0x0000002C(r3)
lfs f0, 0x00000084(rAttackerData)
fmadds f1, f1, f3, f0
lfs f0, 0x00000080(rAttackerData)
fmadds f2, f2, f3, f0
blr
CapLaunchSpeeds_8006BE00:
lfs f0, 0xFFFFC928(rtoc)
fcmpo cr0, f0, f2
bgt SetXCap_8006BE00
fneg f0, f0
fcmpo cr0, f2, f0
bgt SetXCap_8006BE00
b StoreXLaunchSpeed_8006BE00
SetXCap_8006BE00:
fmr f2, f0
StoreXLaunchSpeed_8006BE00:

lfs f0, 0xFFFF89C0(rtoc)
fcmpo cr0, f0, f1
bgt SetYCap_8006BE00
lfs f0, 0xFFFFEC44(rtoc)
fcmpo cr0, f1, f0
bgt SetYCap_8006BE00
b StoreYLaunchSpeed_8006BE00
SetYCap_8006BE00:
fmr f1, f0
StoreYLaunchSpeed_8006BE00:

blr
StopPullIn_8006BE00:
li r3, 0
lbz r0, 10688(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 10688(rFighterData)
lfs f1, 0x00000090(rFighterData)
lfs f2, 0x0000008C(rFighterData)
lfs f3, 0xFFFF9584(rtoc)
bl AddAtkMomentum_8006BE00
bl CapLaunchSpeeds_8006BE00
StoreNewSpeeds_8006BE00:
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
Exit_8006BE00:
epilog
OriginalExit_8006BE00:
lwz r12, 0x000021D0(rFighterData)
gecko 2148065488
lwz r3, 0x00001848(r29)
cmpwi r3, 367
bne OriginalExit_8008e0d0
ba r12, 2148065516
OriginalExit_8008e0d0:
lwz r3, 0xFFFFAEB4(r13)
gecko 2147985716
regs (3), rHitStruct, (15), rAttackerData, (25), rDefenderData
cmplwi r0, 367
li r3, 0
bne+ OriginalExit_8007a868
lwz rHitStruct, 0x0000000C(r17)
lfs f0, 0x0000004C(rHitStruct)
stfs f0, 10692(rDefenderData)
lfs f0, 0x00000050(rHitStruct)
stfs f0, 10696(rDefenderData)
lfs f0, 0x00000054(rHitStruct)
stfs f0, 10700(rDefenderData)
lwz r3, 0x000000E0(rDefenderData)
cmpwi r3, 1
beq OriginalExit_8007a868
li r0, 80
li r3, 1
OriginalExit_8007a868:
stw r0, 0x00000004(r31)
lbz r0, 10688(rDefenderData)
rlwimi r0, r3, 4, 16
stb r0, 10688(rDefenderData)
gecko.end
