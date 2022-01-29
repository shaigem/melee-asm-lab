.include "punkpc.s"
punkpc ppc
# Eight Hitboxes
# authors: @[]
# description: 
gecko 2147913452

addi r30, r3, 0
load r4, 2152042448
lwz r4, 0x00000020(r4)
bla r12, 2147533152
mr r3, r30
lis r4, 0x00008046
gecko 2147908028, li r4, 10496

gecko.end
gecko 2150002648, li r4, 5312
gecko 2150008660
addi r29, r3, 0
li r4, 5312
bla r12, 2147533152
mr r3, r29
mr. r6, r3
gecko.end
gecko 2147947140
regs rHitboxId, (30), rFtHitPtr, rFighterData
cmplwi r0, 4
blt+ OrigExit_80071284
mr rHitboxId, r0
subi r30, r3, 4
mulli r30, r30, 312
addi r30, r30, 9248
OrigExit_80071284:
add rFtHitPtr, rFighterData, rFtHitPtr
gecko 2150076664
regs (0), rItemData, (29), rItHitPtr
cmplwi r4, 4
blt+ OrigExit_802790F8
subi r29, r4, 4
mulli r29, r29, 316
addi r29, r29, 4048
OrigExit_802790F8:
add rItHitPtr, rItemData, rItHitPtr
gecko 2147969412
li r7, 4
addi r6, r3, 8624
b LoopBody_80076984
Loop_80076984:
subic. r7, r7, 1
beq- InitVictimArray_80076984
addi r6, r6, 312
LoopBody_80076984:
cmplw r6, r4
beq Loop_80076984
lwz r0, 0(r6)
cmpwi r0, 0
beq Loop_80076984
lwz r5, 0x00000004(r6)
lwz r0, 0x00000004(r4)
cmplw r5, r0
bne Loop_80076984
mr r3, r6
bla r12, 2147517692
InitVictimArray_80076984:
mr r3, r4
gecko 2147987404
regs (3), rGObj, rHitboxId
cmplwi rHitboxId, 4
blt+ Exit_8007afcc
lwz r3, 0x0000002C(rGObj)
subi rHitboxId, rHitboxId, 4
mulli r4, rHitboxId, 312
regs (3), rData, rNextHitOff
addi rNextHitOff, rNextHitOff, 9248
add rNextHitOff, rNextHitOff, rData
li r0, 0
stw r0, 0(rNextHitOff)
blr
Exit_8007afcc:
mulli rHitboxId, rHitboxId, 312
gecko 2147948128
cmplwi r0, 4
blt+ OrigExit_80071660
mr r3, r0
subi r3, r3, 4
mulli r3, r3, 312
addi r3, r3, 9248
OrigExit_80071660:
add r3, r6, r3
gecko 2147948244
cmplwi r0, 4
blt+ OrigExit_800716d4
regs (5), rFtHitSizePtr
mr rFtHitSizePtr, r0
subi rFtHitSizePtr, rFtHitSizePtr, 4
mulli rFtHitSizePtr, rFtHitSizePtr, 312
addi r0, rFtHitSizePtr, 9276
b Exit_800716d4
OrigExit_800716d4:
addi r0, r5, 2352
Exit_800716d4:

gecko 2147948328, nop
gecko 2147948324
cmplwi r0, 4
addi r5, r5, 2324
blt+ OrigExit_80071724
regs (5), rFtHitPtr
mr rFtHitPtr, r0
subi rFtHitPtr, rFtHitPtr, 4
mulli rFtHitPtr, rFtHitPtr, 312
addi r5, rFtHitPtr, 9248
OrigExit_80071724:
rlwinm r0, r3, 31, 31, 31
gecko.end
gecko 2148009492
cmplwi r25, 4
addi r3, r26, 2324
bgt UseNewOffsets_80080614
bne+ OrigExit_80080614

addi r26, r31, 9248
UseNewOffsets_80080614:
mr r3, r26

OrigExit_80080614:

