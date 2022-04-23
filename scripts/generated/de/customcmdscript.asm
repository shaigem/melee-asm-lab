.include "punkpc.s"
punkpc ppc
# sushie's Custom Subaction Commands Loader v1.0.0
# authors: @["sushie"]
# description: 
gecko 2147955480
lwz r12, 0(r3)
cmpwi r28, 60
li r3, 0
beq- CustomFighterCmd_Jump
cmpwi r28, 61
li r3, 1
beq- CustomFighterCmd_Jump
b OriginalExit_80073318
CustomCmd_HitboxExtension:
hitboxextcmd.__start = .
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
specialflagscmd.__start = .
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
CustomItemCmd_Jump:
bl CustomCmd_DetermineJump
ba r12, 2150079184
CustomFighterCmd_Jump:
bl CustomCmd_DetermineJump
ba r12, 2147955500
CustomFighterCmd_FastForward_Jump:
bl CustomCmd_DetermineJump
ba r12, 2147955792
CustomCmd_DetermineJump:
prolog
bl CustomCmd_JumpTable
mflr r4
slwi r0, r3, 2
lwzx r0, r4, r0
sub r0, r4, r0
mtctr r0
bctrl
epilog
blr
CustomCmd_JumpTable:
blrl
customcmdjmp.__start = .
.4byte customcmdjmp.__start - hitboxextcmd.__start
.4byte customcmdjmp.__start - specialflagscmd.__start
OriginalExit_80073318:

gecko 2150079164
lwz r12, 0(r3)
cmpwi r28, 60
li r3, 0
beq- CustomItemCmd_Jump
cmpwi r28, 61
li r3, 1
beq- CustomItemCmd_Jump
OriginalExit_80279abc:

gecko.end
gecko 2147955760
subi r0, r28, 10
cmpwi r28, 60
li r3, 0
beq- CustomFighterCmd_FastForward_Jump
cmpwi r28, 61
li r3, 1
beq- CustomFighterCmd_FastForward_Jump
SubactionFastForward_OrigExit:

gecko 2147956084
lwz r4, 0x00000008(r29)
cmpwi r28, 60
li r0, 8
beq- SubactionFastForwardPtr2_Skip
cmpwi r28, 61
li r0, 4
beq- SubactionFastForwardPtr2_Skip
b SubactionFastForwardPtr2_OrigExit
SubactionFastForwardPtr2_Skip:
add r4, r4, r0
stw r4, 0x00000008(r29)
ba r12, 2147956104
SubactionFastForwardPtr2_OrigExit:

gecko.end
