.include "punkpc.s"
punkpc ppc
# sushie's Custom Subaction Commands Loader v1.0.0
# authors: @["sushie"]
# description: 
gecko 2148864224
cmpwi r4, 343
beq OriginalExit_801510E0
prolog rGObj, rData, rCmdInfo, rEventParse, rCmdData, rExtDataOff, rHitStructOff, rHitStructSize, rEightHitOff, rCurrentId
mr rGObj, r3
lwz rData, 0x0000002C(rGObj)
mr rCmdInfo, r4
mr rEventParse, r5
li rCurrentId, 8
lhz r0, 0(rGObj)
cmplwi r0, 0x00000004
beq ParseHitboxExt_SetFighterVars
cmplwi r0, 0x00000006
bne ParseHitboxExt_Exit
ParseHitboxExt_SetItemVars:
li rExtDataOff, 4048
li rHitStructOff, 1492
li rHitStructSize, 316
li rEightHitOff, 1932
b ParseHitboxExt_Begin
ParseHitboxExt_SetFighterVars:
li rExtDataOff, 9248
li rHitStructOff, 2324
li rHitStructSize, 312
li rEightHitOff, 6396
ParseHitboxExt_Begin:
lwz rCmdData, 0x00000008(rCmdInfo)
lbz r0, 0x00000001(rCmdData)
rlwinm r3, r0, 27, 29, 31
rlwinm. r0, r0, 0, 0x00000010
beq ParseHitboxExt_GetHitStructs
li r3, 0
li rCurrentId, 0
ParseHitboxExt_GetHitStructs:
mullw r4, r3, rHitStructSize
cmplwi r3, 4
blt CalcNormal
add r4, r4, rEightHitOff
CalcNormal:
add r4, r4, rHitStructOff
add r4, rData, r4
mulli r3, r3, 80
add r3, r3, rExtDataOff
add r3, rData, r3
ParseHitboxExt_FindActiveHitboxes:
regs (3), rExtHit, rNormHit
lwz r0, 0(rNormHit)
cmpwi r0, 0
beq ParseHitboxExt_FindActiveHitboxes_Next
lwz r12, 0(rEventParse)
cmplwi r12, 0
beq ParseHitboxExt_FindActiveHitboxes_Next
mtlr r12
mr r5, rCmdData
blrl
ParseHitboxExt_FindActiveHitboxes_Next:
addi rCurrentId, rCurrentId, 1
cmplwi rCurrentId, 4
bne Advance
add r4, r4, rEightHitOff
Advance:
cmplwi rCurrentId, 8
add r4, r4, rHitStructSize
addi r3, r3, 80
blt ParseHitboxExt_FindActiveHitboxes
ParseHitboxExt_Exit:
lwz r0, 0x00000010(rEventParse)
add rCmdData, rCmdData, r0
stw rCmdData, 0x00000008(rCmdInfo)
epilog
blr
OriginalExit_801510E0:
fmr f3, f1
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
li r0, 8
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
prolog xParseData, (0x00000020)
mr r3, r27
mr r4, r29
addi r5, sp, sp.xParseData
bl HitboxExtCmd_Standard_Parse
mflr r0
stw r0, 0(r5)
li r0, 0
stw r0, 0x00000004(r5)
li r0, 9
li r0, 0x00000008
stw r0, 0x00000010(r5)
bla r12, 2148864224
HitboxExtCmd_Exit:
epilog
blr
HitboxExtCmd_Standard_Copy:
blrl
HitboxExtCmd_Standard_Copy_Begin:
lbz r0, 0x00000007(r5)
rlwinm. r0, r0, 0, 2
beqlr
sp.push
sp.temp +2, rg
lwz r0, 0x00000008(r4)
sth r0, sp.rg(sp)
psq_l f1, sp.rg(sp), 1, 5
stfs f1, 0x0000000C(r4)
sp.pop
blr
HitboxExtCmd_Standard_Parse:
blrl
sp.push
sp.temp +2, rg, ba
lwz r6, 0xFFFFAEB4(r13)
lfs f1, 0x000000F4(r6)
lhz r6, 0x00000001(r5)
rlwinm r6, r6, 0, 0x00000FFF
sth r6, sp.rg(sp)
lhz r6, 0x00000003(r5)
rlwinm r6, r6, 28, 0x00000FFF
sth r6, sp.ba(sp)
psq_l f0, sp.rg(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 0(r3), 0, 7
lwz r6, 0xFFFFAEB4(r13)
psq_l f1, 0x000000F4(r6), 1, 7
lhz r6, 0x00000004(r5)
rlwinm r6, r6, 0, 0x00000FFF
sth r6, sp.rg(sp)
lbz r6, 0x00000006(r5)
slwi r6, r6, 24
srawi r6, r6, 24
sth r6, sp.ba(sp)
psq_l f0, sp.rg(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 8(r3), 0, 7
lbz r0, 0x00000007(r5)
stb r0, 16(r3)
sp.pop
rlwinm. r0, r0, 0, 16
beq HitboxExtCmd_Standard_Copy_Begin
li r0, 0
stw r0, 0(r3)
b HitboxExtCmd_Standard_Copy_Begin
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
ba r12, 2147955792
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
