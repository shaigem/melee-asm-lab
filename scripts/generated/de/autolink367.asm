.include "punkpc.s"
punkpc ppc
# Special Hitbox Angle: 367 v2.0.1
# authors: @["sushie"]
# description: Pulls victims towards the center of collided hitbox and adjusts launch speed
gecko 2147924120
regs (r31), rFighterData
lbz r0, 10688(rFighterData)
rlwinm. r0, r0, 0, 16
beq OriginalExit_8006BE00
prolog xTempCurrentFrame, (0x00000004), xTempEndFrame, (0x00000004)
lwz r0, 0x000018AC(rFighterData)
cmpwi r0, 0
blt ResetEffect_8006BE00
cmpwi r0, 1
beq OnFrameAfter
cmpwi r0, 7
bge ResetEffect_8006BE00
bl CalculateLaunchSpeed_8006BE00
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
li r3, 5
sth r3, sp.xTempEndFrame(sp)
psq_l f0, sp.xTempCurrentFrame(sp), 1, 5
psq_l f3, sp.xTempEndFrame(sp), 1, 5
fdivs f3, f0, f3
Lerp_8006BE00:
fsubs f0, f2, f1
fmuls f0, f0, f3
fadds f1, f1, f0
blr
OnFrameAfter:
bl CalculateLaunchSpeed_8006BE00
b Exit_8006BE00
CalculateLaunchSpeed_8006BE00:
lfs f0, 10692(rFighterData)
lfs f2, 0x000000B0(rFighterData)
fsubs f2, f0, f2
lfs f0, 10696(rFighterData)
lfs f1, 0x000000B4(rFighterData)
fsubs f1, f0, f1
lfs f3, 0xFFFF87B4(rtoc)
lfs f0, 10708(rFighterData)
fmadds f1, f1, f3, f0
lfs f0, 10704(rFighterData)
fmadds f2, f2, f3, f0
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
fmr f0, f3
li r3, 0
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
li r3, 0
lbz r0, 10688(rFighterData)
rlwimi r0, r3, 4, 16
stb r0, 10688(rFighterData)
Exit_8006BE00:
epilog
OriginalExit_8006BE00:
lwz r12, 0x000021A4(rFighterData)
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
lbz r0, 10688(rData)
rlwimi r0, r3, 4, 16
stb r0, 10688(rData)
OrigExit_8007DD88:
lfd f0, 0x00000058(sp)
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
lfs f0, 0x00000080(rAttackerData)
stfs f0, 10704(rDefenderData)
lfs f0, 0x00000084(rAttackerData)
stfs f0, 10708(rDefenderData)
OriginalExit_8007a868:
stw r0, 0x00000004(r31)
lbz r0, 10688(rDefenderData)
rlwimi r0, r3, 4, 16
stb r0, 10688(rDefenderData)
gecko.end
