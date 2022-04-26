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
cmpwi r28, 60
beq CustomCmd_HitboxExtension
cmpwi r28, 61
beq CustomCmd_SpecialFlags
li r28, 0
blr
GetCustomCmdEventLen:
cmpwi r28, 60
li r0, 8
beqlr
cmpwi r28, 61
li r0, 4
beqlr
li r0, 0
blr
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
li r8, 1452
b HitboxExtCmd_ReadEvent
HitboxExtCmd_SetupFighter:
lwz r3, 0x00000008(r29)
lbz r3, 0x00000007(r3)
rlwinm. r3, r3, 0, 1
li r3, 0
li r4, 0
beq HitboxExtCmd_SetupFighter_NoThrow
addi r3, r30, 9408
addi r4, r30, 0x00000DF4
HitboxExtCmd_SetupFighter_NoThrow:
li r5, 9248
li r6, 2324
li r7, 312
li r8, 5856
HitboxExtCmd_ReadEvent:
bla r12, 0x801510e0
HitboxExtCmd_Exit:
epilog
blr
CustomCmd_SpecialFlags:
lwz r3, 0x00000008(r29)
lbz r4, 0x00000001(r3)
rlwinm r4, r4, 27, 29, 31
mulli r4, r4, 312
addi r4, r4, 2324
add r4, r30, r4
regs (3), rCmdEvtPtr, rHitStruct
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
addi rCmdEvtPtr, rCmdEvtPtr, 4
stw rCmdEvtPtr, 0x00000008(r29)
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
