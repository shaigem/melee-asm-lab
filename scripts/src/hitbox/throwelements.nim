import ../melee

const
    EnableElementsThrow* =
        createCode "Enable Other Elements for Throws v1.0.0":
            description: "Allows throws to sleep, bury, disable screw attack or poison flower victims"
            authors: ["sushie"]
            code:
                errata.new e
                e.ref sleep, bury, disable, screw, flower

                # Patch Fighter_ThrownApplyKnockback
                # This is where knockback gets applied when thrown
                gecko 0x800de7ec

                bl ApplyThrowElements
                elements:
                    # elements table
                    # each element contains the offset of the ApplyElement_ function
                    ".space 6 * 4" # 0-5
                    ".4byte" sleep # 6
                    ".4byte" sleep # 7
                    ".4byte" 0
                    ".4byte" bury # 9
                    ".space 2 * 4" # 10-11
                    ".4byte" disable # 12
                    ".4byte" 0
                    ".4byte" screw # 14
                    ".4byte" flower # 15

                    ApplyElement_Sleep:
                        # Set proper facing direction based on damage log
                        lfs f0, 0x1844(r31)
                        stfs f0, 0x2C(r31)
                        
                        # Set as Grounded
                        mr r3, r31
                        bla r12, 0x8007d7fc
                        b ApplyThrowElements_KillVelocity
                    
                    ApplyElement_Disable:
                        lbz r0, 0x2228(r31)
                        "rlwinm." r0, r0, 27, 31, 31
                        bne ApplyThrowElements_EnterDamageState
                        
                        # Set proper facing direction based on damage log
                        lfs f0, 0x1844(r31)
                        stfs f0, 0x2C(r31)
                        
                        # Set as Grounded
                        mr r3, r31
                        bla r12, 0x8007d7fc

                        # Call AS_300_Disable
                        lwz r3, 0(r31)
                        bla r12, 0x800c4550
                        b ApplyThrowElements_KillVelocity

                    ApplyElement_Bury:
                        lbz r0, 0x2227(r31)
                        "rlwinm." r0, r0, 31, 31, 31
                        bne ApplyThrowElements_EnterDamageState
                        
                        # call AS_294_Bury function
                        # r3 = fighter gobj
                        bla r12, 0x800C0D0C
                        b ApplyThrowElements_SkipEnterDamageState

                    ApplyElement_Screw:
                        # AS_156/157_DamageScrew/DamageScrewAir
                        bla r12, 0x800d3004
                        b ApplyThrowElements_SkipEnterDamageState

                    ApplyElement_Flower:
                        sp.push
                        sp.temp rTemp
                        stw r5, sp.rTemp(sp) # backup r5
                        lwz r3, 0(r31)
                        lfs f1, 0x1838(r31) # damage taken
                        bla r12, 0x8007FC7C # applyFlowerHead(GObj* fighterObj, float damageTaken)
                        lwz r5, sp.rTemp(sp) # restore r5
                        sp.pop
                        b ApplyThrowElements_EnterDamageState


                ApplyThrowElements:
                    e.solve ApplyElement_Sleep-elements, ApplyElement_Bury-elements, ApplyElement_Disable-elements, ApplyElement_Screw-elements, ApplyElement_Flower-elements

                    mflr r4
                    lwz r0, 0x1860(r31) # damage element/attribute

                    # element < 6 || element > 15, exit
                    cmplwi r0, 6
                    blt+ ApplyThrowElements_EnterDamageState
                    cmplwi r0, 15
                    bgt ApplyThrowElements_EnterDamageState

                    # get proper branch offset based on element id
                    slwi r0, r0, 2
                    lwzx r0, r4, r0

                    cmplwi r0, 0 # invalid offset, exit
                    beq ApplyThrowElements_EnterDamageState

                    add r0, r4, r0
                    mtctr r0
                    bctr

                    ApplyThrowElements_KillVelocity:
                        lwz r3, 0(r31)
                        bla r12, 0x8007e2fc

                    ApplyThrowElements_SkipEnterDamageState:
                        ba r12, 0x800de840

                    ApplyThrowElements_EnterDamageState:
                        # exit branch
                        lwz r3, 0(r31) # restore r3 just in case
                        cmpwi r5, 0 # orig code line

                gecko.end


when isMainModule:
    generate "./generated/general/throwelements.asm", EnableElementsThrow