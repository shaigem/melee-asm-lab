.include "punkpc.s"
punkpc ppc
# bruh
# authors: @["sushie"]
# description: 
gecko 2148063772
regs (31), rFighterData
lbz r3, 11265(rFighterData)
cmplwi r3, 4
beq- KnockbackAdjust_NoReaction_Damage
cmplwi r3, 2
bne- KnockbackAdjust_NoReaction_SetKb
KnockbackAdjust_NoReaction_Knockback_Value:
lfs f1, 0x00001834(rFighterData)
fcmpo cr0, f1, f0
blt- KnockbackAdjust_NoReaction_SetKb
lfs f0, 0xFFFF8900(rtoc)
b KnockbackAdjust_NoReaction_SetKb
KnockbackAdjust_NoReaction_Damage:
lfs f2, 0x00001834(rFighterData)
lfs f1, 0x00001838(rFighterData)
fcmpo cr0, f2, f1
blt- KnockbackAdjust_NoReaction_SetKb
lfs f0, 0xFFFF8900(rtoc)
KnockbackAdjust_NoReaction_SetKb:
stfs f0, 0x00001850(rFighterData)
gecko.end
