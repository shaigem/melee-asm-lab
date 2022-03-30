.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.1.0
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147924120
regs (r31), rFighterData
lbz r0, 11048(rFighterData)
rlwinm. r0, r0, 0, 16
beq OriginalExit_8006BE00
prolog xTemp, (0x00000004), xTempFrame, (0x00000004), xTempPosX, (0x00000004), xTempPosY, (0x00000004), xTempPosZ, (0x00000004)
lbz r3, 0x0000221C(rFighterData)
rlwinm. r0, r3, 31, 31, 31
li r3, 0
beq StopPullIn_8006BE00
li r3, 1
lwz r0, 0x000018AC(rFighterData)
lwz r5, 11072(rFighterData)
cmpwi r0, 0
ble Exit_8006BE00
cmpw r0, r5
bgt StopPullIn_8006BE00
Hihi:
sth r5, sp.xTempFrame(sp)
mr r5, r0
subi r0, r5, 1
sth r0, sp.xTemp(sp)
bl Data
mflr r5
lwz r3, 11064(rFighterData)
cmplwi r3, 0
bgt AutoVecPull
lwz r6, 11068(rFighterData)
cmplwi r6, 0
beq StopPullIn_8006BE00
AutoVecPullPos:
lfs f0, 11052(rFighterData)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, 11056(rFighterData)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
stfs f2, sp.xTempPosX(sp)
stfs f1, sp.xTempPosY(sp)
li r0, 0
stw r0, sp.xTempPosZ(sp)
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, 1
beq CalcDist
b DoStuff
CalcDist:
addi r3, sp, sp.xTempPosX
bla r12, 2150903292
psq_l f0, sp.xTempFrame(sp), 1, 5
fdivs f1, f1, f0
stfs f1, 11076(rFighterData)
addi r3, sp, sp.xTempPosX
bla r12, 2147537644
lfs f0, 11076(rFighterData)
lfs f1, sp.xTempPosX(sp)
fmuls f1, f0, f1
stfs f1, 11080(rFighterData)
bl Data
mflr r5
lfs f2, 0x0000016C(rFighterData)
lfs f3, 0x00000014(r5)
fsubs f2, f2, f3
lfs f3, 0x00000018(r5)
fmuls f2, f2, f3
lfs f1, sp.xTempPosY(sp)
fmuls f1, f0, f1
fadds f1, f1, f2
stfs f1, 0x00000090(rFighterData)
stfs f1, 11084(rFighterData)
DoStuff:
lwz r3, 0(rFighterData)
addi r4, rFighterData, 11052
lfs f1, 11076(rFighterData)
bl MoveTowardsPoint
lfs f3, 0xFFFF9584(rtoc)
li r3, 0
bl AddAtkMomentum_8006BE00
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
b Exit_8006BE00
AutoVecPull:
lfs f0, 11052(rFighterData)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, 11056(rFighterData)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
lfs f3, 0x00000008(r5)
AddAtkLol:
li r3, 0
bl AddAtkMomentum_8006BE00
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
LerpSpeed:
lfs f1, 0x00000090(rFighterData)
lfs f2, 0x0000008C(rFighterData)
psq_l f0, sp.xTemp(sp), 1, 5
psq_l f3, sp.xTempFrame(sp), 1, 5
fdivs f3, f0, f3
lfs f4, 0xFFFFC928(rtoc)
fmr f1, f2
lfs f0, 0xFFFFC928(rtoc)
fcmpo cr0, f0, f1
bgt Balal
fneg f0, f0
fcmpo cr0, f1, f0
bgt Balal
b StoreTest
Balal:
fmr f2, f0
CallLerp:
bl Lerp
StoreTest:
stfs f1, 0x0000008C(rFighterData)
lfs f1, 0x00000090(rFighterData)
lfs f0, 0xFFFF89C0(rtoc)
fcmpo cr0, f0, f1
bgt Balal2
lfs f0, 0xFFFFEC44(rtoc)
fcmpo cr0, f1, f0
bgt Balal2
b StoreTest2
Balal2:
fmr f2, f0
CallLerp2:
bl Lerp
StoreTest2:
stfs f1, 0x00000090(rFighterData)
b Exit_8006BE00
MoveTowardsPoint:
mflr r0
stw r0, 4(r1)
stwu r1, 0xFFFFFFA8(r1)
stfd f31, 0x00000050(r1)
fmr f31, f2
stfd f30, 0x00000048(r1)
fmr f30, f1
stfd f29, 0x00000040(r1)
stw r31, 0x0000003C(r1)
stw r30, 0x00000038(r1)
addi r5, r1, 0x0000002C
lwz r31, 0x0000002C(r3)
addi r3, r4, 0
addi r4, r31, 0x000000B0
bla r12, 2147538168
addi r3, sp, 0x0000002C
bla r12, 2150903292
fmr f29, f1
lbl_8015BEF8:
fcmpo cr0, f29, f30
bge lbl_8015BF0C
b MoveTowardsPointEpilog
lbl_8015BF0C:
lfs f1, 11080(rFighterData)
stfs f1, 0x0000002C(sp)
lfs f1, 11084(rFighterData)
stfs f1, 0x00000030(r1)
MoveTowardsPointEpilog:
lfs f2, 0x0000002C(r1)
lfs f1, 0x00000030(r1)
lwz r0, 0x0000005C(r1)
lfd f31, 0x00000050(r1)
lfd f30, 0x00000048(r1)
lfd f29, 0x00000040(r1)
lwz r31, 0x0000003C(r1)
lwz r30, 0x00000038(r1)
addi r1, r1, 0x00000058
mtlr r0
blr
Lerp:
fsubs f0, f2, f1
fmuls f0, f0, f3
fadds f1, f1, f0
blr
Data:
blrl
.float 1
.float 0.235
.float 0.2
.float 100
.float 4
.float 0.095
.float 5
AddAtkMomentum_8006BE00:
lbz r4, 11048(rFighterData)
rlwinm. r4, r4, 0, 32
bne MultiplySpeed_8006BE00
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
MultiplySpeed_8006BE00:
fmuls f1, f1, f3
fmuls f2, f2, f3
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
lbz r0, 11048(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 11048(rFighterData)
StoreNewSpeeds_8006BE00:
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
Exit_8006BE00:
epilog
OriginalExit_8006BE00:
lwz r12, 0x000021A4(rFighterData)
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
lbz r0, 11048(rData)
rlwimi r0, r3, 4, 16
stb r0, 11048(rData)
OrigExit_8007DD88:
lfd f0, 0x00000058(sp)
gecko.end
