.include "punkpc.s"
punkpc ppc
# Hitbox Extension
# authors: @[]
# description: 
gecko 2148864224
cmpwi r4, 343
beq- OriginalExit_801510e0
mflr r0
stw r0, 0x00000004(sp)
stwu sp, 0xFFFFFFB0(sp)
lwz r9, 0x00000008(r29)
li r10, 0
cmplwi r4, 0
bne BeginReadData_801510e0
CheckApplyToPrevious_801510e0:
lbz r0, 0x00000001(r9)
rlwinm. r10, r0, 0, 27, 27
rlwinm r3, r0, 27, 29, 31
beq CalculateHitStructs_801510e0
li r3, 0
CalculateHitStructs_801510e0:
mullw r4, r3, r7
cmplwi r3, 4
blt CalcNormal_801510e0
add r4, r4, r8
CalcNormal_801510e0:
add r4, r4, r6
add r4, r30, r4
mulli r3, r3, 20
add r3, r3, r5
add r3, r30, r3
BeginReadData_801510e0:
lwz r5, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r5)
lhz r5, 0x00000001(r9)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000044(sp)
lhz r5, 0x00000003(r9)
rlwinm r5, r5, 28, 0x00000FFF
sth r5, 0x00000046(sp)
psq_l f0, 0x00000044(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r3), 0, 7
lwz r5, 0xFFFFAEB4(r13)
psq_l f1, 0x000000F4(r5), 1, 7
lhz r5, 0x00000004(r9)
rlwinm r5, r5, 0, 0x00000FFF
sth r5, 0x00000040(sp)
lbz r5, 0x00000006(r9)
slwi r5, r5, 24
srawi r5, r5, 24
sth r5, 0x00000042(sp)
psq_l f0, 0x00000040(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r3), 0, 7
lbz r0, 0x00000007(r9)
stb r0, 16(r3)
bl SetBaseDamage_801510e0
cmplwi r10, 0
beq Exit_801510e0
CopyToAllHitboxes_801510e0:
li r10, 1
addi r5, r3, 20
add r4, r4, r7
Loop_801510e0:
cmpwi r10, 4
bne Body_801510e0
add r4, r4, r8
Body_801510e0:
lwz r0, 0(r3)
stw r0, 0(r5)
lwz r0, 4(r3)
stw r0, 4(r5)
lwz r0, 8(r3)
stw r0, 8(r5)
lwz r0, 12(r3)
stw r0, 12(r5)
lbz r0, 16(r3)
stb r0, 16(r5)
bl SetBaseDamage_801510e0
addi r5, r5, 20
add r4, r4, r7
addi r10, r10, 1
cmplwi r10, 8
blt+ Loop_801510e0
Exit_801510e0:
addi r9, r9, 8
stw r9, 0x00000008(r29)
lwz r0, 0x00000054(sp)
addi sp, sp, 0x00000050
mtlr r0
blr
SetBaseDamage_801510e0:
rlwinm. r0, r0, 0, 2
beq Return_SetBaseDamage_801510e0
lwz r0, 0x00000008(r4)
sth r0, 0x00000040(sp)
psq_l f1, 0x00000040(sp), 1, 5
stfs f1, 0x0000000C(r4)
Return_SetBaseDamage_801510e0:
blr
OriginalExit_801510e0:
fmr f3, f1
gecko 2147955760
subi r0, r28, 10
cmpwi r28, 0x0000003C
bne OriginalExit_80073430
lwz r4, 0x00000008(r29)
addi r4, r4, 8
stw r4, 0x00000008(r29)
ba r12, 2147955792
OriginalExit_80073430:

gecko 2147956084
lwz r4, 0x00000008(r29)
cmpwi r28, 0x0000003C
bne OriginalExit_80073574
addi r4, r4, 8
stw r4, 0x00000008(r29)
ba r12, 2147956104
OriginalExit_80073574:

