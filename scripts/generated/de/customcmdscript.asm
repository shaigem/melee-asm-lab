.include "punkpc.s"
punkpc ppc
# sushie's Custom Subaction Commands Loader v1.0.0
# authors: @["sushie"]
# description: 
gecko 2147955480
lwz r12, 0(r3)
bl JumpCustomCmdEvent
cmpwi r28, 0
beq OriginalExit_80073318
ba r12, 2147955500
JumpCustomCmdEvent:
cmpwi r28, 59
beq CustomCmd_HitboxExtensionAdvanced
cmpwi r28, 60
beq CustomCmd_HitboxExtension
cmpwi r28, 61
beq CustomCmd_SpecialFlags
cmpwi r28, 62
beq CustomCmd_AttackCapsule
li r28, 0
blr
GetCustomCmdEventLen:
cmpwi r28, 59
li r0, 12
beqlr
cmpwi r28, 60
li r0, 8
beqlr
cmpwi r28, 61
li r0, 4
beqlr
cmpwi r28, 62
li r0, 8
beqlr
li r0, 0
blr
CustomCmd_HitboxExtensionAdvanced:
CustomCmd_HitboxExtension:
prolog
lhz r0, 0(r27)
cmplwi r0, 0x00000004
beq HitboxExtCmd_SetupFighter
cmplwi r0, 0x00000006
bne HitboxExtCmd_Exit
HitboxExtensionCmd_SetupItem:
li r3, 0
li r4, 0
li r5, 4048
li r6, 1492
li r7, 316
li r8, 1932
b HitboxExtCmd_ReadEvent
HitboxExtCmd_SetupFighter:
lwz r3, 0x00000008(r29)
lbz r3, 0x00000007(r3)
rlwinm. r3, r3, 0, 1
li r3, 0
li r4, 0
beq HitboxExtCmd_SetupFighter_NoThrow
addi r3, r30, 9888
addi r4, r30, 0x00000DF4
HitboxExtCmd_SetupFighter_NoThrow:
li r5, 9248
li r6, 2324
li r7, 312
li r8, 6396
HitboxExtCmd_ReadEvent:
cmpwi r28, 59
li r9, 1
beq HitBoxEventCmd_ReadEvent_Branch
li r9, 0
HitBoxEventCmd_ReadEvent_Branch:
bla r12, 0x801510e0
HitboxExtCmd_Exit:
epilog
blr
CustomCmd_SpecialFlags:
lwz r3, 0x00000008(r29)
lbz r4, 0x00000001(r3)
li r7, 4
rlwinm. r0, r4, 0, 27, 27
rlwinm r4, r4, 27, 29, 31
beq SpecialFlagsCmd_GetHitStruct
li r4, 0
li r7, 0
SpecialFlagsCmd_GetHitStruct:
mulli r4, r4, 312
addi r4, r4, 2324
add r4, r30, r4
regs (3), rCmdEvtPtr, rHitStruct
SpecialFlagsCmd_ReadLoop:
lwz r0, 0(r4)
cmpwi r0, 0
beq SpecialFlagsCmd_ReadLoop_Next
lhz r5, 0x00000040(rHitStruct)
lbz r6, 0x00000002(rCmdEvtPtr)
rlwimi r5, r6, 4, 20, 27
sth r5, 0x00000040(rHitStruct)
lbz r5, 0x00000041(rHitStruct)
lbz r6, 0x00000003(rCmdEvtPtr)
rlwimi r5, r6, 28, 28, 28
stb r5, 0x00000041(rHitStruct)
lbz r5, 0x00000041(rHitStruct)
lbz r6, 0x00000003(rCmdEvtPtr)
rlwimi r5, r6, 28, 29, 29
stb r5, 0x00000041(rHitStruct)
lbz r5, 0x00000041(rHitStruct)
lbz r6, 0x00000003(rCmdEvtPtr)
rlwimi r5, r6, 28, 30, 30
stb r5, 0x00000041(rHitStruct)
lbz r5, 0x00000042(rHitStruct)
lbz r6, 0x00000003(rCmdEvtPtr)
rlwimi r5, r6, 4, 25, 25
stb r5, 0x00000042(rHitStruct)
lbz r5, 0x00000042(rHitStruct)
lbz r6, 0x00000003(rCmdEvtPtr)
rlwimi r5, r6, 4, 26, 26
stb r5, 0x00000042(rHitStruct)
SpecialFlagsCmd_ReadLoop_Next:
addi r7, r7, 1
cmplwi r7, 4
addi r4, r4, 312
blt SpecialFlagsCmd_ReadLoop
addi rCmdEvtPtr, rCmdEvtPtr, 4
stw rCmdEvtPtr, 0x00000008(r29)
blr
CustomCmd_AttackCapsule:
li r3, 9248
lhz r0, 0(r27)
cmplwi r0, 0x00000004
beq AttackCapsuleCmd_Read
cmplwi r0, 0x00000006
li r3, 4048
bne AttackCapsuleCmd_Exit
regs (3), rExtHit, rCmdPtr, (29), rCmdInfo, rData
AttackCapsuleCmd_Read:
lwz rCmdPtr, 0x00000008(rCmdInfo)
lbz r0, 0x00000001(rCmdPtr)
rlwinm r5, r0, 27, 29, 31
mulli r5, r5, 80
add r3, r5, r3
add rExtHit, rData, r3
sp.push
sp.temp +2, x1, x2
lfs f1, 0xFFFF88C0(rtoc)
lhz r0, 0x00000002(rCmdPtr)
sth r0, sp.x1(sp)
lhz r0, 0x00000004(rCmdPtr)
sth r0, sp.x2(sp)
psq_l f0, sp.x1(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 20(rExtHit), 0, 0
lhz r0, 0x00000006(rCmdPtr)
sth r0, sp.x1(sp)
psq_l f0, sp.x1(sp), 1, 5
ps_mul f0, f1, f0
stfs f0, 28(rExtHit)
li r5, 1
lbz r0, 48(rExtHit)
rlwimi r0, r5, 7, 128
stb r0, 48(rExtHit)
sp.pop
AttackCapsuleCmd_Exit:
lwz r4, 0x00000008(rCmdInfo)
addi r4, r4, 8
stw r4, 0x00000008(rCmdInfo)
blr
OriginalExit_80073318:

gecko 2150079164
lwz r12, 0(r3)
bl JumpCustomCmdEvent
cmpwi r28, 0
beq OriginalExit_80279abc
ba r12, 2150079056
OriginalExit_80279abc:

gecko.end
gecko 2147955760
subi r0, r28, 10
bl JumpCustomCmdEvent
cmpwi r28, 0
beq SubactionFastForward_OrigExit
ba r12, 2147955500
SubactionFastForward_OrigExit:

gecko 2147956084
lwz r4, 0x00000008(r29)
bl GetCustomCmdEventLen
cmpwi r0, 0
beq SubactionFastForwardPtr2_OrigExit
add r4, r4, r0
stw r4, 0x00000008(r29)
ba r12, 2147956104
SubactionFastForwardPtr2_OrigExit:

gecko.end