gecko 2148009516, cmplwi r25, 8
gecko 2150034800
cmplwi r27, 4
addi r3, r28, 1492
bgt UseNewOffsets_8026ED70
bne+ OrigExit_8026ED70

addi r28, r31, 4048
UseNewOffsets_8026ED70:
mr r3, r28

OrigExit_8026ED70:

gecko 2150034824, cmplwi r27, 8
gecko.end
gecko 2147987116
cmplwi r29, 4
addi r4, r31, 2324
bgt UseNewOffsets_8007AEAC
bne+ OrigExit_8007AEAC

addi r31, r30, 9248
UseNewOffsets_8007AEAC:
mr r4, r31

OrigExit_8007AEAC:

gecko 2147987128, cmplwi r29, 8
gecko 2150044572
cmplwi r28, 4
addi r29, r31, 1492
bgt UseNewOffsets_8027139C
bne+ OrigExit_8027139C

li r31, 4048
UseNewOffsets_8027139C:
mr r29, r31

OrigExit_8027139C:

gecko 2150044748, cmplwi r28, 8
gecko.end
gecko 2147987488
cmplwi r29, 4
addi r3, r31, 2324
bgt UseNewOffsets_8007B020
bne+ OrigExit_8007B020

addi r31, r30, 9248
UseNewOffsets_8007B020:
mr r3, r31

OrigExit_8007B020:

gecko 2147987500, cmplwi r29, 8
gecko.end
gecko 2147978632
cmplwi r23, 4
addi r4, r30, 2324
bgt UseNewOffsets_80078D88
bne+ OrigExit_80078D88

addi r30, r28, 9248
UseNewOffsets_80078D88:
mr r4, r30
lwz r0, 0(r4)
OrigExit_80078D88:

gecko 2147978796, cmplwi r23, 8
gecko 2147978824
cmplwi r30, 4
addi r23, r29, 2324
bgt UseNewOffsets_80078E48
bne+ OrigExit_80078E48

addi r29, r24, 9248
UseNewOffsets_80078E48:
mr r23, r29
lwz r0, 0(r23)
OrigExit_80078E48:

gecko 2147979820, cmplwi r30, 8
gecko 2147971600
cmplwi r25, 4
addi r3, r23, 2324
bgt UseNewOffsets_80077210
bne+ OrigExit_80077210

addi r23, r26, 9248
UseNewOffsets_80077210:
mr r3, r23
lwz r0, 0(r3)
OrigExit_80077210:

gecko 2147971644, cmplwi r25, 8
gecko 2147971180
cmplwi r30, 4
addi r3, r24, 2324
bgt UseNewOffsets_8007706C
bne+ OrigExit_8007706C

addi r24, r26, 9248
UseNewOffsets_8007706C:
mr r3, r24
lwz r0, 0(r3)
OrigExit_8007706C:

gecko 2147971224, cmplwi r30, 8
gecko 2147980156
cmplwi r20, 4
lwz r0, 0x00000914(r22)
bgt UseNewOffsets_8007937C
bne+ OrigExit_8007937C
addi r22, r27, 9248
UseNewOffsets_8007937C:
mr r3, r22
lwz r0, 0(r3)
OrigExit_8007937C:

gecko 2147980304, cmplwi r20, 8
gecko 2147980940
cmplwi r19, 4
addi r4, r20, 2324
bgt UseNewOffsets_8007968C
bne+ OrigExit_8007968C

addi r20, r27, 9248
UseNewOffsets_8007968C:
mr r4, r20

OrigExit_8007968C:

gecko 2147981128, cmplwi r19, 8
gecko 2150040772
cmplwi r27, 4
addi r26, r31, 2324
bgt UseNewOffsets_802704C4
bne+ OrigExit_802704C4

addi r31, r28, 9248
UseNewOffsets_802704C4:
mr r26, r31
lwz r0, 0(r26)
OrigExit_802704C4:

