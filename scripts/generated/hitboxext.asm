# generated with geckon
# Hitbox Extension A20XX
# authors: @[]
# description: 
.include "punkpc.s"
punkpc ppc

gecko 2147913452
li r4, 0
stw r4, 32(r31)
stw r4, 36(r31)
stb r4, 13(r3)
sth r4, 14(r3)
stb r4, 8701(r3)
sth r4, 8702(r3)
addi r30, r3, 0
load r4, 2152042448
lwz r4, 32(r4)
bla r12, 2147533152
mr r3, r30
lis r4, 32838
gecko 2147908028, li r4, 9292
gecko 2148754716, blr
gecko.end
gecko 2150002648, li r4, 4128
gecko 2150008660
addi r29, r3, 0
li r4, 4128
bla r12, 2147533152
mr r3, r29
mr. r6, r3
gecko.end
gecko 2148064624
lfs f0, 9280(r29)
fadds f30, f30, f0
fctiwz f0, f30
gecko.end
gecko 2147955480
cmpwi r28, 60
bne+ OriginalExit_80073318
li r5, 9196
bl ParseEventData
ba r12, 2147955500
ParseEventData:
stwu sp, -80(sp)
lwz r3, 8(r29)
lbz r4, 1(r3)
rlwinm. r0, r4, 0, 27, 27
bne ApplyToAllPreviousHitboxes
li r0, 1
rlwinm r4, r4, 27, 29, 31
b SetLoopCount
ApplyToAllPreviousHitboxes:
li r0, 4
li r4, 0
SetLoopCount:
mtctr r0
mulli r4, r4, 20
add r4, r4, r5
add r4, r30, r4
b BeginReadData
CopyToAllHitboxes:
addi r6, r4, 20
Loop:
lwz r0, 0(r4)
stw r0, 0(r6)
lwz r0, 4(r4)
stw r0, 4(r6)
lwz r0, 8(r4)
stw r0, 8(r6)
lwz r0, 12(r4)
stw r0, 12(r6)
lwz r0, 16(r4)
stw r0, 16(r6)
addi r6, r6, 20
bdnz+ Loop
b ExitParseEventData
BeginReadData:
lwz r6, -20812(r13)
lfs f1, 244(r6)
lhz r6, 1(r3)
rlwinm r6, r6, 0, 4095
sth r6, 68(sp)
lhz r6, 3(r3)
rlwinm r6, r6, 28, 4095
sth r6, 70(sp)
psq_l f0, 68(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r4), 0, 7
lwz r6, -20812(r13)
psq_l f1, 244(r6), 1, 7
lhz r6, 4(r3)
rlwinm r6, r6, 0, 4095
sth r6, 64(sp)
lbz r6, 6(r3)
slwi r6, r6, 24
srawi r6, r6, 24
sth r6, 66(sp)
psq_l f0, 64(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r4), 0, 7
lbz r6, 7(r3)
stb r6, 16(r4)
bdnz+ CopyToAllHitboxes
ExitParseEventData:
addi r3, r3, 8
stw r3, 8(r29)
addi sp, sp, 80
blr
OriginalExit_80073318:
lwz r12, 0(r3)
gecko 2150079164
cmpwi r28, 60
bne+ OriginalExit_80279ABC
li r5, 4044
bl ParseEventData
ba r12, 2150079184
OriginalExit_80279ABC:
lwz r12, 0(r3)
gecko 2147956084
lwz r4, 8(r29)
cmpwi r28, 60
bne OriginalExit_80073574
addi r4, r4, 8
stw r4, 8(r29)
ba r12, 2147956104
OriginalExit_80073574:

gecko.end
gecko 2147947132
mulli r3, r0, 20
addi r3, r3, 9196
add r3, r31, r3
mr r30, r0
bl InitDefaultValuesExtHit
b OriginalExit_8007127C
InitDefaultValuesExtHit:
lfs f0, -30608(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, -30604(rtoc)
stfs f0, 12(r3)
li r0, 0
stw r0, 16(r3)
blr
OriginalExit_8007127C:
mulli r3, r30, 312
gecko 2150076656
mulli r3, r4, 20
addi r3, r3, 4044
add r3, r30, r3
bl InitDefaultValuesExtHit
mr r0, r30
mulli r3, r4, 316
gecko.end
gecko 2147986164
lwz r3, 8(r19)
mr r4, r30
lwz r5, 12(r19)
bl SetVarsOnHit
ba r12, 2147986188
SetVarsOnHit:
prolog rSrcData, rDefData, rHitStruct, rExtHitStruct, rSrcGObj, rDefGObj, rSrcType, rDefType
lwz rSrcData, 44(r3)
lwz rDefData, 44(r4)
mr rHitStruct, r5
mr rSrcGObj, r3
mr rDefGObj, r4
mr r3, rSrcGObj
bl IsItemOrFighter
mr rSrcType, r3
cmpwi r3, 1
beq SetupFighterVars
cmpwi r3, 2
bne Epilog_SetVarsOnHit
SetupItemVars:
li r5, 1492
li r6, 316
li r7, 4044
b CalculateExtHitOffset
SetupFighterVars:
li r5, 2324
li r6, 312
li r7, 9196
CalculateExtHitOffset:
mr r3, rSrcData
mr r4, rHitStruct
bl GetExtHitForHitboxStruct
cmpwi r3, 0
beq Epilog_SetVarsOnHit
mr rExtHitStruct, r3
cmpwi rDefType, 1
bne Epilog_SetVarsOnHit
lfs f0, 12(r28)
stfs f0, 9280(r30)
Epilog_SetVarsOnHit:
epilog
blr
CalculateHitlagMultiOffset:
cmpwi r3, 1
beq Return1960
cmpwi r3, 2
bne Exit_CalculateHitlagMultiOffset
li r3, 4124
b Exit_CalculateHitlagMultiOffset
Return1960:
li r3, 6496
Exit_CalculateHitlagMultiOffset:
blr
IsItemOrFighter:
lhz r0, 0(r3)
cmpwi r0, 4
li r3, 1
beq Result_IsItemOrFighter
li r3, 2
cmpwi r0, 6
beq Result_IsItemOrFighter
li r3, 0
Result_IsItemOrFighter:
blr
GetExtHitForHitboxStruct:
add r8, r3, r5
li r5, 0
b Comparison_GetExtHitForHitboxStruct
Loop_GetExtHitForHitboxStruct:
addi r5, r5, 1
cmpwi r5, 3
bgt- NotFound_GetExtHitForHitboxStruct
add r8, r8, r6
Comparison_GetExtHitForHitboxStruct:
cmplw r8, r4
bne+ Loop_GetExtHitForHitboxStruct
mulli r5, r5, 20
add r5, r5, r7
add r5, r3, r5
mr r3, r5
blr
NotFound_GetExtHitForHitboxStruct:
li r3, 0
blr
gecko 2150041004
mr r3, r29
mr r4, r24
mr r5, r26
bl SetVarsOnHit
OriginalExit_802705ac:
lwz r0, 3232(r30)
gecko 2150042552
mr r3, r30
mr r4, r26
mr r5, r19
bl SetVarsOnHit
OriginalExit_80270BB8:
lwz r0, 3232(r31)
gecko.end
gecko 2147932412
lfs f0, -30608(rtoc)
stfs f1, 6200(r30)
stfs f1, 9280(r30)

gecko.end
gecko.end