gecko 2147955480
cmpwi r28, 0x0000003C
bne+ OriginalExit_80073318
lwz r3, 0x00000008(r29)
lbz r3, 0x00000007(r3)
rlwinm. r3, r3, 0, 1
li r3, 0
li r4, 0
beq ReadEvent_80073318
addi r3, r30, 9408
addi r4, r30, 0x00000DF4
ReadEvent_80073318:
li r5, 9248
li r6, 2324
li r7, 312
li r8, 5856
bla r12, 0x801510e0
ba r12, 2147955500
OriginalExit_80073318:
lwz r12, 0(r3)
gecko 2150079164
cmpwi r28, 0x0000003C
bne+ OriginalExit_80279abc
li r3, 0
li r4, 0
li r5, 4048
li r6, 1492
li r7, 316
li r8, 1452
bla r12, 0x801510e0
ba r12, 2150079184
OriginalExit_80279abc:
lwz r12, 0(r3)
gecko.end
gecko 2150014172
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 5472(r5)
lfs f0, 0xFFFFCC58(rtoc)
gecko 2150076668
mulli r3, r4, 20
addi r3, r3, 4048
add r3, r30, r3
bla r12, 0x801510e4
lwz r0, 0(r29)
gecko 2147947144
mulli r3, r0, 20
addi r3, r3, 9248
add r3, r31, r3
bla r12, 0x801510e4
lwz r0, 0(r30)
gecko 2147950152
cmplwi r0, 1
bge Exit_80071e48
addi r3, r6, 9408
bla r12, 0x801510e4
stw r0, 0(r3)
Exit_80071e48:
addi r3, r31, 0
gecko 2147930584
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 10676(r31)
lwz r0, 0x00000024(sp)
gecko 2147932508
lwz r0, 0x00001A58(r30)
cmplwi r0, 0
bne Exit_8006d95c
stfs f0, 0x00001960(r30)
Exit_8006d95c:

