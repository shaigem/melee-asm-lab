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
gecko 2147908028, li r4, 10500

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
blt+ OrigExit_8007127C
mr rHitboxId, r0
subi rHitboxId, rHitboxId, 4
mulli r3, rHitboxId, 312
addi rFtHitPtr, r3, 9248
OrigExit_8007127C:
add rFtHitPtr, rFighterData, rFtHitPtr
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
gecko.end
gecko.end
