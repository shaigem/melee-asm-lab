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
prolog
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, -1
beq StopPullIn_8006BE00
cmpwi r0, 5
bge StopPullIn_8006BE00
bl Data
mflr r5
lfs f1, 0x00000008(r5)
lfs f2, 0x0000000C(r5)
lfs f3, 0x00000004(r5)
lfs f5, 0(r5)
addi r3, rFighterData, 0x000000B0
addi r4, rFighterData, 10692
addi r5, rFighterData, 0x0000008C
bl SmoothDamp
lfs f3, 0xFFFF9584(rtoc)
lfs f1, 0x00000090(rFighterData)
lfs f2, 0x0000008C(rFighterData)
bl AddAtkMomentum_8006BE00
b StoreNewSpeeds_8006BE00
SmoothDamp:
mflr r0
stw r0, 4(r1)
stwu r1, 0xFFFFFF78(r1)
stfd f31, 0x00000080(r1)
stfd f30, 0x00000078(r1)
stfd f29, 0x00000070(r1)
stfd f28, 0x00000068(r1)
stfd f27, 0x00000060(r1)
fmuls f27, f2, f1
stw r31, 0x0000005C(r1)
mr r31, r5
stw r30, 0x00000058(r1)
addi r30, r4, 0
stw r29, 0x00000054(r1)
addi r29, r3, 0
lfs f0, 0xFFFF809C(rtoc)
lfs f8, 0xFFFF8870(rtoc)
fdivs f31, f0, f1
lfs f2, 4(r3)
lfs f1, 4(r4)
fmuls f9, f31, f8
lfs f4, 0(r3)
fsubs f28, f2, f1
lwz r3, 0(r4)
lwz r0, 4(r4)
fmuls f7, f3, f9
lfs f3, 0(r4)
fmuls f6, f5, f9
fadds f5, f8, f9
stw r3, 0x00000038(r1)
fmuls f7, f7, f9
stw r0, 0x0000003C(r1)
fmadds f5, f6, f9, f5
lwz r0, 8(r4)
fsubs f29, f4, f3
fmadds f2, f9, f7, f5
stw r0, 0x00000040(r1)
fmuls f1, f28, f28
fmuls f0, f27, f27
fdivs f30, f8, f2
fmadds f1, f29, f29, f1
fcmpo cr0, f1, f0
ble SmoothDamp_e4
stfs f29, 0x00000020(sp)
stfs f28, 0x00000024(sp)
li r0, 0
stw r0, 0x00000028(sp)
addi r3, sp, 0x00000020
bla r12, 2150903292
fdivs f0, f29, f1
fmuls f29, f27, f0
fdivs f0, f28, f1
fmuls f28, f27, f0
SmoothDamp_e4:
lfs f0, 0(r29)
fsubs f0, f0, f29
stfs f0, 0(r30)
lfs f0, 4(r29)
fsubs f0, f0, f28
stfs f0, 4(r30)
lfs f2, 0(r31)
lfs f0, 4(r31)
fmadds f1, f31, f29, f2
lfs f6, 0xFFFF8870(rtoc)
fmadds f0, f31, f28, f0
fmuls f3, f6, f1
fmuls f4, f6, f0
fnmsubs f0, f31, f3, f2
fadds f1, f28, f4
fadds f3, f29, f3
fmuls f0, f30, f0
stfs f0, 0(r31)
lfs f0, 4(r31)
fnmsubs f0, f31, f4, f0
fmuls f0, f30, f0
stfs f0, 4(r31)
lfs f0, 4(r30)
lfs f2, 0(r30)
fmadds f0, f30, f1, f0
lfs f7, 0x0000003C(r1)
lfs f1, 4(r29)
fmadds f3, f30, f3, f2
lfs f5, 0x00000038(r1)
lfs f4, 0(r29)
fsubs f2, f7, f1
fsubs f1, f0, f7
lfs f0, 0xFFFF8900(rtoc)
fsubs f4, f5, f4
fsubs f3, f3, f5
fmuls f1, f2, f1
fmadds f1, f4, f3, f1
fcmpo cr0, f1, f0
ble SmoothDamp_Epilog
fsubs f1, f5, f5
fsubs f0, f7, f7
fdivs f1, f1, f6
fdivs f0, f0, f6
stfs f1, 0(r31)
stfs f0, 4(r31)
SmoothDamp_Epilog:
lwz r0, 0x0000008C(r1)
lfd f31, 0x00000080(r1)
lfd f30, 0x00000078(r1)
lfd f29, 0x00000070(r1)
lfd f28, 0x00000068(r1)
lfd f27, 0x00000060(r1)
lwz r31, 0x0000005C(r1)
lwz r30, 0x00000058(r1)
lwz r29, 0x00000054(r1)
addi r1, r1, 0x00000088
mtlr r0
blr
Data:
blrl
.float 0.48
.float 0.235
.float 0.2
.float 100
AddAtkMomentum_8006BE00:
lwz r3, 0x00001868(rFighterData)
cmplwi r3, 0
beqlr-
regs (3), rAttackerData
lwz rAttackerData, 0x0000002C(r3)
cmplwi rAttackerData, 0
beqlr-
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
