# generated with geckon
# MH & CH Controlled by All Ports
# authors: @[]
# description: 
.include "punkpc.s"
punkpc ppc

gecko 2148862136, lwz r6, 0x0000065C(r4)
# generated with geckon
# MH/CH No Smooth Movement
# authors: @[]
# description: 
.include "punkpc.s"
punkpc ppc

gecko 2148859064
data.start
CommonDataTable:
0:
.float 5.0
1:
.float 2.0
2:
.float 50.0
3:
.float 50.0
4:
.float -1.4
5:
.float 2.0
data.struct 0, "", xMainMoveSpeed, xSecondaryMoveSpeed, xStartOffsetX, xStartOffsetY, xHarauLoopXVel, xFreeMovementSpeed
data.end r3
lfs f0, xStartOffsetX(r3)
stfs f0, 0x00000030(r31)
lfs f0, xStartOffsetY(r3)
stfs f0, 0x00000034(r31)
lfs f0, xSecondaryMoveSpeed(r3)
stfs f0, 0x00000028(r31)
lfs f0, xMainMoveSpeed(r3)
stfs f0, 0x0000002C(r31)
lwz r0, 0x00000008(r4)
gecko.end
gecko 2148908832, fmuls f0, f0, f30
gecko 2148908844, fmuls f0, f0, f30
gecko 2148908856, fmuls f0, f0, f30
gecko 2148871032, nop
gecko 2148873080, nop
gecko 2148877640, nop
gecko 2148878824, nop
# generated with geckon
# MH/CH Harau Movement Fix
# authors: @[]
# description: 
.include "punkpc.s"
punkpc ppc

gecko 2148866736
bla r12, 2148028724
data.table CommonDataTable
data.end r4
lfs f0, xHarauLoopXVel(r4)
lfs f1, 0x00000080(r3)
fadds f0, f1, f0
stfs f0, 0x00000080(r3)
gecko.end
# generated with geckon
# MH/CH Free Movement
# authors: @[]
# description: 
.include "punkpc.s"
punkpc ppc

gecko 2148860580, nop
gecko 2148860584, nop
gecko 2148859532, nop
gecko 2148859536, nop
gecko 2148862064
prolog rFighterData
bla r12, 2148028724
mr rFighterData, r3
data.table CommonDataTable
data.end r3
lfs f1, xFreeMovementSpeed(r3)
lfs f2, 0xFFFFA4AC(rtoc)
lfs f0, 0x00000620(rFighterData)
fcmpo cr0, f2, f1
beq SetVelY_FreeMovement
fmuls f0, f0, f1
lfs f1, 0x00000080(rFighterData)
fadds f0, f1, f0
stfs f0, 0x00000080(rFighterData)
SetVelY_FreeMovement:
lfs f0, 0x00000624(rFighterData)
fcmpo cr0, f2, f0
beq Exit_FreeMovement
lfs f1, xFreeMovementSpeed(r3)
fmuls f0, f0, f1
lfs f1, 0x00000084(rFighterData)
fadds f0, f1, f0
stfs f0, 0x00000084(rFighterData)
Exit_FreeMovement:
epilog
blr
gecko 2148862096
prolog rFighterGObj, rFighterData
bla r12, 2148028724
lwz r3, 0(r3)
bla r12, 2148015372
epilog
blr
gecko.end
