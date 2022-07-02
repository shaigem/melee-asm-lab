.include "punkpc.s"
punkpc ppc
# sushie's Custom Subaction Commands Loader v1.0.0
# authors: @["sushie"]
# description: 
gecko 2148864224
cmpwi r4, 343
beq OriginalExit_801510E0
prolog rGObj, rData, rCmdInfo, rEventParse, rCmdData, rHitStructSize, rEightHitOff, rCurrentId, rExtHitTemplate, rCurExtHit, rCurHit
mr rGObj, r3
lwz rData, 0x0000002C(rGObj)
mr rCmdInfo, r4
mr rEventParse, r5
lwz rCmdData, 0x00000008(rCmdInfo)
li rCurrentId, -1
li rExtHitTemplate, 0
li rCurExtHit, 0
li rCurHit, 0
lhz r0, 0(rGObj)
cmplwi r0, 0x00000004
beq ParseHitboxExt_SetFighterVars
cmplwi r0, 0x00000006
bne ParseHitboxExt_Exit
ParseHitboxExt_SetItemVars:
lwz r5, 0x00000014(rEventParse)
cmplwi r5, 2
beq ParseHitboxExt_Exit
li r5, 4048
li r6, 1492
li rHitStructSize, 316
li rEightHitOff, 1964
b ParseHitboxExt_Begin
ParseHitboxExt_SetFighterVars:
lwz r5, 0x00000014(rEventParse)
cmplwi r5, 2
beq ParseHitboxExt_SetForThrow
li r5, 9248
li r6, 2324
li rHitStructSize, 312
li rEightHitOff, 6432
b ParseHitboxExt_Begin
ParseHitboxExt_SetForThrow:
lwz r12, 0(rEventParse)
cmplwi r12, 0
beq ParseHitboxExt_Exit
mtlr r12
addi r3, rData, 9920
addi r4, rData, 0x00000DF4
mr r5, rCmdData
blrl
b ParseHitboxExt_Exit
ParseHitboxExt_Begin:
lbz r0, 0x00000001(rCmdData)
rlwinm r3, r0, 27, 29, 31
lwz r0, 0x00000014(rEventParse)
cmplwi r0, 0
beq ParseHitboxExt_GetHitStructs
li r3, 0
li rCurrentId, 0
ParseHitboxExt_GetHitStructs:
mullw rCurHit, r3, rHitStructSize
cmplwi r3, 4
blt CalcNormal
add rCurHit, rCurHit, rEightHitOff
CalcNormal:
add rCurHit, rCurHit, r6
add rCurHit, rData, rCurHit
mulli rCurExtHit, r3, 84
add rCurExtHit, rCurExtHit, r5
add rCurExtHit, rData, rCurExtHit
ParseHitboxExt_FindActiveHitboxes:
lwz r0, 0(rCurHit)
cmpwi r0, 0
beq ParseHitboxExt_FindActiveHitboxes_Next
mr r3, rCurExtHit
mr r4, rCurHit
cmplwi rExtHitTemplate, 0
bne ParseHitboxExt_FindActiveHitboxes_Copy
ParseHitboxExt_FindActiveHitboxes_Parse:
lwz r12, 0(rEventParse)
cmplwi r12, 0
beq ParseHitboxExt_FindActiveHitboxes_Next
mtlr r12
mr r5, rCmdData
blrl
mr rExtHitTemplate, r3
b ParseHitboxExt_FindActiveHitboxes_Next
ParseHitboxExt_FindActiveHitboxes_Copy:
subi r5, rExtHitTemplate, 4
subi r6, r3, 4
lwz r0, 0x00000004(rEventParse)
add r5, r5, r0
add r6, r6, r0
lwz r0, 0x00000008(rEventParse)
cmpwi r0, 0
beq- ParseHitboxExt_FindActiveHitboxes_Next
mtctr r0
ParseHitboxExt_FindActiveHitboxes_CopyLoop:
lwzu r0, 0x00000004(r5)
stwu r0, 0x00000004(r6)
bdnz+ ParseHitboxExt_FindActiveHitboxes_CopyLoop
lwz r12, 0x0000000C(rEventParse)
cmplwi r12, 0
beq ParseHitboxExt_FindActiveHitboxes_Next
mtlr r12
mr r5, rCmdData
blrl
ParseHitboxExt_FindActiveHitboxes_Next:
cmpwi rCurrentId, 0
blt- ParseHitboxExt_Exit
addi rCurrentId, rCurrentId, 1
cmplwi rCurrentId, 4
bne+ Advance
add rCurHit, rCurHit, rEightHitOff
Advance:
cmplwi rCurrentId, 8
add rCurHit, rCurHit, rHitStructSize
addi rCurExtHit, rCurExtHit, 84
blt+ ParseHitboxExt_FindActiveHitboxes
ParseHitboxExt_Exit:
epilog
blr
OriginalExit_801510E0:
fmr f3, f1
gecko 2147955480
bl CustomFighterCmdHandler_Start
_customCmdTable:
blrl
data.table customCmdTable
errata.new e
errata.mode e, stack, solve_iter
customCmdTable.__start = .
0:
.4byte 0x3AEA0C00
.4byte e$0
1:
.4byte 0x3BEF0800
.4byte e$1
2:
.4byte 0x3CF10800
.4byte e$2
3:
.4byte 0x3DF50400
.4byte e$3
4:
.4byte 0x3EF80800
.4byte e$4
customCmdTable.__count = (. - customCmdTable.__start) / 8
CustomCmd_SetVecTargetPos:
e.solve CustomCmd_SetVecTargetPos - ((8 * 0) + _data.table)
prolog xParseFunc, (0x00000004), xStartCopyOff, (0x00000004), xNumVarsCopy, (0x00000004), xAfterCopyFunc, (0x00000004), xEventLen, (0x00000004), xApplyType, (0x00000004)
bl SetTargetPosCmd_Parse
mflr r0
stw r0, sp.xParseFunc(sp)
li r0, 52
stw r0, sp.xStartCopyOff(sp)
li r0, 6
stw r0, sp.xNumVarsCopy(sp)
li r0, 0
stw r0, sp.xAfterCopyFunc(sp)
li r0, 12
stw r0, sp.xEventLen(sp)
lwz r3, 0x00000008(r29)
lbz r0, 0x00000001(r3)
rlwinm r0, r0, 29, 30, 31
stw r0, sp.xApplyType(sp)
mr r3, r27
mr r4, r29
addi r5, sp, sp.xParseFunc
bla r12, 2148864224
epilog
blr
SetTargetPosCmd_Parse:
blrl
sp.push
sp.temp +2, ru, rl
regs (3), rExtHit, rNormHit, rCmdData
lhz r0, 0(r31)
cmplwi cr0, r0, 0x00000004
cmplwi cr1, r0, 0x00000006
lbz r0, 0x00000004(rCmdData)
beq cr0, SetTargetPosCmd_Parse_FighterBone
bne cr1, SetTargetPosCmd_Parse_Exit
SetTargetPosCmd_Parse_ItemBone:
cmplwi r0, 0
bne 0f
lwz r4, 0x00000028(r31)
b SetTargetPosCmd_Parse_StoreBoneJObj
0:
lwz r4, 0x00000BBC(r30)
cmplwi r4, 0
beq SetTargetPosCmd_Parse_Exit
rlwinm r0, r0, 2, 0, 29
b SetTargetPosCmd_Parse_GetBoneJObj
SetTargetPosCmd_Parse_FighterBone:
lwz r4, 0x000005E8(r30)
rlwinm r0, r0, 4, 0, 27
SetTargetPosCmd_Parse_GetBoneJObj:
lwzx r4, r4, r0
SetTargetPosCmd_Parse_StoreBoneJObj:
stw r4, 52(rExtHit)
lfs f1, 0xFFFF88C0(rtoc)
lhz r0, 0x00000005(rCmdData)
sth r0, sp.ru(sp)
lhz r0, 0x00000007(rCmdData)
sth r0, sp.rl(sp)
psq_l f0, sp.ru(sp), 0, 5
ps_mul f0, f1, f0
psq_st f0, 60(rExtHit), 0, 0
lhz r0, 0x00000009(rCmdData)
sth r0, sp.ru(sp)
psq_l f0, sp.ru(sp), 1, 5
fmuls f0, f1, f0
stfs f0, 68(rExtHit)
lbz r0, 0x0000000B(rCmdData)
cmplwi r0, 0
bf- eq, 0f
li r0, 1
0:
stw r0, 56(rExtHit)
lbz r0, 0x00000002(rCmdData)
li r4, 1
rlwimi r0, r4, 0, 1
stb r0, 72(rExtHit)
SetTargetPosCmd_Parse_Exit:
sp.pop
blr
CustomCmd_HitboxExtAdv:
e.solve CustomCmd_HitboxExtAdv - ((8 * 1) + _data.table)
li r3, 1
b HitboxExtCmd_Begin
CustomCmd_HitboxExtStd:
e.solve CustomCmd_HitboxExtStd - ((8 * 2) + _data.table)
li r3, 0
HitboxExtCmd_Begin:
prolog xParseFunc, (0x00000004), xStartCopyOff, (0x00000004), xNumVarsCopy, (0x00000004), xAfterCopyFunc, (0x00000004), xEventLen, (0x00000004), xApplyType, (0x00000004)
cmpwi r3, 1
bne ParseStandard
ParseAdvanced:
bl HitboxExtCmd_Advanced_Parse
mflr r3
li r4, 32
li r5, 4
li r6, 0
li r7, 8
lwz r8, 0x00000008(r29)
lbz r0, 0x00000001(r8)
rlwinm r8, r0, 29, 30, 31
b ParseSetupStack
ParseStandard:
bl HitboxExtCmd_Standard_Parse
mflr r3
li r4, 0
li r5, 5
bl HitboxExtCmd_Standard_Copy
mflr r6
li r7, 8
lwz r9, 0x00000008(r29)
lbz r0, 0x00000007(r9)
rlwinm. r8, r0, 1, 30, 30
bne ParseSetupStack
lbz r0, 0x00000001(r9)
rlwinm r8, r0, 28, 31, 31
ParseSetupStack:
stw r3, sp.xParseFunc(sp)
stw r4, sp.xStartCopyOff(sp)
stw r5, sp.xNumVarsCopy(sp)
stw r6, sp.xAfterCopyFunc(sp)
stw r7, sp.xEventLen(sp)
stw r8, sp.xApplyType(sp)
mr r3, r27
mr r4, r29
addi r5, sp, sp.xParseFunc
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
HitboxExtCmd_Advanced_Parse:
blrl
lbz r0, 0x00000007(r5)
stb r0, 44(r3)
blr
CustomCmd_SpecialFlags:
e.solve CustomCmd_SpecialFlags - ((8 * 3) + _data.table)
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
blr
CustomCmd_AttackCapsule:
e.solve CustomCmd_AttackCapsule - ((8 * 4) + _data.table)
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
mulli r5, r5, 84
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
blr

