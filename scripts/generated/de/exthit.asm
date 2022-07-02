.include "punkpc.s"
punkpc ppc
# sushie's Common ExtHit Functions
# authors: @["sushie"]
# description: 
gecko 2148864228
cmpwi r4, 343
beq- InitDefaultExtHit_OrigExit
lfs f0, 0xFFFF8870(rtoc)
stfs f0, 0(r3)
stfs f0, 4(r3)
stfs f0, 8(r3)
lfs f0, 0xFFFF8874(rtoc)
stfs f0, 12(r3)
li r0, 0
stw r0, 20(r3)
stw r0, 24(r3)
stw r0, 28(r3)
stw r0, 44(r3)
stw r0, 48(r3)
stw r0, 16(r3)
stw r0, 52(r3)
stw r0, 56(r3)
stw r0, 60(r3)
stw r0, 64(r3)
stw r0, 68(r3)
stw r0, 72(r3)
blr
InitDefaultExtHit_OrigExit:
lfs f2, 0xFFFFA4C4(rtoc)
gecko.end
gecko 2148864212
cmpwi r4, 343
beq- GetExtHit_OrigExit
cmplwi r3, 0
beq GetExtHit_Invalid
cmplwi r4, 0
beq GetExtHit_Invalid
stwu sp, 0xFFFFFFE8(sp)
li r0, 4
stw r0, 0x00000014(sp)
li r0, 4
mtctr r0
lhz r0, 0(r3)
lwz r3, 0x0000002C(r3)
cmplwi r0, 4
beq GetExtHit_Fighter
cmplwi r0, 6
beq GetExtHit_Item
b GetExtHit_Invalid
GetExtHit_Item:
addi r5, r3, 4404
stw r5, 0x00000010(sp)
addi r5, r3, 1492
addi r3, r3, 4048
li r0, 316
b GetExtHit
GetExtHit_Fighter:
addi r5, r3, 9692
stw r5, 0x00000010(sp)
addi r5, r3, 2324
addi r3, r3, 9248
li r0, 312
GetExtHit:
b GetExtHit_Comparison
GetExtHit_Loop:
add r5, r5, r0
addi r3, r3, 84
GetExtHit_Comparison:
cmplw r5, r4
bdnzf eq, GetExtHit_Loop
beq GetExtHit_Exit
lwz r5, 0x00000014(sp)
cmplwi r5, 0
beq GetExtHit_Invalid
mtctr r5
li r5, 0
stw r5, 0x00000014(sp)
lwz r5, 0x00000010(sp)
b GetExtHit_Loop
GetExtHit_Invalid:
li r3, 0
GetExtHit_Exit:
addi sp, sp, 0x00000018
blr
GetExtHit_OrigExit:
lwz r31, 0x0000002C(r3)
gecko.end
gecko 2147947144
mulli r3, r0, 84
addi r3, r3, 9248
add r3, r31, r3
bla r12, 2148864228
lwz r0, 0(r30)
gecko.end
