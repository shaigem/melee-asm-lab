.include "punkpc.s"
punkpc ppc
# Enable Other Elements for Throws v1.0.0
# authors: @["sushie"]
# description: Allows throws to sleep, bury, disable screw attack or poison flower victims
errata.new e
e.ref sleep, bury, disable, screw, flower
gecko 2148394988
bl ApplyThrowElements
elements:
.space 6 * 4
.4byte sleep
.4byte sleep
.4byte 0
.4byte bury
.space 2 * 4
.4byte disable
.4byte 0
.4byte screw
.4byte flower
ApplyElement_Sleep:
lfs f0, 0x00001844(r31)
stfs f0, 0x0000002C(r31)
mr r3, r31
bla r12, 2147997692
b ApplyThrowElements_KillVelocity
ApplyElement_Disable:
lbz r0, 0x00002228(r31)
rlwinm. r0, r0, 27, 31, 31
bne ApplyThrowElements_EnterDamageState
lfs f0, 0x00001844(r31)
stfs f0, 0x0000002C(r31)
mr r3, r31
bla r12, 2147997692
lwz r3, 0(r31)
bla r12, 2148287824
b ApplyThrowElements_KillVelocity
ApplyElement_Bury:
lbz r0, 0x00002227(r31)
rlwinm. r0, r0, 31, 31, 31
bne ApplyThrowElements_EnterDamageState
bla r12, 2148273420
b ApplyThrowElements_SkipEnterDamageState
ApplyElement_Screw:
bla r12, 2148347908
b ApplyThrowElements_SkipEnterDamageState
ApplyElement_Flower:
sp.push
sp.temp rTemp
stw r5, sp.rTemp(sp)
lwz r3, 0(r31)
lfs f1, 0x00001838(r31)
bla r12, 2148007036
lwz r5, sp.rTemp(sp)
sp.pop
b ApplyThrowElements_EnterDamageState
ApplyThrowElements:
e.solve ApplyElement_Sleep - elements, ApplyElement_Bury - elements, ApplyElement_Disable - elements, ApplyElement_Screw - elements, ApplyElement_Flower - elements
mflr r4
lwz r0, 0x00001860(r31)
cmplwi r0, 6
blt+ ApplyThrowElements_EnterDamageState
cmplwi r0, 15
bgt ApplyThrowElements_EnterDamageState
slwi r0, r0, 2
lwzx r0, r4, r0
cmplwi r0, 0
beq ApplyThrowElements_EnterDamageState
add r0, r4, r0
mtctr r0
bctr
ApplyThrowElements_KillVelocity:
lwz r3, 0(r31)
bla r12, 2148000508
ApplyThrowElements_SkipEnterDamageState:
ba r12, 2148395072
ApplyThrowElements_EnterDamageState:
lwz r3, 0(r31)
cmpwi r5, 0
gecko.end
