.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.1.0
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
enumb Set, Unk2, LerpAtkMom, LerpSpeedCap, UseVecTargetPos, UseAtkMom, CalcOverrideSpeed, AfterHitlag
enum (0), +4, xVecTargetPosFrame, xVecTargetPosX, xVecTargetPosY, xVecTargetAtkSpeedX, xVecTargetAtkSpeedY, xVecTargetPosFlags
gecko 2147924120
regs (r31), rFighterData
lbz r0, 11264(rFighterData)
rlwinm. r0, r0, 0, 16
beq AutoLinkPhysics_OriginalExit
prolog xU, (0x00000002), xL, (0x00000002), xTempFrameInfo, (0x00000004)
lbz r0, 11288(rFighterData)
mtcrf 0x00000003, r0
lwz r3, 0x000018AC(rFighterData)
subi r3, r3, 1
sth r3, sp.xU(sp)
lwz r3, 11268(rFighterData)
sth r3, sp.xL(sp)
psq_l f0, sp.xU(sp), 0, 5
ps_res f1, f0
ps_merge01 f0, f0, f1
psq_st f0, sp.xTempFrameInfo(sp), 0, 0
lbz r0, 0x0000221C(rFighterData)
rlwinm. r0, r0, 31, 31, 31
beq AutoLinkPhysics_ResetEffect
lwz r0, 0x000018AC(rFighterData)
lwz r3, 11268(rFighterData)
addi r3, r3, 2
cmpwi r0, 0
blt AutoLinkPhysics_ResetEffect
cmpw r0, r3
bge AutoLinkPhysics_ResetEffect_TurnOff
lwz r0, 0x000018AC(rFighterData)
cmplwi r0, 1
beq AutoLinkPhysics_Exit
psq_l f1, sp.xTempFrameInfo(sp), 0, 0
bl AutoLinkPhysics_LerpVels
b AutoLinkPhysics_Exit
AutoLinkPhysics_LerpVels:
ps_muls1 f4, f1, f1
psq_l f1, 0x0000008C(rFighterData), 0, 0
bt bLerpSpeedCap, AutoLinkPhysics_LerpVels_Speed
bt bLerpAtkMom, AutoLinkPhysics_LerpVels_AtkMom
blr
AutoLinkPhysics_LerpVels_Speed:
lfs f2, 0xFFFFEC44(rtoc)
lfs f3, 0xFFFF8870(rtoc)
ps_merge01 f3, f2, f3
ps_neg f3, f3
ps_sub f0, f1, f2
ps_sel f2, f0, f2, f1
ps_sub f0, f1, f3
ps_sel f2, f0, f2, f3
fmr f3, f4
b AutoLinkPhysics_Lerp
AutoLinkPhysics_LerpVels_AtkMom:
addi r3, rFighterData, 11268
psq_l f2, 0x0000000C(r3), 0, 0
fmr f3, f4
b AutoLinkPhysics_Lerp
AutoLinkPhysics_Lerp:
ps_sub f0, f2, f1
ps_madds0 f0, f0, f3, f1
psq_st f0, 0x0000008C(rFighterData), 0, 0
lfs f2, 0xFFFF8950(rtoc)
lfs f1, 0x000000F0(rFighterData)
fcmpu cr0, f2, f1
beqlr-
stfs f0, 0x000000F0(rFighterData)
blr
AutoLinkPhysics_ResetEffect:
lfs f1, 0xFFFF8870(rtoc)
bl AutoLinkPhysics_LerpVels
AutoLinkPhysics_ResetEffect_TurnOff:
li r3, 0
lbz r0, 11264(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 11264(rFighterData)
AutoLinkPhysics_Exit:
epilog
AutoLinkPhysics_OriginalExit:
lwz r12, 0x000021A4(rFighterData)
gecko 2148064648
regs (29), rData
lbz r3, 11288(rData)
mtcrf 0x00000003, r3
bf+ bSet, OrigExit_8007DD88
li r3, 1
EnablePullEffect_8008dd88:
crclr bSet
mfcr r0
stb r0, 11288(rData)
lbz r0, 11264(rData)
rlwimi r0, r3, 4, 16
stb r0, 11264(rData)
OrigExit_8007DD88:
lfd f0, 0x00000058(sp)
gecko 2147985716
stw r0, 0x00000004(r31)
prolog rDmgLog, rAttackerData, rAttackerGObj, rExtHit, rHit, xTemp, (0x0000000C)
regs (17), rDmgSrc, (25), rDefenderData
lwz rHit, 0x0000000C(rDmgSrc)
lwz rAttackerGObj, 0x00000008(rDmgSrc)
li r0, 0
mtcrf 0x00000003, r0
cmplwi rAttackerGObj, 0
beq SetAutoLinkVars_CheckAngle
lwz rAttackerData, 0x0000002C(rAttackerGObj)
mr r3, rAttackerGObj
mr r4, rHit
bla r12, 2148864212
mr rExtHit, r3
cmplwi r3, 0
beq SetAutoLinkVars_CheckAngle
lbz r0, 72(rExtHit)
mtcrf 0x00000003, r0
bf- bSet, SetAutoLinkVars_CheckAngle
SetAutoLinkVars_CustomVecTargetPos:
lwz r3, 52(rExtHit)
addi r4, rExtHit, 60
addi r5, rDefenderData, 11272
bla r12, 2147529164
lwz r0, 56(rExtHit)
stw r0, 11268(rDefenderData)
b SetAutoLinkVars_IsAutoLink
SetAutoLinkVars_CheckAngle:
nop
SetAutoLinkVars_IsAutoLink:
mr r3, rDefenderData
addi r4, rDefenderData, 11268
psq_l f0, 0x00000080(rAttackerData), 0, 0
psq_st f0, 0x0000000C(r4), 0, 0
bl CalculateAutoLinkLaunchSpeed
crandc eq, bCalcOverrideSpeed, bAfterHitlag
bf eq, SetAutoLinkVars_IsAutoLink_CalcAngle
psq_st f2, 0x00000004(r4), 0, 0
SetAutoLinkVars_IsAutoLink_CalcAngle:
lfs f0, 0xFFFF8900(rtoc)
lfs f3, 0(rDmgLog)
fcmpo cr0, f3, f0
bt lt, 0f
fneg f2, f2
0:

bla r12, 2147626032
lfs f0, 0xFFFF893C(rtoc)
fmuls f1, f0, f1
fctiw f0, f1
stfd f0, sp.xTemp(sp)
lwz r0, sp.xTemp + 0x00000004(sp)
stw r0, 0x00000004(rDmgLog)
cror eq, bLerpAtkMom, bLerpSpeedCap
crnot lt, bCalcOverrideSpeed
crandc eq, lt, eq
bt- eq, 0f
crset bSet
b SetAutoLinkVars_Exit
0:
crclr bSet
b SetAutoLinkVars_Exit
CalculateAutoLinkLaunchSpeed:
sp.push
sp.temp xTemp, (0x0000000C)
lwz r0, 0(r4)
sth r0, sp.xTemp(sp)
psq_l f0, sp.xTemp(sp), 1, 5
fres f0, f0
lfs f1, 0xFFFF8900(rtoc)
sp.pop
bf bUseAtkMom, CalculateAutoLinkLaunchSpeed_TargetPos
CalculateAutoLinkLaunchSpeed_AtkMom:
psq_l f1, 0x0000000C(r4), 0, 0
bt bUseVecTargetPos, CalculateAutoLinkLaunchSpeed_TargetPos
ps_muls0 f2, f1, f0
ps_merge10 f1, f2, f2
blr
CalculateAutoLinkLaunchSpeed_TargetPos:
psq_l f2, 0x00000004(r4), 0, 0
psq_l f3, 0x000000B0(r3), 0, 0
ps_sub f2, f2, f3
ps_muls0 f2, f2, f0
ps_add f2, f1, f2
ps_merge10 f1, f2, f2
blr
SetAutoLinkVars_Exit:
mfcr r0
stb r0, 11288(rDefenderData)
epilog
gecko.end
