.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.1.0
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
enumb Set, Unk2, LerpAtkMom, LerpSpeedCap, UseVecTargetPos, UseAtkMom, CalcOverrideSpeed, AfterHitlag
enum (0), +4, xVecTargetPosFrame, xVecTargetPosX, xVecTargetPosY, xVecTargetAtkSpeedX, xVecTargetAtkSpeedY, xVecTargetPosFlags
gecko 2148864184
cmpwi r4, 343
beq- CalcAutoLinkSpeed_OriginalExit
lfs f1, 0xFFFF8900(rtoc)
lfs f2, 0xFFFF8900(rtoc)
crnot eq, bUseAtkMom
crandc eq, eq, bUseVecTargetPos
beqlr-
sp.push
sp.temp xTemp, (0x0000000C)
lwz r0, 0(r4)
sth r0, sp.xTemp(sp)
psq_l f0, sp.xTemp(sp), 1, 5
fres f0, f0
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
bf- bCalcOverrideSpeed, 0f
ps_muls0 f2, f2, f0
0:
ps_add f2, f1, f2
ps_merge10 f1, f2, f2
blr
CalcAutoLinkSpeed_OriginalExit:
stw r0, 0x00000004(sp)
gecko 2147924120
regs (r31), rFighterData
lbz r0, 11264(rFighterData)
rlwinm. r0, r0, 0, 16
beq AutoLinkPhysics_OriginalExit
prolog xU, (0x00000002), xL, (0x00000002), xTempFrameInfo, (0x00000004), xTempVec2, (0x00000008)
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
cmplwi r0, 1
beq- AutoLinkPhysics_SetLaunchSpeeds
addi r3, rFighterData, 11268
psq_l f0, 0x00000004(r3), 0, 0
psq_st f0, 0x0000008C(rFighterData), 0, 0
psq_l f1, sp.xTempFrameInfo(sp), 0, 0
bl AutoLinkPhysics_LerpVels
b AutoLinkPhysics_Exit
AutoLinkPhysics_SetLaunchSpeeds:
addi r4, rFighterData, 11268
bt bAfterHitlag, AutoLinkPhysics_SetLaunchSpeeds_Recalc
AutoLinkPhysics_SetLaunchSpeeds_NoCalc:
psq_l f2, 0x0000008C(rFighterData), 0, 0
bf bCalcOverrideSpeed, AutoLinkPhysics_SetLaunchSpeeds_Set
psq_l f2, 0x00000004(r4), 0, 0
b AutoLinkPhysics_SetLaunchSpeeds_Set
AutoLinkPhysics_SetLaunchSpeeds_Recalc:
mr r3, rFighterData
bla r12, 2148864184
bt bCalcOverrideSpeed, AutoLinkPhysics_SetLaunchSpeeds_Set
addi r3, sp, sp.xTempVec2
psq_st f2, 0(r3), 0, 0
bla r12, 2147537840
addi r3, rFighterData, 0x0000008C
bla r12, 2150903292
psq_l f2, sp.xTempVec2(sp), 0, 0
ps_mul f2, f2, f1
b AutoLinkPhysics_SetLaunchSpeeds_Set
AutoLinkPhysics_SetLaunchSpeeds_Set:
psq_st f2, 0x0000008C(rFighterData), 0, 0
psq_st f2, 0x00000004(r4), 0, 0
b AutoLinkPhysics_Exit
AutoLinkPhysics_LerpVels:
ps_muls1 f4, f1, f1
addi r3, rFighterData, 11268
psq_l f1, 0x00000004(r3), 0, 0
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
gecko.end
