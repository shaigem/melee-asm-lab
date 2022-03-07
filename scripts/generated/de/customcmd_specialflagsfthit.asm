.include "punkpc.s"
punkpc ppc
# [cmd_mod] Special Properties FtHit
# authors: @["sushie"]
# description: 
cmpwi r28, 0x0000003D
bne+ SpecialPropFtHitCmd_Exit
lwz r3, 0x00000008(r29)
lbz r4, 0x00000001(r3)
rlwinm r4, r4, 27, 29, 31
lbz r7, 0x00000001(r3)
rlwinm r7, r7, 30, 29, 31
sub r7, r7, r4
addi r7, r7, 1
ba r12, 2147955500
SpecialPropFtHitCmd_Exit:
