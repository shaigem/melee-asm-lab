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