gecko 2147932412
lbz r0, 10688(r30)
rlwimi r0, r3, 0, 1
stb r0, 10688(r30)
lbz r0, 10688(r30)
rlwimi r0, r3, 2, 4
stb r0, 10688(r30)
lbz r0, 10688(r30)
rlwimi r0, r3, 3, 8
stb r0, 10688(r30)
stfs f1, 10680(r30)
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 10684(r30)
stfs f1, 0x00001838(r30)
gecko 2148864228
cmpwi r4, 343
beq- OriginalExit_801510e4
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 12(r3)
li r0, 0
stw r0, 16(r3)
blr
OriginalExit_801510e4:
lfs f2, 0xFFFFA4C4(rtoc)
gecko.end
gecko 2147976504
lwz r3, 0x0000002C(r3)
lbz r0, 10688(r3)
rlwinm. r0, r0, 0, 1
beq OriginalExit_80078538
blr
OriginalExit_80078538:
lwz r3, 0(r3)
mflr r0
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
gecko 2150041004
mr r3, r29
mr r4, r24
mr r5, r26
li r6, 0
bla r12, 2148864220
lwz r0, 0x00000CA0(r30)
gecko 2150042552
mr r3, r30
mr r4, r26
mr r5, r19
li r6, 0
bla r12, 2148864220
lwz r0, 0x00000CA0(r31)
gecko 2148067236
lfs f0, 10676(r31)
fmuls f2, f2, f0
lfs f0, 0x0000063C(r31)
gecko 2148067264
lfs f0, 10676(r31)
fmuls f2, f2, f0
lfs f0, 0x00000624(r31)
gecko 2148066648
lfs f0, 10676(r3)
fmuls f4, f4, f0
li r0, 254
gecko 2148064624
lfs f0, 10680(r29)
fadds f30, f30, f0
fctiwz f0, f30
gecko 2148085836
lfs f0, 10684(r31)
fmuls f4, f4, f0
fsubs f2, f2, f3
gecko 2147931872
lbz r0, 10688(r30)
rlwinm. r0, r0, 0, 8
beq OriginalExit_8006d6e0
lwz r29, 0x0000183C(r30)
OriginalExit_8006d6e0:
mr r3, r30
gecko 2148392840
mr r3, r24
mr r4, r25
addi r5, r31, 0x00000DF4
addi r6, r31, 9408
bla r12, 2148864220
lfs f1, 0x00001960(r30)
mr r3, r30
lwz r4, 0x00000E24(r28)
lwz r5, 0x00000DFC(r28)
lwz r6, 0x00000010(r30)
bla r12, 2148074900
lhz r0, 0x000018FA(r30)
cmplwi r0, 0
beq Exit_800ddf88
li r3, 1
lbz r0, 10688(r30)
rlwimi r0, r3, 3, 8
stb r0, 10688(r30)
Exit_800ddf88:
lbz r0, 0x00002226(r27)
gecko 2148864220
cmpwi r4, 343
beq- OriginalExit_801510dc
cmplwi r3, 0
beq EpilogReturn_801510dc
prolog r31, r30, r29, r28, r27, r26, r25, r24
lwz r31, 0x0000002C(r3)
lwz r30, 0x0000002C(r4)
mr r29, r5
mr r27, r3
mr r26, r4
cmplwi r6, 0
mr r28, r6
bne CalculateTypes_801510dc
mr r3, r27
mr r4, r29
bla r12, 2148864212
cmplwi r3, 0
beq Epilog_801510dc
mr r28, r3
CalculateTypes_801510dc:
mr r3, r27
bl IsItemOrFighter_801510dc
cmplwi r3, 0
beq Epilog_801510dc
mr r25, r3
mr r3, r26
bl IsItemOrFighter_801510dc
cmplwi r3, 0
beq Epilog_801510dc
mr r24, r3
StoreHitlag_801510dc:
lfs f0, 0(r28)
cmpwi r25, 1
addi r3, r31, 5472
bne StoreHitlagMultiForAttacker_801510dc
addi r3, r31, 0x00001960
StoreHitlagMultiForAttacker_801510dc:
stfs f0, 0(r3)
cmpwi r24, 1
addi r3, r30, 5472
bne ElectricHitlagCalculate_801510dc
addi r3, r30, 0x00001960
ElectricHitlagCalculate_801510dc:
lwz r0, 0x00000030(r29)
cmplwi r0, 2
bne+ StoreHitlagMultiForDefender_801510dc
lwz r4, 0xFFFFAEB4(r13)
lfs f1, 0x000001A4(r4)
fmuls f0, f1, f0
StoreHitlagMultiForDefender_801510dc:
stfs f0, 0(r3)
cmpwi r24, 1
bne Epilog_801510dc
StoreHitstunModifier_801510dc:
lfs f0, 12(r28)
stfs f0, 10680(r30)
StoreSDIMultiplier_801510dc:
lfs f0, 4(r28)
stfs f0, 10676(r30)
CalculateFlippyDirection_801510dc:
lbz r3, 16(r28)
lfs f0, 0x0000002C(r31)
rlwinm. r0, r3, 0, 26, 26
bne FlippyForward_801510dc
rlwinm. r0, r3, 0, 25, 25
bne StoreCalculatedDirection_801510dc
b SetWeight_801510dc
FlippyForward_801510dc:
fneg f0, f0
StoreCalculatedDirection_801510dc:
stfs f0, 0x00001844(r30)
SetWeight_801510dc:
lbz r3, 16(r28)
rlwinm. r3, r3, 0, 128
beq ResetTempGravityFallSpeed_801510dc
SetTempGravityFallSpeed_801510dc:
bl Constants_801510dc
mflr r3
addi r4, r30, 0x00000110
lfs f0, 0(r3)
stfs f0, 0x0000005C(r4)
lfs f0, 4(r3)
stfs f0, 0x00000060(r4)
li r3, 1
lbz r0, 10688(r30)
rlwimi r0, r3, 1, 2
stb r0, 10688(r30)
b StoreDisableMeteorCancel_801510dc
ResetTempGravityFallSpeed_801510dc:
lbz r3, 10688(r30)
rlwinm. r3, r3, 0, 2
beq StoreDisableMeteorCancel_801510dc
mr r3, r30
bla r12, 0x801510e8
StoreDisableMeteorCancel_801510dc:
lbz r3, 16(r28)
rlwinm. r0, r3, 0, 4
li r3, 0
beq MeteorCancelSet
li r3, 1
MeteorCancelSet:
lbz r0, 10688(r30)
rlwimi r0, r3, 2, 4
stb r0, 10688(r30)
Epilog_801510dc:
epilog
EpilogReturn_801510dc:
blr
IsItemOrFighter_801510dc:
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
Constants_801510dc:
blrl
.float 0.095
.float 1.7
OriginalExit_801510dc:
lwz r5, 0x0000010C(r31)
gecko 2147931912
lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit_8006d708
li r3, 0
stw r3, 0x000021D0(r30)
stw r3, 0x000021D8(r30)
ba r12, 2147932128
OriginalExit_8006d708:
stfs f1, 0x0000195C(r30)
gecko 2148069424
lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit_8008f030
ba r12, 2148069496
OriginalExit_8008f030:
stfs f1, 0x0000195C(r27)
gecko 2147970540
lwz r3, 0(r29)
mr r4, r30
bla r12, 2148864212
cmplwi r3, 0
beq Exit_80076dec
lfs f0, 8(r3)
stfs f0, 10684(r31)
Exit_80076dec:
lwz r3, 0x00000024(sp)
lwz r0, 0x00000030(r30)
gecko 2147973396
lwz r3, 0x00000004(r27)
mr r4, r28
bla r12, 2148864212
cmplwi r3, 0
beq Exit_80077914
lfs f0, 8(r3)
stfs f0, 10684(r29)
Exit_80077914:
lwz r0, 0x00000030(r28)
gecko 2150020180
lfs f1, 5472(r31)
fmuls f0, f0, f1
fctiwz f0, f0
gecko 2150016504
lfs f0, 0xFFFF8870(rtoc)
fcmpo cr0, f1, f0
bge+ OriginalExit_8026a5f8
bla r12, 2150016652
OriginalExit_8026a5f8:
lfs f0, 0x00000CBC(r31)
gecko.end
