.include "punkpc.s"
punkpc ppc
# MH/CH Control with Any Port
# authors: @["sushie", "Achilles1515"]
# description: Enables you to control MH/CH with any port instead of being restricted to ports 3 & 4
gecko 2148862136
regs rInputStructStart, rFighterData, (6), rInputStruct
lbz rInputStruct, 0x0000000C(rFighterData)
mulli rInputStruct, rInputStruct, 0x00000044
add rInputStruct, rInputStruct, rInputStructStart
lwz r6, 0(rInputStruct)
gecko.end
gecko 2148887292, lwz r0, 0x0000065C(r6)
# MH/CH No Lerp Movement
# authors: @[]
# description: 
gecko 2148859064
data.start
CommonDataTable:
0:
.float 5.0
1:
.float 3.0
2:
.float 2.0
3:
.float 0.0174533
4:
.float 93
5:
.float 42.0
data.struct 0, "", xMainMoveSpeed, xSecondaryMoveSpeed, xFreeMovementSpeed, xRadianOneDegree, xPaatsubusuStartFrame, xPaatsubusuStartY
data.table masterHandData
0:
.float -1.6
1:
.float 3.25
2:
.float 45.0
3:
.float 45.0
data.struct 0, "mh.", xHarauLoopXVel, xYubideppou2AnimRate, xStartOffsetX, xStartOffsetY
data.table crazyHandData
0:
.float 1.4
1:
.float -45.0
2:
.float -45.0
data.struct 0, "ch.", xHarauLoopXVel, xStartOffsetX, xStartOffsetY
data.end r3
lfs f0, xSecondaryMoveSpeed(r3)
stfs f0, 0x00000028(r31)
lfs f0, xMainMoveSpeed(r3)
stfs f0, 0x0000002C(r31)
lfs f0, xPaatsubusuStartY(r3)
stfs f0, 0x000000C0(r31)
data.get r3, masterHandData
lfs f0, mh.xStartOffsetX(r3)
stfs f0, 0x00000030(r31)
lfs f0, mh.xStartOffsetY(r3)
stfs f0, 0x00000034(r31)
lfs f0, mh.xYubideppou2AnimRate(r3)
stfs f0, 0x000000F4(r31)
lwz r0, 0x00000008(r4)
gecko 2148884072
data.table CommonDataTable
data.end r3
lfs f0, xSecondaryMoveSpeed(r3)
stfs f0, 0x00000010(r31)
lfs f0, xMainMoveSpeed(r3)
stfs f0, 0x00000014(r31)
data.get r3, crazyHandData
lwz r0, 0x00000008(r4)
gecko.end
gecko 2148908832, fmuls f0, f0, f30
gecko 2148908844, fmuls f0, f0, f30
gecko 2148908856, fmuls f0, f0, f30
gecko 2148871032, nop
gecko 2148870984, lfs f0, 0x00000028(r30)
gecko 2148873080, nop
gecko 2148877640, nop
gecko 2148877592, lfs f0, 0x00000028(r30)
gecko 2148878824, nop
gecko 2148868916, nop
gecko 2148892912, nop
gecko 2148892864, lfs f0, 0x00000010(r30)
gecko 2148896164, nop
gecko 2148896116, lfs f0, 0x00000010(r30)
gecko 2148897348, nop
# MH/CH Harau Movement Fix
# authors: @[]
# description: 
gecko 2148866736
bla r12, 2148028724
data.table CommonDataTable
data.end r4
data.get r4, masterHandData
lfs f1, xHarauLoopXVel(r4)
bl HarauMovementPatch
b OriginalExit_80151ab0
HarauMovementPatch:
lfs f0, 128(r3)
fadds f0, f1, f0
stfs f0, 128(r3)
blr
OriginalExit_80151ab0:

