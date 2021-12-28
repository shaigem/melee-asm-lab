.include "punkpc.s"
punkpc ppc
# MH & CH Controlled by All Ports
# authors: @[]
# description: 
gecko 2148862136, lwz r6, 0x0000065C(r4)
gecko 2148887292, lwz r0, 0x0000065C(r6)
# MH/CH No Smooth Movement
# authors: @[]
# description: 
gecko 2148859064
data.start
CommonDataTable:
0:
.float 5.0
1:
.float 1.0
2:
.float 45.0
3:
.float 45.0
4:
.float 2.0
5:
.float 0.0174533
6:
.float 0.872665
data.struct 0, "", xMainMoveSpeed, xSecondaryMoveSpeed, xStartOffsetX, xStartOffsetY, xFreeMovementSpeed, xRadianOneDegree, xRadianFiftyDegrees
data.table masterHandData
0:
.float -1.6
1:
.float 3.25
data.struct 0, "", xHarauLoopXVel, xYubideppou2AnimRate
data.table crazyHandData
0:
.float 1.4
data.struct 0, "", xHarauLoopXVel
data.end r3
lfs f0, xStartOffsetX(r3)
stfs f0, 0x00000030(r31)
lfs f0, xStartOffsetY(r3)
stfs f0, 0x00000034(r31)
lfs f0, xSecondaryMoveSpeed(r3)
stfs f0, 0x00000028(r31)
lfs f0, xMainMoveSpeed(r3)
stfs f0, 0x0000002C(r31)
data.get r3, masterHandData
lfs f0, xYubideppou2AnimRate(r3)
stfs f0, 0x000000F4(r31)
lwz r0, 0x00000008(r4)
gecko.end
gecko 2148908832, fmuls f0, f0, f30
gecko 2148908844, fmuls f0, f0, f30
gecko 2148908856, fmuls f0, f0, f30
gecko 2148871032, nop
gecko 2148873080, nop
gecko 2148877640, nop
gecko 2148878824, nop
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
lfs f0, 0x0000002C(r30)
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
lfs f1, 0x00002340(r31)
bla r12, 2150785600
stfs f1, 0x00000060(sp)
lfs f1, 0x00002340(r31)
bla r12, 2150786004
fmr f3, f1
lfs f1, 0x0000002C(r31)
fmuls f3, f3, f1
lfs f2, 0x00000060(sp)
lfs f0, 0x000000D4(r30)
fmuls f2, f2, f0
fmuls f3, f3, f0
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
