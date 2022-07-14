.include "punkpc.s"
punkpc ppc
# sushie's Common ExtHit Functions
# authors: @["sushie"]
# description: 
gecko 2147915552
stfs f0, 0x000018B4(r26)
stb r29, 11265(r26)
gecko.end
gecko 2147909156
stfs f1, 0x000018B4(r27)
stb r28, 11265(r27)
gecko.end
gecko 2148864228
cmpwi r4, 343
beq- InitDefaultExtHit_OrigExit
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 12(r3)
li r0, 0
stw r0, 20(r3)
stw r0, 24(r3)
stw r0, 28(r3)
stw r0, 44(r3)
stw r0, 48(r3)
stw r0, 16(r3)
stw r0, 52(r3)
stw r0, 56(r3)
stw r0, 60(r3)
stw r0, 64(r3)
stw r0, 68(r3)
stw r0, 72(r3)
blr
InitDefaultExtHit_OrigExit:
lfs f2, 0xFFFFA4C4(rtoc)
gecko.end
gecko 2148864212
cmpwi r4, 343
beq- GetExtHit_OrigExit
cmplwi r3, 0
beq GetExtHit_Invalid
cmplwi r4, 0
beq GetExtHit_Invalid
stwu sp, 0xFFFFFFE8(sp)
li r0, 4
stw r0, 0x00000014(sp)
li r0, 4
mtctr r0
lhz r0, 0(r3)
lwz r3, 0x0000002C(r3)
cmplwi r0, 4
beq GetExtHit_Fighter
cmplwi r0, 6
beq GetExtHit_Item
b GetExtHit_Invalid
GetExtHit_Item:
addi r5, r3, 4404
stw r5, 0x00000010(sp)
addi r5, r3, 1492
addi r3, r3, 4048
li r0, 316
b GetExtHit
GetExtHit_Fighter:
addi r5, r3, 9692
stw r5, 0x00000010(sp)
addi r5, r3, 2324
addi r3, r3, 9248
li r0, 312
GetExtHit:
b GetExtHit_Comparison
GetExtHit_Loop:
add r5, r5, r0
addi r3, r3, 84
GetExtHit_Comparison:
cmplw r5, r4
bdnzf eq, GetExtHit_Loop
beq GetExtHit_Exit
lwz r5, 0x00000014(sp)
cmplwi r5, 0
beq GetExtHit_Invalid
mtctr r5
li r5, 0
stw r5, 0x00000014(sp)
lwz r5, 0x00000010(sp)
b GetExtHit_Loop
GetExtHit_Invalid:
li r3, 0
GetExtHit_Exit:
addi sp, sp, 0x00000018
blr
GetExtHit_OrigExit:
lwz r31, 0x0000002C(r3)
gecko.end
gecko 2147947144
mulli r3, r0, 84
addi r3, r3, 9248
add r3, r31, r3
bla r12, 2148864228
lwz r0, 0(r30)
gecko.end
gecko 2148864220
cmpwi r4, 343
beq- OnKnockback_OriginalExit
cmplwi r3, 0
beqlr-
prolog rSrcData, rDefData, rHit, rExtHit, rSrcGObj, rDefGObj
enumb SourceFighter, DefenderFighter
lwz rSrcData, 0x0000002C(r3)
lwz rDefData, 0x0000002C(r4)
mr rHit, r5
mr rSrcGObj, r3
mr rDefGObj, r4
cmplwi r6, 0
mr rExtHit, r6
bne- OnKnockback_DetermineEntityType
mr r3, rSrcGObj
mr r4, rHit
bla r12, 2148864212
cmplwi r3, 0
beq- OnKnockback_Epilog
mr rExtHit, r3
OnKnockback_DetermineEntityType:
lhz r0, 0(rSrcGObj)
cmplwi cr0, r0, 0x00000004
crmove bSourceFighter, eq
lhz r0, 0(rDefGObj)
cmplwi cr0, r0, 0x00000004
crmove bDefenderFighter, eq
OnKnockback_StoreHitlag:
OnKnockback_StoreHitlag_GetMultiOff:
addi r3, rSrcData, 0x00001960
bt+ bSourceFighter, 0f
addi r3, rSrcData, 5984
0:
addi r4, rDefData, 0x00001960
bt+ bDefenderFighter, OnKnockback_StoreHitlag_CheckDisable
addi r4, rDefData, 5984
OnKnockback_StoreHitlag_CheckDisable:
lbz r0, 16(rExtHit)
rlwinm. r5, r0, 28, 0x00000001
beq+ OnKnockback_StoreHitlag_Store
lfs f0, 0xFFFFCC58(rtoc)
bf bSourceFighter, 0f
lbz r0, 11264(rSrcData)
rlwimi r0, r5, 5, 32
stb r0, 11264(rSrcData)
b OnKnockback_StoreHitlag_CheckDisable_Defender
0:
stfs f0, 0(r3)
OnKnockback_StoreHitlag_CheckDisable_Defender:
bf bDefenderFighter, OnKnockback_StoreHitlag_Store_Defender
lbz r0, 11264(rDefData)
rlwimi r0, r5, 5, 32
stb r0, 11264(rDefData)
b OnKnockback_DefFighters
OnKnockback_StoreHitlag_Store:
lfs f0, 0(rExtHit)
stfs f0, 0(r3)
lwz r0, 0x00000030(rHit)
cmplwi r0, 2
bne+ OnKnockback_StoreHitlag_Store_Defender
lwz r3, 0xFFFFAEB4(r13)
lfs f1, 0x000001A4(r3)
fmuls f0, f1, f0
OnKnockback_StoreHitlag_Store_Defender:
stfs f0, 0(r4)
OnKnockback_DefFighters:
bf bDefenderFighter, OnKnockback_Epilog
OnKnockback_StoreHitstunModifier:
lfs f0, 12(rExtHit)
stfs f0, 11256(rDefData)
OnKnockback_StoreSDIMultiplier:
lfs f0, 4(rExtHit)
stfs f0, 11252(rDefData)
OnKnockback_StoreFacingRestrict:
lfs f0, 0x0000002C(rSrcData)
lbz r0, 16(rExtHit)
rlwinm. r3, r0, 0, 25, 25
bne- OnKnockback_StoreFacingRestrict_Store
rlwinm. r3, r0, 0, 26, 26
beq+ OnKnockback_StoreAutoLink
OnKnockback_StoreFacingRestrict_F:
fneg f0, f0
OnKnockback_StoreFacingRestrict_Store:
stfs f0, 0x00001844(rDefData)
OnKnockback_StoreAutoLink:
enumb.restart
enumb Set, Unk2, LerpAtkMom, LerpSpeedCap, UseVecTargetPos, UseAtkMom, CalcOverrideSpeed, AfterHitlag
li r0, 0
mtcrf 0x00000003, r0
lbz r0, 72(rExtHit)
mtcrf 0x00000003, r0
bf- bSet, OnKnockback_StoreAutoLink_CheckAngle
lwz r3, 52(rExtHit)
addi r4, rExtHit, 60
addi r5, rDefData, 11272
bla r12, 2147529164
lwz r0, 56(rExtHit)
stw r0, 11268(rDefData)
b OnKnockback_StoreAutoLink_IsAutoLink
OnKnockback_StoreAutoLink_CheckAngle:
addi r3, rDefData, 11268
lwz r0, 0x00001848(rDefData)
cmplwi r0, 363
beq OnKnockback_StoreAutoLink_Vec_Speed
cmplwi r0, 365
beq OnKnockback_StoreAutoLink_Vec_Sync
cmplwi r0, 366
beq OnKnockback_StoreAutoLink_Vec_Pull_Reaction
cmplwi r0, 367
beq OnKnockback_StoreAutoLink_Vec_Pull
b OnKnockback_StoreAutoLink_Exit
OnKnockback_StoreAutoLink_Vec_Speed:
crset bUseAtkMom
lfs f0, 0xFFFF8900(rtoc)
psq_st f0, 0x00000004(r3), 0, 0
li r0, 1
stw r0, 0(r3)
b OnKnockback_StoreAutoLink_IsAutoLink
OnKnockback_StoreAutoLink_Vec_Sync:
crset bUseAtkMom
crset bCalcOverrideSpeed
lfs f0, 0xFFFF8900(rtoc)
psq_st f0, 0x00000004(r3), 0, 0
li r0, 2
stw r0, 0(r3)
b OnKnockback_StoreAutoLink_IsAutoLink
OnKnockback_StoreAutoLink_Vec_Pull_Reaction:
crset bLerpAtkMom
crset bUseVecTargetPos
crset bUseAtkMom
crset bAfterHitlag
psq_l f0, 0x0000004C(rHit), 0, 0
psq_st f0, 0x00000004(r3), 0, 0
li r0, 5
stw r0, 0(r3)
b OnKnockback_StoreAutoLink_IsAutoLink
OnKnockback_StoreAutoLink_Vec_Pull:
crset bLerpSpeedCap
crset bUseVecTargetPos
crset bUseAtkMom
crset bCalcOverrideSpeed
crset bAfterHitlag
psq_l f0, 0x0000004C(rHit), 0, 0
psq_st f0, 0x00000004(r3), 0, 0
li r0, 10
stw r0, 0(r3)
OnKnockback_StoreAutoLink_IsAutoLink:
mr r3, rDefData
addi r4, rDefData, 11268
cror eq, bLerpAtkMom, bUseAtkMom
lfs f0, 0xFFFF8900(rtoc)
bne OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom
lhz r0, 0(rSrcGObj)
cmplwi r0, 0x00000004
psq_l f0, 0x00000080(rSrcData), 0, 0
beq OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom
cmplwi r0, 0x00000006
psq_l f0, 0x00000040(rSrcData), 0, 0
OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom:
psq_st f0, 0x0000000C(r4), 0, 0
bla r12, 2148864184
crandc eq, bCalcOverrideSpeed, bAfterHitlag
bf eq, OnKnockback_StoreAutoLink_IsAutoLink_CalcAngle
psq_st f2, 0x00000004(r4), 0, 0
OnKnockback_StoreAutoLink_IsAutoLink_CalcAngle:
sp.push
sp.temp xTemp, (0x0000000C)
lfs f0, 0xFFFF8900(rtoc)
lfs f3, 0x00001844(rDefData)
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
stw r0, 0x00001848(rDefData)
sp.pop
cror eq, bLerpAtkMom, bLerpSpeedCap
crnot lt, bCalcOverrideSpeed
crandc eq, lt, eq
crandc eq, eq, bAfterHitlag
bt- eq, 0f
crset bSet
b OnKnockback_StoreAutoLink_Exit
0:
crclr bSet
OnKnockback_StoreAutoLink_Exit:
li r3, 0
lbz r0, 11264(rDefData)
rlwimi r0, r3, 4, 16
stb r0, 11264(rDefData)
mfcr r0
stb r0, 11288(rDefData)
OnKnockback_HandleSetWeight:
lbz r0, 16(rExtHit)
rlwinm. r3, r0, 25, 0x00000001
bne OnKnockback_HandleSetWeight_SetTempVars
OnKnockback_HandleSetWeight_Reset:
lbz r0, 11264(rDefData)
rlwinm. r0, r0, 0, 2
beq- OnKnockback_StoreDisableMeteorCancel
mr r3, rDefData
bla r12, 2148864232
b OnKnockback_StoreDisableMeteorCancel
OnKnockback_HandleSetWeight_SetTempVars:
lbz r0, 11264(rDefData)
rlwimi r0, r3, 1, 2
stb r0, 11264(rDefData)
data.start
0:
.float 0.095
1:
.float 1.7
data.struct 0, "sw.", xGravity, xFallSpeed
data.end r3
addi r4, rDefData, 0x00000110
psq_l f0, sw.xGravity(r3), 0, 0
psq_st f0, 0x0000005C(r4), 0, 0
OnKnockback_StoreDisableMeteorCancel:
lbz r0, 16(rExtHit)
rlwinm r3, r0, 30, 0x00000001
lbz r0, 11264(rDefData)
rlwimi r0, r3, 2, 4
stb r0, 11264(rDefData)
OnKnockback_StoreNoHitstunLandCancel:
lbz r0, 44(rExtHit)
rlwinm r3, r0, 25, 0x00000001
lbz r0, 11264(rDefData)
rlwimi r0, r3, 6, 64
stb r0, 11264(rDefData)
OnKnockback_Epilog:
epilog
OnKnockback_Epilog_Return:
blr
OnKnockback_OriginalExit:
lwz r5, 0x0000010C(r31)
gecko.end