gecko 2150041248, cmplwi r27, 8
gecko 2147969064
addi r30, r3, 0
stw r30, 0x00000010(sp)
gecko 2147969084
cmplwi r28, 4
addi r3, r30, 2324
bgt UseNewOffsets_8007683C
bne+ OrigExit_8007683C
lwz r30, 0x10(sp)
addi r30, r30, 9248
UseNewOffsets_8007683C:
mr r3, r30
lwz r0, 0(r3)
OrigExit_8007683C:

gecko 2147969148, cmplwi r28, 8
gecko 2147970276
cmplwi r28, 4
addi r3, r27, 2324
bgt UseNewOffsets_80076CE4
bne+ OrigExit_80076CE4

addi r27, r29, 9248
UseNewOffsets_80076CE4:
mr r3, r27
lwz r0, 0(r3)
OrigExit_80076CE4:

gecko 2147970320, cmplwi r28, 8
gecko 2147969656
cmplwi r26, 4
addi r3, r24, 2324
bgt UseNewOffsets_80076A78
bne+ OrigExit_80076A78

addi r24, r30, 9248
UseNewOffsets_80076A78:
mr r3, r24
lwz r0, 0(r3)
OrigExit_80076A78:

gecko 2147969712, cmplwi r26, 8
gecko 2147979132
cmplwi r18, 4
addi r16, r19, 2324
bgt UseNewOffsets_80078F7C
bne+ OrigExit_80078F7C

addi r19, r28, 9248
UseNewOffsets_80078F7C:
mr r16, r19

OrigExit_80078F7C:

gecko 2147979204, cmplwi r18, 8
gecko 2147969988
cmplwi r26, 4
addi r3, r23, 2324
bgt UseNewOffsets_80076BC4
bne+ OrigExit_80076BC4

addi r23, r28, 9248
UseNewOffsets_80076BC4:
mr r3, r23
lwz r0, 0(r3)
OrigExit_80076BC4:

gecko 2147970032, cmplwi r26, 8
gecko 2147973708
cmplwi r26, 4
addi r3, r24, 2324
bgt UseNewOffsets_80077A4C
bne+ OrigExit_80077A4C

addi r24, r30, 9248
UseNewOffsets_80077A4C:
mr r3, r24
lwz r0, 0(r3)
OrigExit_80077A4C:

gecko 2147973764, cmplwi r26, 8
gecko 2147978000
cmplwi r27, 4
lwz r0, 0x00000914(r31)
bgt UseNewOffsets_80078B10
bne+ OrigExit_80078B10
addi r31, r30, 9248
UseNewOffsets_80078B10:
mr r3, r31
lwz r0, 0(r3)
OrigExit_80078B10:

gecko 2147978304, cmplwi r27, 8
gecko 2147990784
cmplwi r26, 4
lwz r0, 0x00000914(r27)
bgt UseNewOffsets_8007BD00
bne+ OrigExit_8007BD00
addi r27, r31, 9248
UseNewOffsets_8007BD00:
mr r3, r27
lwz r0, 0(r3)
OrigExit_8007BD00:

gecko 2147991052, cmplwi r26, 8
gecko 2148249900
li r30, 0
stw r4, 0x00000010(sp)
gecko 2148249912
cmplwi r30, 4
addi r29, r31, 2324
bgt UseNewOffsets_800BB138
bne+ OrigExit_800BB138
lwz r31, 0x10(sp)
addi r31, r31, 9248
UseNewOffsets_800BB138:
mr r29, r31
lwz r0, 0(r29)
OrigExit_800BB138:

gecko 2148250100, cmplwi r30, 8
gecko 2147987560
mr r5, r4
mulli r4, r4, 312
gecko 2147987576
regs (5), rHitboxId, (31), rNextHitOff
cmplwi rHitboxId, 4
addi rNextHitOff, r4, 2324
blt+ OrigExit_8007b078
subi rNextHitOff, rHitboxId, 4
mulli rNextHitOff, rNextHitOff, 312
addi rNextHitOff, rNextHitOff, 9248
OrigExit_8007b078:

gecko.end
gecko.end
