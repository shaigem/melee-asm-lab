.include "punkpc.s"
punkpc ppc
# MH/CH Vibrate on Hit
# authors: @["sushie"]
# description: Hands will vibrate on hit
gecko 2148068132
mr r3, r30
lwz r4, 0x00001860(r30)
lwz r5, 0x0000183C(r30)
lwz r6, 0x00000010(r30)
lwz r7, 0x000000E0(r30)
lfs f1, 0x00001960(r30)
bla r12, 2148074900
cmpwi r31, 0
gecko.end