gecko 2148889432
mr r3, r31
data.table CommonDataTable
data.end r4
data.get r4, crazyHandData
lfs f1, xHarauLoopXVel(r4)
bl HarauMovementPatch
gecko.end
# MH/CH No Attack Startup
# authors: @[]
# description: 
gecko 2148862756
bla r12, 2148871116
gecko.end
# MH Point Gun Towards Target
# authors: @[]
# description: 
gecko 2148873032
lwz r3, 0(r31)
lfs f1, 0x00000028(r30)
bl RotTowardsTarget
b OriginalExit_801533ac
RotTowardsTarget:
prolog rSrcData, fRotSpeedMulti, xVec3, (0x0000000C)
lwz rSrcData, 0x0000002C(r3)
fmr fRotSpeedMulti, f1
regs (4), rTempVec
addi rTempVec, sp, sp.xVec3
lfs f0, 0xFFFFD688(rtoc)
stfs f0, 0(rTempVec)
stfs f0, 4(rTempVec)
stfs f0, 8(rTempVec)
lwz r5, 0x0000010C(rSrcData)
bla r12, 2148909576
lfs f4, 0(rTempVec)
lfs f3, 0x000000B0(rSrcData)
fsubs f2, f3, f4
lfs f4, 4(rTempVec)
lfs f3, 0x000000B4(rSrcData)
fsubs f1, f3, f4
bla r12, 2147626032
data.table CommonDataTable
data.end r3
lfs f3, xRadianOneDegree(r3)
fmuls f3, f3, fRotSpeedMulti
lfs f2, 0x00002340(r31)
lfs f4, 0xFFFFA818(rtoc)
fsubs f1, f1, f2
fcmpu cr0, f1, f4
bge- CurrentBiggerThanTarget_RotTowardsTarget
fneg f0, f1
b CheckCurrent_RotTowardsTarget
CurrentBiggerThanTarget_RotTowardsTarget:
fmr f0, f1
CheckCurrent_RotTowardsTarget:
fcmpo cr0, f0, f3
ble- ClampRot_RotTowardsTarget
fcmpu cr0, f1, f4
ble- MoveDown_RotTowardsTarget
fmr f0, f3
b AddToRot_RotTowardsTarget
MoveDown_RotTowardsTarget:
fneg f0, f3
AddToRot_RotTowardsTarget:
fadds f0, f2, f0
stfs f0, 0x00002340(rSrcData)
b Rotate_RotTowardsTarget
ClampRot_RotTowardsTarget:
fadds f1, f2, f1
stfs f1, 0x00002340(rSrcData)
Rotate_RotTowardsTarget:
lfs f1, 0x00002340(rSrcData)
mr r3, rSrcData
li r4, 0
bla r12, 2147965228
Epilog_RotTowardsTarget:
epilog
blr
OriginalExit_801533ac:
lfs f0, 0x00000028(r30)
gecko 2148872516
stw r0, 0x00002340(r31)
lwz r0, 0x0000003C(sp)
gecko 2148873296
lfs f1, 0x00002340(r31)
mr r3, r31
li r4, 0
bla r12, 2147965228
lwz r0, 0x00000024(sp)
gecko 2148873460
lfs f1, 0x00002340(r30)
mr r3, r30
li r4, 0
bla r12, 2147965228
mr r3, r29
gecko 2148873976
regs (1), fCurrentRot, fXVel, fYVel
lfs fCurrentRot, 0x00002340(r31)
bla r12, 2150786004
fmr f31, f1
lfs fCurrentRot, 0x00002340(r31)
bla r12, 2150785600
fmr fXVel, f1
fmr fYVel, f31
lfs f1, 0x0000002C(r31)
fmuls fYVel, fYVel, f1
lfs f0, 0x000000D4(r30)
fmuls fXVel, fXVel, f0
fmuls fYVel, fYVel, f0
mr r3, r28
mr r7, r29
addi r4, sp, 40
gecko 2150566784
addi r31, r3, 0
lwz r3, 0x0000002C(r30)
lwz r3, 0x00002340(r3)
lwz r4, 0x00000028(r31)
stw r3, 0x0000001C(r4)
gecko 2150567072, nop
gecko 2150567396, nop
gecko.end
# MH/CH Paatsubusu Uses Gootsubusu Action States
# authors: @[]
# description: 
gecko 2148869032
lwz r3, 0x0000002C(r31)
li r0, 357
stw r0, 9108(r3)
li r0, 0
stw r0, 9104(r3)
lwz r0, 0x0000001C(sp)
gecko 2148890912
lwz r3, 0x0000002C(r31)
li r0, 353
stw r0, 9108(r3)
li r0, 0
stw r0, 9104(r3)
lwz r0, 0x0000001C(sp)
gecko 2148869896
bla r12, 2148868976
li r3, 358
stw r3, 9108(r31)
data.table CommonDataTable
data.end r3
lfs f0, xPaatsubusuStartFrame(r3)
stfs f0, 9104(r31)
ba r12, 2148869912
gecko 2148891776
bla r12, 2148890856
li r3, 354
stw r3, 9108(r31)
data.table CommonDataTable
data.end r3
lfs f0, xPaatsubusuStartFrame(r3)
stfs f0, 9104(r31)
ba r12, 2148891792
gecko 2148869644
lwz r4, 9108(r5)
lfs f1, 9104(r5)
li r5, 0
gecko 2148891524
lwz r4, 9108(r5)
lfs f1, 9104(r5)
li r5, 0
gecko 2148870132, fmr f1, f0
gecko 2148892012, fmr f1, f0
gecko.end
# CH Uses His Own Lasers
# authors: @[]
# description: 
gecko 2148894084, li r7, 0x7F
gecko 2148894136, li r7, 0x7F
gecko 2148894188, li r7, 0x7F
gecko 2148894240, li r7, 0x7F
