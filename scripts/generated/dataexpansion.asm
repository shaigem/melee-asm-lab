.include "punkpc.s"
punkpc ppc
# sushie's Ft/ItData Expansion
# authors: @["sushie"]
# description: Must be on for codes like Hitbox Extension & 8Box to work
gecko 2147913452
addi r30, r3, 0
load r4, 2152042448
lwz r4, 0x00000020(r4)
bla r12, 2147533152
mr r3, r30
lis r4, 0x00008046
gecko 2147908028, li r4, 10676
gecko 2150002648, li r4, 5476
gecko 2150008660
addi r29, r3, 0
li r4, 5476
bla r12, 2147533152
mr r3, r29
mr. r6, r3
gecko.end