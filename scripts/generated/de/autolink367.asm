.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.1.0
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147924120
regs (r31), rFighterData
lbz r0, 11228(rFighterData)
rlwinm. r0, r0, 0, 16
beq OriginalExit_8006BE00
prolog xTempCurrentFrame, (0x00000004), xSpeed, (0x00000004)
lbz r0, 0x0000221C(rFighterData)
rlwinm. r0, r0, 31, 31, 31
beq ResetEffect_8006BE00
lwz r0, 0x000018AC(rFighterData)
lwz r3, 11252(rFighterData)
sth r3, sp.xSpeed(sp)
psq_l f0, sp.xSpeed(sp), 1, 5
fres f0, f0
stfs f0, sp.xSpeed(sp)
addi r3, r3, 2
cmpwi r0, 0
blt ResetEffect_8006BE00
cmpw r0, r3
bge ResetEffect_8006BE00
bl CalculateLaunchSpeed_8006BE00
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, 1
beq Exit_8006BE00
LerpSpeedCap_8006BE00:
bl ExceedsYSpeedCap_8006BE00
cmpwi r3, 0
lfs f0, 0x00000090(rFighterData)
beq CheckXLerpCap
bl SetupLerpSpeed_8006BE00
stfs f1, 0x00000090(rFighterData)
CheckXLerpCap:
bl ExceedsXSpeedCap_8006BE00
cmpwi r3, 1
lfs f0, 0x0000008C(rFighterData)
bne Exit_8006BE00
bl SetupLerpSpeed_8006BE00
stfs f1, 0x0000008C(rFighterData)
b Exit_8006BE00
SetupLerpSpeed_8006BE00:
fmr f2, f1
fmr f1, f0
lwz r3, 0x000018AC(rFighterData)
subi r3, r3, 1
sth r3, sp.xTempCurrentFrame(sp)
psq_l f0, sp.xTempCurrentFrame(sp), 1, 5
lfs f3, sp.xSpeed(sp)
fmuls f3, f0, f3
Lerp_8006BE00:
fsubs f0, f2, f1
fmuls f0, f0, f3
fadds f1, f1, f0
blr
CalculateLaunchSpeed_8006BE00:
lwz r3, 0x000018AC(rFighterData)
cmpwi r3, 1
beq Calc
lfs f1, 11248(rFighterData)
lfs f2, 11244(rFighterData)
lbz r0, 11229(rFighterData)
rlwinm. r0, r0, 0, 64
beq CalcStore
li r0, 0
stw r0, 0x00000084(rFighterData)
b CalcStore
Calc:
lfs f0, 11232(rFighterData)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, 11236(rFighterData)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
lfs f3, sp.xSpeed(sp)
lfs f0, 11248(rFighterData)
fmadds f1, f1, f3, f0
lfs f0, 11244(rFighterData)
fmadds f2, f2, f3, f0
CheckSmooth:
lbz r0, 11229(rFighterData)
rlwinm. r0, r0, 0, 64
beq SavePullSpeed
li r0, 0
stw r0, 0x00000084(rFighterData)
lfs f0, 0x0000016C(rFighterData)
fadds f1, f1, f0
SavePullSpeed:
stfs f1, 11248(rFighterData)
stfs f2, 11244(rFighterData)
CalcStore:
stfs f1, 0x00000090(rFighterData)
stfs f2, 0x0000008C(rFighterData)
blr
ExceedsYSpeedCap_8006BE00:
lfs f1, 0x00000090(rFighterData)
lfs f2, 0xFFFFEC44(rtoc)
lfs f3, 0xFFFF89C0(rtoc)
b ExceedsSpeedCap_8006BE00
ExceedsXSpeedCap_8006BE00:
lfs f1, 0x0000008C(rFighterData)
lfs f2, 0xFFFFEC44(rtoc)
fneg f3, f2
ExceedsSpeedCap_8006BE00:
li r3, 0
lbz r0, 11229(rFighterData)
rlwinm. r0, r0, 0, 128
beqlr
fmr f0, f3
fcmpo cr0, f0, f1
bgt ExceedsSpeedCap_True
fmr f0, f2
fcmpo cr0, f1, f0
bgt ExceedsSpeedCap_True
blr
ExceedsSpeedCap_True:
fmr f1, f0
li r3, 1
blr
ResetEffect_8006BE00:
bl ExceedsYSpeedCap_8006BE00
stfs f1, 0x00000090(rFighterData)
bl ExceedsXSpeedCap_8006BE00
stfs f1, 0x0000008C(rFighterData)
li r3, 0
lbz r0, 11228(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 11228(rFighterData)
Exit_8006BE00:
epilog
OriginalExit_8006BE00:
lwz r12, 0x000021A4(rFighterData)
gecko 2148065576
lbz r3, 11228(r29)
rlwinm. r3, r3, 0, 16
beq OrigExit_8008e128
lfs f1, 0xFFFF8870(rtoc)
OrigExit_8008e128:
lwz r3, 0xFFFFAEB4(r13)
gecko 2148064648
regs (29), rData
lwz r3, 0x00001848(rData)
cmpwi r3, 367
bne OrigExit_8007DD88
lwz r3, 0x000000E0(rData)
cmpwi r3, 1
beq EnablePullEffect_8008dd88
li r3, 80
stw r3, 0x00001848(rData)
li r3, 1
EnablePullEffect_8008dd88:
lbz r0, 11228(rData)
rlwimi r0, r3, 4, 16
stb r0, 11228(rData)
OrigExit_8007DD88:
lfd f0, 0x00000058(sp)
gecko 2147985716
stw r0, 0x00000004(r31)
prolog rDefenderData, rAttackerData, rAttackerGObj, rExtHit, rHit, rDmgLog
mr rHit, r3
mr rDefenderData, r25
mr rDmgLog, r31
lwz rHit, 0x0000000C(r17)
lwz rAttackerGObj, 0x00000008(r17)
cmplwi r3, 0
beq OriginalExit_8007a868
lwz rAttackerData, 0x0000002C(rAttackerGObj)
mr r3, rAttackerGObj
mr r4, rHit
bla r12, 2148864212
mr. rExtHit, r3
beq OriginalExit_8007a868
lbz r0, 48(rExtHit)
rlwinm. r3, r0, 0, 64
beq SetDefaultsForAutoLink
lwz r3, 52(rExtHit)
addi r4, rExtHit, 60
addi r5, rDefenderData, 11232
bla r12, 2147529164
lwz r3, 56(rExtHit)
stw r3, 11252(rDefenderData)
lbz r0, 48(rExtHit)
lbz r4, 11229(rDefenderData)
rlwinm r3, r0, 27, 31, 31
rlwimi r4, r3, 7, 128
rlwinm r3, r0, 28, 31, 31
rlwimi r4, r3, 6, 64
stb r4, 11229(rDefenderData)
rlwinm r3, r0, 29, 31, 31
b SetAutoLinkVars
SetDefaultsForAutoLink:
lfs f0, 0x0000004C(rHit)
stfs f0, 11232(rDefenderData)
lfs f0, 0x00000050(rHit)
stfs f0, 11236(rDefenderData)
li r0, 5
stw r0, 11252(rDefenderData)
lbz r0, 11229(rDefenderData)
li r3, 0
rlwimi r0, r3, 6, 64
li r3, 1
rlwimi r0, r3, 7, 128
stb r0, 11229(rDefenderData)
SetAutoLinkVars:
cmplwi r3, 0
beq SetAutoLinkVars_NoAttackerMomentum
lhz r0, 0(rAttackerGObj)
addi r3, rAttackerData, 0x00000080
cmplwi r0, 0x00000004
beq SetAutoLinkVars_AttackerVel
addi r3, rAttackerData, 0x00000040
cmplwi r0, 0x00000006
SetAutoLinkVars_AttackerVel:
psq_l f0, 0(r3), 0, 0
addi r4, rDefenderData, 11244
psq_st f0, 0(r4), 0, 0
b OriginalExit_8007a868
SetAutoLinkVars_NoAttackerMomentum:
li r0, 0
stw r0, 11244(rDefenderData)
stw r0, 11248(rDefenderData)
OriginalExit_8007a868:
li r3, 0
lbz r0, 11228(rDefenderData)
rlwimi r0, r3, 4, 16
stb r0, 11228(rDefenderData)
epilog
gecko.end
