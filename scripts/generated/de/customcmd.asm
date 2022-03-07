.include "punkpc.s"
punkpc ppc
# sushie's Custom Subaction Command Module
# authors: @["sushie"]
# description: 
gecko 2147955480
.zero 16
b OriginalExit_80073318
OriginalExit_80073318:
lwz r12, 0(r3)
gecko.end
