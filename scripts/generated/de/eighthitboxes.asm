.include "punkpc.s"
punkpc ppc
# Enable Eight Hitboxes
# authors: @["sushie"]
# description: Enables up to 8 active hitboxes for Melee
gecko 2150076664
regs (0), rItemData, (29), rItHitPtr
cmplwi r4, 4
blt+ OrigExit_802790F8
subi r29, r4, 4
mulli r29, r29, 316
addi r29, r29, 4464
OrigExit_802790F8:
add rItHitPtr, rItemData, rItHitPtr
gecko 2150061460
regs (4), rHitboxId
cmplwi rHitboxId, 4
mulli rHitboxId, rHitboxId, 316
blt+ OrigExit_80275594
addi rHitboxId, rHitboxId, 1708
OrigExit_80275594:

gecko 2150078004
regs (4), rHitboxId, rItHitPtr
cmplwi rHitboxId, 4
addi rItHitPtr, rItHitPtr, 1492
blt+ OrigExit_80279634
addi rItHitPtr, rItHitPtr, 1708
OrigExit_80279634:

gecko 2150077840
regs (3), rHitboxId
cmplwi rHitboxId, 4
mulli rHitboxId, rHitboxId, 316
blt+ OrigExit_80279590
addi rHitboxId, rHitboxId, 1708
OrigExit_80279590:

gecko 2150049124
regs (4), rHitboxId
cmplwi rHitboxId, 4
mulli rHitboxId, rHitboxId, 316
blt+ OrigExit_80272564
addi rHitboxId, rHitboxId, 1708
OrigExit_80272564:

gecko 2150049416
regs (4), rHitboxId
cmplwi rHitboxId, 4
mulli r30, rHitboxId, 316
blt+ OrigExit_80272688
addi r30, r30, 1708
OrigExit_80272688:
gecko 2150062284
addi r3, r3, 2024
li r0, 4
mtctr r0
Loop_802758cc:
lwz r0, 1808(r3)
addi r3, r3, 316
cmpwi r0, 0
bdnzt+ eq, Loop_802758cc
li r3, 0
beq Exit_802758cc
li r3, 1
Exit_802758cc:

gecko 2150062388
addi r3, r3, 2024
li r0, 4
mtctr r0
Loop_80275934:
lwz r0, 1808(r3)
addi r3, r3, 316
cmpwi r0, 0
bdnzt+ eq, Loop_80275934
li r0, 0
beq Exit_80275934
li r0, 1
Exit_80275934:

gecko 2150062528, beq 0x00000018
gecko 2150062544, bne 0x00000008
gecko 2150062552
addi r3, r3, 2024
li r7, 5
Loop_802759d8:
subic. r7, r7, 1
beqlr
lwz r0, 0x00000710(r3)
addi r5, r3, 1808
addi r3, r3, 316
cmpwi r0, 0
beq Loop_802759d8
lfs f0, 0x0000000C(r5)
fcmpo cr0, f1, f0
cror 2, 0, 2
bne Loop_802759d8
fmr f1, f0
b Loop_802759d8
gecko 2150061612, beq 0x00000010
gecko 2150061628
addi r3, r3, 2024
li r7, 5
Loop_8027563c:
subic. r7, r7, 1
beqlr
lwz r0, 0x00000710(r3)
addi r4, r3, 1808
addi r3, r3, 316
cmpwi r0, 0
beq Loop_8027563c
lfs f0, 0x0000001C(r4)
fmuls f0, f0, f1
stfs f0, 0x0000001C(r4)
b Loop_8027563c
gecko 2150061448, beq 0x00000008
gecko 2150061456
addi r3, r3, 2024
li r0, 4
mtctr r0
Loop_80275590:
lwz r0, 1808(r3)
addi r4, r3, 1808
addi r3, r3, 316
cmpwi r0, 0
beq CheckToLoop
stfs f1, 0x0000001C(r4)
CheckToLoop:
bdnz+ Loop_80275590
Exit_80275590:
blr
gecko 2150039084
addi r5, r5, 2024
li r7, 5
Loop_8026fe2c:
subic. r7, r7, 1
li r0, 0
beq- Exit_8026fe2c
addi r3, r5, 1808
cmplw r3, r30
addi r5, r5, 316
beq Loop_8026fe2c
lwz r0, 0(r3)
cmpwi r0, 0
beq Loop_8026fe2c
lwz r4, 0x00000004(r3)
lwz r0, 0x00000004(r30)
cmplw r4, r0
bne Loop_8026fe2c
mr r4, r30
bla r12, 2147517692
li r0, 1
Exit_8026fe2c:
gecko 0x8026ED70
cmplwi r27, 4
bne+ OrigExit_8026ED70
addi r28, r28, 1708
OrigExit_8026ED70:
addi r3, r28, 1492
gecko 0x8026ED88, cmplwi r27, 8
gecko 0x8027139C
cmplwi r28, 4
bne+ OrigExit_8027139C
addi r31, r31, 1708
OrigExit_8027139C:
addi r29, r31, 1492
gecko 0x8027144C, cmplwi r28, 8
gecko 2148250176
mr r29, r4
stw r4, 0x00000010(sp)
gecko 2148250600
cmplwi r31, 4
addi r25, r29, 1492
bgt UseNewOffsets_800BB3E8
bne+ OrigExit_800BB3E8
lwz r29, 0x10(sp)
addi r29, r29, 4464
UseNewOffsets_800BB3E8:
mr r25, r29
lwz r0, 0(r25)
OrigExit_800BB3E8:

gecko 2148250856, cmplwi r31, 8
gecko 2148250880
cmplwi r31, 4
addi r25, r29, 1492
bgt UseNewOffsets_800BB500
bne+ OrigExit_800BB500
lwz r29, 0x10(sp)
addi r29, r29, 4464
UseNewOffsets_800BB500:
mr r25, r29
lwz r0, 0(r25)
OrigExit_800BB500:

gecko 2148251156, cmplwi r31, 8
gecko 2148251196
cmplwi r27, 4
addi r25, r26, 1492
bgt UseNewOffsets_800BB63C
bne+ OrigExit_800BB63C
lwz r26, 0x10(sp)
addi r26, r26, 4464
UseNewOffsets_800BB63C:
mr r25, r26
lwz r0, 0(r25)
OrigExit_800BB63C:

gecko 2148251452, cmplwi r27, 8
gecko 0x8026A020
cmplwi r28, 4
bne+ OrigExit_8026A020
addi r29, r29, 1708
OrigExit_8026A020:
lwz r0, 1492(r29)
gecko 0x8026A074, cmplwi r28, 8
gecko 0x80270938
cmplwi r18, 4
blt+ OrigExit_80270938
addi r23, r23, 1708
OrigExit_80270938:
addi r4, r23, 1492
gecko 0x80270A1C, cmplwi r18, 8
gecko 0x8026FA5C
cmplwi r28, 4
bne+ OrigExit_8026FA5C
addi r30, r30, 1708
OrigExit_8026FA5C:
lwz r0, 1492(r30)
gecko 0x8026FAA0, cmplwi r28, 8
gecko 0x80275670
cmplwi r30, 4
bne+ OrigExit_80275670
addi r31, r31, 1708
OrigExit_80275670:
lwz r0, 1492(r31)
gecko 0x802756A0, cmplwi r30, 8
gecko 0x8026FB24
cmplwi r25, 4
bne+ OrigExit_8026FB24
addi r24, r24, 1708
OrigExit_8026FB24:
lwz r0, 1492(r24)
gecko 0x8026FB68, cmplwi r25, 8
gecko 0x8026FC54
cmplwi r27, 4
bne+ OrigExit_8026FC54
addi r26, r26, 1708
OrigExit_8026FC54:
lwz r0, 1492(r26)
gecko 0x8026FC84, cmplwi r27, 8
gecko 0x8026FCA8
cmplwi r27, 4
bne+ OrigExit_8026FCA8
addi r26, r26, 1708
OrigExit_8026FCA8:
lwz r0, 1492(r26)
gecko 0x8026FCD8, cmplwi r27, 8
gecko 2150049284
cmplwi r29, 4
addi r3, r31, 1492
bgt UseNewOffsets_80272604
bne+ OrigExit_80272604

addi r31, r30, 4464
UseNewOffsets_80272604:
mr r3, r31
OrigExit_80272604:

gecko 2150049296, cmplwi r29, 8
gecko 2150049328, cmplwi r31, 8
gecko 2150044320
mr r5, r4
mulli r4, r4, 316
gecko 2150044340
regs (5), rHitboxId, (30), rItHitPtr
cmplwi rHitboxId, 4
addi rItHitPtr, r4, 1492
blt+ OrigExit_802712b4
subi r30, r5, 4
mulli r30, r30, 316
addi r30, r30, 4464
OrigExit_802712b4:

gecko 2150038244
addi r31, r7, 0
stw r27, 0x00000020(sp)
gecko 2150038428
cmplwi r25, 4
addi r3, r23, 1492
bgt UseNewOffsets_8026FB9C
bne+ OrigExit_8026FB9C
lwz r23, 0x20(sp)
addi r23, r23, 4464
UseNewOffsets_8026FB9C:
mr r3, r23
lwz r0, 0(r3)
OrigExit_8026FB9C:

gecko 2150038492, cmplwi r25, 8
gecko 2147980332
cmplwi r28, 4
addi r23, r29, 1492
bgt UseNewOffsets_8007942C
bne+ OrigExit_8007942C

addi r29, r24, 4464
UseNewOffsets_8007942C:
mr r23, r29
lwz r0, 0(r23)
OrigExit_8007942C:

gecko 2147981948, cmplwi r28, 8
gecko 2150041608
cmplwi r20, 4
lwz r0, 0x000005D4(r23)
bgt UseNewOffsets_80270808
bne+ OrigExit_80270808
addi r23, r31, 4464
UseNewOffsets_80270808:
mr r3, r23
lwz r0, 0(r3)
OrigExit_80270808:

gecko 2150041728, cmplwi r20, 8
gecko 2150041756
cmplwi r20, 4
addi r19, r21, 1492
bgt UseNewOffsets_8027089C
bne+ OrigExit_8027089C

addi r21, r27, 4464
UseNewOffsets_8027089C:
mr r19, r21
lwz r0, 0(r19)
OrigExit_8027089C:

gecko 2150042788, cmplwi r20, 8
gecko 2150044812
add r31, r3, r0
stw r3, 0x0000000C(sp)
gecko 2150044816
cmplwi r30, 4
addi r3, r31, 1492
bgt UseNewOffsets_80271490
bne+ OrigExit_80271490
lwz r31, 0xC(sp)
addi r31, r31, 4464
UseNewOffsets_80271490:
mr r3, r31
OrigExit_80271490:

gecko 2150044828, cmplwi r30, 8
gecko 2150040220
cmplwi r26, 4
lwz r0, 0x000005D4(r27)
bgt UseNewOffsets_8027029C
bne+ OrigExit_8027029C
addi r27, r31, 4464
UseNewOffsets_8027029C:
mr r3, r27
lwz r0, 0(r3)
OrigExit_8027029C:

gecko 2150040508, cmplwi r26, 8
gecko.end
gecko 2147947140
regs (3), rHitboxId, (30), rFtHitPtr, rFighterData
cmplwi r0, 4
blt+ OrigExit_80071284
mr rHitboxId, r0
subi r30, r3, 4
mulli r30, r30, 312
addi r30, r30, 9716
OrigExit_80071284:
add rFtHitPtr, rFighterData, rFtHitPtr
gecko 2147969412
li r7, 4
addi r6, r3, 9092
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
addi rNextHitOff, rNextHitOff, 9716
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
addi r3, r3, 9716
OrigExit_80071660:
add r3, r6, r3
gecko 2147948244
cmplwi r0, 4
blt+ OrigExit_800716d4
regs (5), rFtHitSizePtr
mr rFtHitSizePtr, r0
subi rFtHitSizePtr, rFtHitSizePtr, 4
mulli rFtHitSizePtr, rFtHitSizePtr, 312
addi r0, rFtHitSizePtr, 9744
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
addi r5, rFtHitPtr, 9716
OrigExit_80071724:
rlwinm r0, r3, 31, 31, 31
gecko 2147978632
cmplwi r23, 4
addi r4, r30, 2324
bgt UseNewOffsets_80078D88
bne+ OrigExit_80078D88

addi r30, r28, 9716
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

addi r29, r24, 9716
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

addi r23, r26, 9716
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

addi r24, r26, 9716
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
addi r22, r27, 9716
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

addi r20, r27, 9716
UseNewOffsets_8007968C:
mr r4, r20
OrigExit_8007968C:

gecko 2147981128, cmplwi r19, 8
gecko 2150040772
cmplwi r27, 4
addi r26, r31, 2324
bgt UseNewOffsets_802704C4
bne+ OrigExit_802704C4

addi r31, r28, 9716
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
addi r30, r30, 9716
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

addi r27, r29, 9716
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

addi r24, r30, 9716
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

addi r19, r28, 9716
UseNewOffsets_80078F7C:
mr r16, r19
OrigExit_80078F7C:

gecko 2147979204, cmplwi r18, 8
gecko 2147969988
cmplwi r26, 4
addi r3, r23, 2324
bgt UseNewOffsets_80076BC4
bne+ OrigExit_80076BC4

addi r23, r28, 9716
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

addi r24, r30, 9716
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
addi r31, r30, 9716
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
addi r27, r31, 9716
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
addi r31, r31, 9716
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
addi rNextHitOff, rNextHitOff, 9716
OrigExit_8007b078:

gecko 2147987488
cmplwi r29, 4
addi r3, r31, 2324
bgt UseNewOffsets_8007B020
bne+ OrigExit_8007B020

addi r31, r30, 9716
UseNewOffsets_8007B020:
mr r3, r31
OrigExit_8007B020:

gecko 2147987500, cmplwi r29, 8
gecko 2147987116
cmplwi r29, 4
addi r4, r31, 2324
bgt UseNewOffsets_8007AEAC
bne+ OrigExit_8007AEAC

addi r31, r30, 9716
UseNewOffsets_8007AEAC:
mr r4, r31
OrigExit_8007AEAC:

gecko 2147987128, cmplwi r29, 8
gecko 2148009492
cmplwi r25, 4
addi r3, r26, 2324
bgt UseNewOffsets_80080614
bne+ OrigExit_80080614

addi r26, r31, 9716
UseNewOffsets_80080614:
mr r3, r26
OrigExit_80080614:

gecko 2148009516, cmplwi r25, 8
gecko.end
gecko.end