CustomFighterCmdHandler_Start:
lwz r12, 0(r3)
mflr r3
addi r3, r3, 0x00000004
bl CustomCmdTable_Find
cmplwi r3, 0
beq OriginalExit_80073318
load r4, 2147955500
CustomCmdTable_Handle:
sp.push
sp.temp +4, xCustomCmdTable, xExitPtr
stw r3, sp.xCustomCmdTable(sp)
stw r4, sp.xExitPtr(sp)
lwz r0, 0x00000004(r3)
add r0, r3, r0
mr r3, r27
mr r4, r29
mtlr r0
blrl
lwz r3, sp.xCustomCmdTable(sp)
lbz r0, 0x00000002(r3)
lwz r4, 0x00000008(r29)
add r0, r4, r0
stw r0, 0x00000008(r29)
lwz r12, sp.xExitPtr(sp)
mtctr r12
sp.pop
bctr
CustomCmdTable_Find:
li r0, "customCmdTable.__count"
mtctr r0
b CustomCmdTable_Find_Loop_Body
CustomCmdTable_Find_Loop:
addi r3, r3, 0x00000008
CustomCmdTable_Find_Loop_Body:
lbz r0, 0x00000000(r3)
cmpw r28, r0
bdnzf eq, CustomCmdTable_Find_Loop
beqlr
li r3, 0
blr
OriginalExit_80073318:

gecko 2150079164
lwz r12, 0(r3)
bl "_customCmdTable"
mflr r3
bl CustomCmdTable_Find
cmplwi r3, 0
beq OriginalExit_80279abc
load r4, 2147955500
b CustomCmdTable_Handle
OriginalExit_80279abc:

gecko.end
gecko 2147955760
bl "_customCmdTable"
mflr r3
bl CustomCmdTable_Find
cmplwi r3, 0
beq SubactionFastForward_OrigExit
load r4, 2147955792
b CustomCmdTable_Handle
SubactionFastForward_OrigExit:
subi r0, r28, 10
gecko 2147956084
bl "_customCmdTable"
mflr r3
bl CustomCmdTable_Find
cmplwi r3, 0
beq SubactionFastForwardPtr2_OrigExit
lwz r4, 0x00000008(r29)
lbz r0, 0x00000002(r3)
add r4, r4, r0
stw r4, 0x00000008(r29)
ba r12, 2147956104
SubactionFastForwardPtr2_OrigExit:
add r3, r31, r28
lwz r4, 0x00000008(r29)
gecko.end
