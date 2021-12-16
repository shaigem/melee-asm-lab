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
data.struct 0, "", xMainMoveSpeed, xSecondaryMoveSpeed, xStartOffsetX, xStartOffsetY, xHarauLoopXVel
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
# MH/CH No Harau Movement
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
