.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.1.0
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147925504
regs (r31), rFighterData
lbz r0, 10976(rFighterData)
rlwinm. r0, r0, 0, 16
beq OriginalExit_8006BE00
prolog xTemp, xTempPosX, (0x00000004), xTempPosY, (0x00000004), xTempPosZ, (0x00000004)
lbz r3, 0x0000221C(rFighterData)
rlwinm. r0, r3, 31, 31, 31
li r3, 0
beq StopPullIn_8006BE00
li r3, 1
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, 0
ble Exit_8006BE00
cmpwi r0, 6
bgt StopPullIn_8006BE00
mr r5, r0
subi r0, r5, 1
sth r0, sp.xTemp(sp)
bl Data
mflr r5
lwz r3, 10992(rFighterData)
cmplwi r3, 0
bgt AutoVecPull
lwz r6, 10996(rFighterData)
cmplwi r6, 0
beq StopPullIn_8006BE00
AutoVecPullPos:
lwz r3, 20(r6)
addi r4, r6, 24
addi r5, sp, sp.xTempPosX
bla r12, 2147529164
lfs f0, sp.xTempPosX(sp)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, sp.xTempPosY(sp)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
lwz r6, 10996(rFighterData)
lfs f3, 40(r6)
b AddAtkLol
AutoVecPull:
lfs f0, 0x0000004C(r3)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, 0x00000050(r3)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
lfs f3, 0x00000008(r5)
AddAtkLol:
li r3, 0
bl AddAtkMomentum_8006BE00
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
b Exit_8006BE00
Lerp:
fsubs f0, f2, f1
fmuls f0, f0, f3
fadds f1, f1, f0
blr
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
.float 4
AddAtkMomentum_8006BE00:
lwz r4, 0x00001868(rFighterData)
cmplwi r4, 0
beqlr-
regs (4), rAttackerData
lwz rAttackerData, 0x0000002C(r4)
cmplwi rAttackerData, 0
beqlr-
cmplwi r3, 1
beq SetAtkMomentum_8006BE00
lfs f0, 0x00000084(rAttackerData)
fmadds f1, f1, f3, f0
lfs f0, 0x00000080(rAttackerData)
fmadds f2, f2, f3, f0
blr
SetAtkMomentum_8006BE00:
lfs f1, 0x00000084(rAttackerData)
lfs f2, 0x00000080(rAttackerData)
blr
CapGroundSpeed_8006BE00:
lfs f0, 0xFFFFC928(rtoc)
fcmpo cr0, f0, f3
bgt SetGroundCap_8006BE00
fneg f0, f0
fcmpo cr0, f3, f0
bgt SetGroundCap_8006BE00
b StoreGroundLaunchSpeed_8006BE00
SetGroundCap_8006BE00:
fmr f3, f0
StoreGroundLaunchSpeed_8006BE00:
stfs f3, 0x000000F0(rFighterData)
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
lfs f1, 0x00000090(rFighterData)
lfs f2, 0x0000008C(rFighterData)
lfs f3, 0xFFFF9584(rtoc)
cmpwi r3, 0
beq StopPullInCap_8006BE00
StopPullInCap_8006BE00:
bl CapLaunchSpeeds_8006BE00
li r3, 0
lbz r0, 10976(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 10976(rFighterData)
StoreNewSpeeds_8006BE00:
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
Exit_8006BE00:
epilog
OriginalExit_8006BE00:
lwz r12, 0x000021D0(rFighterData)
gecko 2148064648
regs (29), rData
lwz r3, 0x00001848(rData)
cmpwi r3, 367
blt OrigExit_8007DD88
cmpwi r3, 368
bgt OrigExit_8007DD88
lwz r3, 0x000000E0(rData)
cmpwi r3, 1
beq EnablePullEffect_8008dd88
li r3, 80
stw r3, 0x00001848(rData)
li r3, 1
EnablePullEffect_8008dd88:
lbz r0, 10976(rData)
rlwimi r0, r3, 4, 16
stb r0, 10976(rData)
OrigExit_8007DD88:
lfd f0, 0x00000058(sp)
gecko.end
