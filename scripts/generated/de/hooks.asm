.include "punkpc.s"
punkpc ppc
# hooks
# authors: @["sushie"]
# description: 
gecko 2148864220
cmpwi r4, 343
beq- OriginalExit_SetHitVarsOnHit
cmplwi r3, 0
beq EpilogReturn_SetHitVarsOnHit
prolog r31, r30, r29, r28, r27, r26, r25, r24
lwz r31, 0x0000002C(r3)
lwz r30, 0x0000002C(r4)
mr r29, r5
mr r27, r3
mr r26, r4
cmplwi r6, 0
mr r28, r6
bne CalculateTypes_SetHitVarsOnHit
CalculateExtHitOffset_SetHitVarsOnHit:
mr r3, r27
mr r4, r29
bla r12, 2148864212
cmplwi r3, 0
beq Epilog_SetHitVarsOnHit
mr r28, r3
CalculateTypes_SetHitVarsOnHit:
mr r3, r27
bl IsItemOrFighter_SetHitVarsOnHit
cmplwi r3, 0
beq Epilog_SetHitVarsOnHit
mr r25, r3
mr r3, r26
bl IsItemOrFighter_SetHitVarsOnHit
cmplwi r3, 0
beq Epilog_SetHitVarsOnHit
mr r24, r3
li r3, 0
li r4, 0
lwz r0, 0x00001848(r30)
cmplwi r0, 367
beq shv_AttackVecPull
cmplwi r0, 368
beq shv_AttackVecTargetPos
b shv_AutolinkExit
shv_AttackVecPull:
li r3, 6
stw r3, 11072(r30)
li r3, 0
lbz r5, 11048(r30)
rlwimi r5, r3, 5, 32
stb r5, 11048(r30)
lwz r5, 0x0000004C(r29)
stw r5, 11052(r30)
lwz r5, 0x00000050(r29)
stw r5, 11056(r30)
mr r3, r29
b shv_AutolinkExit
shv_AttackVecTargetPos:
lwz r4, 36(r28)
addi r4, r4, 1
stw r4, 11072(r30)
lwz r4, 52(r28)
lbz r5, 11048(r30)
rlwimi r5, r4, 5, 32
stb r5, 11048(r30)
sp.push
sp.temp xTempPosX, (0x00000004), xTempPosY, (0x00000004), xTempPosZ, (0x00000004)
lwz r3, 20(r28)
addi r4, r28, 24
addi r5, sp, sp.xTempPosX
bla r12, 2147529164
addi r3, r30, 11052
psq_l f0, sp.xTempPosX(sp), 0, 0
psq_st f0, 0(r3), 0, 0
sp.pop
li r3, 0
mr r4, r28
shv_AutolinkExit:
stw r3, 11064(r30)
stw r4, 11068(r30)
li r3, 0
lbz r0, 11048(r30)
rlwimi r0, r3, 4, 16
stb r0, 11048(r30)
cmpwi r24, 1
bne Epilog_SetHitVarsOnHit
Epilog_SetHitVarsOnHit:
epilog
EpilogReturn_SetHitVarsOnHit:
blr
IsItemOrFighter_SetHitVarsOnHit:
lhz r0, 0(r3)
cmplwi r0, 0x00000004
li r3, 1
beq Result
li r3, 2
cmplwi r0, 0x00000006
beq Result
li r3, 0
Result:
blr
Constants_SetHitVarsOnHit:
blrl
OriginalExit_SetHitVarsOnHit:
lwz r5, 0x0000010C(r31)
gecko 2148864212
cmpwi r4, 343
beq- OriginalExit_GetExtHit
cmplwi r3, 0
beq Invalid_GetExtHit
cmplwi r4, 0
beq Invalid_GetExtHit
li r0, 4
mtctr r0
lhz r0, 0(r3)
lwz r3, 0x0000002C(r3)
cmplwi r0, 4
beq GetExtHitForFighter
cmplwi r0, 6
beq GetExtHitForItem
b Invalid_GetExtHit
GetExtHitForItem:
addi r5, r3, 1492
addi r3, r3, 4048
li r0, 316
b GetExtHitLoop
GetExtHitForFighter:
addi r5, r3, 2324
addi r3, r3, 9248
li r0, 312
GetExtHitLoop:
b Comparison_GetExtHit
Loop_GetExtHit:
add r5, r5, r0
addi r3, r3, 60
Comparison_GetExtHit:
cmplw r5, r4
bdnzf eq, Loop_GetExtHit
beq Exit_GetExtHit
Invalid_GetExtHit:
li r3, 0
Exit_GetExtHit:
blr
OriginalExit_GetExtHit:
lwz r31, 0x0000002C(r3)
gecko 2147983596
stw r24, 0x00000090(sp)
lis r29, 0x00004330
gecko 2147986164
lwz r0, 0x0000001C(r31)
cmplwi r0, 2
bne SetVars_8007aaf4
lwz r3, 0xFFFFAEB4(r13)
lfs f0, 0x000001A4(r3)
stfs f0, 0x00001960(r25)
SetVars_8007aaf4:
lwz r3, 0x00000008(r19)
mr r4, r30
lwz r5, 0x0000000C(r19)
lwz r6, 0x00000090(sp)
bla r12, 2148864220
li r0, 0
gecko.end
