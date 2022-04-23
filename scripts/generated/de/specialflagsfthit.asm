.include "punkpc.s"
punkpc ppc
# Enable Special Flags for Fighter Hitboxes v2.0.0
# authors: @["sushie"]
# description: Lets you use special flags that are normally found in item hitboxes
gecko 2147978912
lbz r0, 0x00000042(r23)
rlwinm. r0, r0, 27, 31, 31
beq OriginalExit_80078ea0
lfs f1, 0x0000002C(r28)
lfs f0, 0x0000002C(r24)
fcmpu cr0, f1, f0
beq CanHit_80078ea0
b OriginalExit_80078ea0
CanHit_80078ea0:
ba r12, 2147979816
OriginalExit_80078ea0:
lbz r0, 0x00000134(r23)
gecko 2147979240
lbz r0, 0x00000042(r23)
rlwinm. r0, r0, 26, 31, 31
bne Exit_80078fe8
SkipShield:
ba r12, 2147979444
Exit_80078fe8:
rlwinm. r0, r3, 28, 31, 31
gecko 2147928524
mr r3, r29
prolog rHitStruct, rLoopCount
li rLoopCount, 0
mulli r0, rLoopCount, 312
lwz r3, 0x0000002C(r3)
add rHitStruct, r3, r0
Loop_8006c9cc:
addi r3, rHitStruct, 2324
bla r12, 2147519068
addi rLoopCount, rLoopCount, 1
cmplwi rLoopCount, 4
addi rHitStruct, rHitStruct, 312
blt+ Loop_8006c9cc
epilog
mr r3, r29
gecko 2147971632
lbz r4, 0x00000041(r27)
rlwinm. r4, r4, 30, 31, 31
li r4, 0
beq Exit_80077230
li r4, 5
Exit_80077230:

gecko 2147970308
lbz r4, 0x00000041(r30)
rlwinm. r4, r4, 31, 31, 31
li r4, 1
beq Exit_80076d04
li r4, 2
Exit_80076d04:

gecko 2150040972
lbz r5, 0x00000041(r26)
rlwinm. r5, r5, 29, 31, 31
li r5, 0
beq Exit_8027058C
li r5, 8
Exit_8027058C:

gecko.end
