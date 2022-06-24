import ../../common/[dataexpansion, exthit]
import ../../melee


const
    HeaderInfo = MexHeaderInfo
    AutoLinkAngle = 367

    AutoLink367* =
        createCode "Special Hitbox Angle: 367 v2.1.0":
            description: "Pulls victims towards the center of collided hitbox and adjusts launch speed"
            authors: ["sushie"]
            code:
                
                # Main Patch - Physics Callback
                gecko 0x8006b898
                # r31 = fighter data

                regs (r31), rFighterData

                # check if fighter is under the ATTACK_VEC_PULL effect
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                "rlwinm." r0, r0, 0, {flag(ffAttackVecTargetPos)}
                beq OriginalExit_8006BE00 # if not, exit

                prolog xTempCurrentFrame, (0x4), xSpeed, (0x4)

                # check if in hitstun
                lbz r0, 0x221C(rFighterData)
                "rlwinm." r0, r0, 31, 31, 31
                beq ResetEffect_8006BE00 # if not, reset the pull effect

                # time since hit checks
                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames
                lwz r3, {extFtDataOff(HeaderInfo, attackVecTargetPosFrame)}(rFighterData)

                sth r3, sp.xSpeed(sp)
                psq_l f0, sp.xSpeed(sp), 1, 5
                fres f0, f0
                stfs f0, sp.xSpeed(sp)

                addi r3, r3, 2
                cmpwi r0, 0 # safety check
                blt ResetEffect_8006BE00
                cmpw r0, r3 # ending timer
                bge ResetEffect_8006BE00

                bl CalculateLaunchSpeed_8006BE00
               
                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames

                cmpwi r0, 1 # time since hit is 1 frame, don't cap speeds
                beq Exit_8006BE00                

                LerpSpeedCap_8006BE00:
                    bl ExceedsYSpeedCap_8006BE00
                    cmpwi r3, 0
                    lfs f0, 0x90(rFighterData)
                    beq CheckXLerpCap
                    bl SetupLerpSpeed_8006BE00
                    stfs f1, 0x90(rFighterData)

                    CheckXLerpCap:
                        bl ExceedsXSpeedCap_8006BE00
                        cmpwi r3, 1
                        lfs f0, 0x8C(rFighterData)
                        bne Exit_8006BE00
                        bl SetupLerpSpeed_8006BE00
                        stfs f1, 0x8C(rFighterData)

                    b Exit_8006BE00

                    SetupLerpSpeed_8006BE00:
                        fmr f2, f1 # target speed
                        fmr f1, f0 # current speed
                        
                        lwz r3, 0x18AC(rFighterData)
                        subi r3, r3, 1
                        sth r3, sp.xTempCurrentFrame(sp)
                        
                        psq_l f0, sp.xTempCurrentFrame(sp), 1, 5
                        lfs f3, sp.xSpeed(sp) #-0x784C(rtoc) # 0.2
                        fmuls f3, f0, f3 # current time since hit * 0.2
                
                Lerp_8006BE00:
                    # inputs
                    # f1 = a
                    # f2 = b
                    # f3 = t
                    # outputs
                    # f1 = result
                    fsubs f0, f2, f1 # (b - a)
                    fmuls f0, f0, f3 # (b - a) * t
                    fadds f1, f1, f0 # a + ((b - a) * t)
                    blr

                CalculateLaunchSpeed_8006BE00:
                    # for 367
                    # launch speed = attacker momentum + (hitbox position - opponent's position) * 0.20

                    lwz r3, 0x18AC(rFighterData)
                    cmpwi r3, 1
                    beq Calc

                    # reuse
                    lfs f1, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData)
                    lfs f2, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)
                    
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                    "rlwinm." r0, r0, 0, {flag(ffAttackVecSmooth)}
                    beq CalcStore

                    li r0, 0
                    stw r0, 0x84(rFighterData)

                    b CalcStore

                    Calc:
                        # first calculate diff between hitbox and opponent positions
                        lfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)}(rFighterData)
                        lfs f2, 0xB0(rFighterData) # pos x
                        fsubs f2, f0, f2 # hitbox x - pos x
                        lfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterY)}(rFighterData)
                        lfs f1, 0xB4(rFighterData) # pos y
                        fsubs f1, f0, f1 # hitbox y - pos y
                        
                        # next, add the atacker's momentum and 20%
                        lfs f3, sp.xSpeed(sp)#-0x784C(rtoc) # 0.2
                        # add momentum
                        lfs f0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData) # attacker vel y
                        fmadds f1, f1, f3, f0 # (y * 0.20) + attacker velocity y
                        lfs f0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)  # attacker vel x
                        fmadds f2, f2, f3, f0 # (x * 0.20) + attacker velocity x

                        CheckSmooth:
                            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                            "rlwinm." r0, r0, 0, {flag(ffAttackVecSmooth)}
                            beq SavePullSpeed

                            li r0, 0
                            stw r0, 0x84(rFighterData)

                            lfs f0, 0x16C(rFighterData)
                            fadds f1, f1, f0

                        SavePullSpeed:
                            stfs f1, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData)
                            stfs f2, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)


                    # store launch speeds
                    CalcStore:

                        stfs f1, 0x90(rFighterData)
                        stfs f2, 0x8C(rFighterData)

                        blr

                ExceedsYSpeedCap_8006BE00:
                    lfs f1, 0x90(rFighterData)
                    lfs f2, -0x13BC(rtoc) # 3.0
                    lfs f3, -0x7640(rtoc) # -1
                    b ExceedsSpeedCap_8006BE00

                ExceedsXSpeedCap_8006BE00:
                    lfs f1, 0x8C(rFighterData)
                    lfs f2, -0x13BC(rtoc) # 3.0
                    fneg f3, f2

                ExceedsSpeedCap_8006BE00:
                    # inputs
                    # f1 = original value
                    # f2 = upper cap
                    # f3 = lower cap
                    # returns
                    # f1 = original or capped value
                    li r3, 0
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                    "rlwinm." r0, r0, 0, {flag(ffAttackVecCap)}
                    beqlr
                    fmr f0, f3
                    fcmpo cr0, f0, f1
                    bgt ExceedsSpeedCap_True
                    fmr f0, f2
                    fcmpo cr0, f1, f0
                    bgt ExceedsSpeedCap_True
                    blr
                    ExceedsSpeedCap_True:
                        fmr f1, f0
                        li r3, 1
                        blr


                    
                ResetEffect_8006BE00:
                    # check to see if we need to cap launch speeds
                    bl ExceedsYSpeedCap_8006BE00
                    stfs f1, 0x90(rFighterData)
                    bl ExceedsXSpeedCap_8006BE00
                    stfs f1, 0x8C(rFighterData)

                    # turn off the ATTACK_VEC_PULL effect
                    li r3, 0
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                    rlwimi r0, r3, 4, {flag(ffAttackVecTargetPos)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)

                Exit_8006BE00:
                    epilog

                OriginalExit_8006BE00:
                    lwz r12, 0x21A4(rFighterData)

                # patch for NOT entering DamageFlyRoll if attack vec pull effect is active
                gecko 0x8008e128
                lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r29)
                "rlwinm." r3, r3, 0, {flag(ffAttackVecTargetPos)}
                beq OrigExit_8008e128
                lfs f1, -0x7790(rtoc) # use value of 1.0 to skip the use of DamageFlyRoll
                OrigExit_8008e128:
                    lwz r3, -0x514C(r13) # orig code line

                # enable attack vec pull effect if kb_angle is an autolink angle
                # happens when sent into hitstun
                gecko 0x8008dd88
                # r29 = fighter data
                # free registers: r3, r0
                regs (29), rData
                lwz r3, 0x1848(rData) # kb_angle
                cmpwi r3, {AutoLinkAngle}
                bne OrigExit_8007DD88

                # set kb_angle to 80 if defender is grounded at the time of attack
                lwz r3, 0xE0(rData) # air state
                cmpwi r3, 1 # in the air
                beq EnablePullEffect_8008dd88
                # otherwise, use angle of 80
                li r3, 80
                stw r3, 0x1848(rData) # store into kb_angle
                # enable attack vec pull effect
                li r3, 1
                EnablePullEffect_8008dd88:
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rData)
                    rlwimi r0, r3, 4, {flag(ffAttackVecTargetPos)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rData)
                OrigExit_8007DD88:
                    lfd f0, 0x58(sp) # orig code line

                # gecko 0x8007aaf8
                # patch for setting hitlag to be the same for both attacker and defender if electric
                # # r0 at this point contains hit attribute
                # regs (25), rDefenderData, (31), rFtDmgLog

                # lwz r3, 0x4(rFtDmgLog) # angle of hit
                # cmplwi r3, {AutoLinkAngle}
                # bne OrigExit_8007AAF8 # not autolink 367, exit

                # lwz r3, 0x1C(rFtDmgLog) # hit attribute
                # cmplwi r3, 2
                # bne OrigExit_8007AAF8 # exit if not electric

                # lwz r4, 0x8(r19)
                # cmplwi r4, 0
                # beq OrigExit_8007AAF8 # NULL attacker
                # lhz r5, 0(r4)
                # cmplwi r5, 0x4
                # bne OrigExit_8007AAF8 # != fighter

                # regs (4), rAttackerData
               
                # lwz rAttackerData, 0x2C(r4)

                # # if r0 != hit attribute of ftHit, hitbox extension is installed
                # cmplw r3, r0
                # bne SetBoth

                # # otherwise, vanilla
                # lwz r5, -0x514C(r13)
                # lfs f0, 0x1A4(r5)
                # stfs f0, 0x1960(rDefenderData)
                # stfs f0, 0x1960(rAttackerData)
                # li r0, 0 # skip vanilla electric check
                # b OrigExit_8007AAF8

                # SetBoth:
                #     lfs f0, 0x1960(rDefenderData)
                #     stfs f0, 0x1960(rAttackerData)


                # OrigExit_8007AAF8:
                #     cmplwi r0, 2 # orig check electric attribute
                

                # CalculateKnockback Function Patch - Sets the Necessary Hit Variables
                gecko 0x8007a934
                # r0 = hitbox angle
                # r3 = hit struct
                # r25 = defender data
                # r17 = damage source?
                # r31 = points to direction var of struct dmg
                # f26/launch_speed_kb = calculated kb value based on hitbox settings
                stw r0, 0x4(r31) # orig line, set kb_angle


                prolog rDefenderData, rAttackerData, rAttackerGObj, rExtHit, rHit, rDmgLog
                mr rHit, r3
                mr rDefenderData, r25
                mr rDmgLog, r31
                lwz rHit, 0xC(r17)

                lwz rAttackerGObj, 0x8(r17)
                cmplwi r3, 0
                beq OriginalExit_8007a868

                lwz rAttackerData, 0x2C(rAttackerGObj)

                # get ExtHit
                mr r3, rAttackerGObj
                mr r4, rHit
                bla r12, {GetExtHitFunc}
                "mr." rExtHit, r3
                beq OriginalExit_8007a868

                lbz r0, {extHitOff(hitStdFlags)}(rExtHit)
                "rlwinm." r3, r0, 0, {flag(hsfVecTargetPos)}
                beq SetDefaultsForAutoLink

                # set vec target positions
                lwz r3, {extHitTargetPosOff(targetPosNode)}(rExtHit)
                addi r4, rExtHit, {extHitTargetPosOff(targetPosOffsetX)}
                addi r5, rDefenderData, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)}
                bla r12, {JOBJGetWorldPos}

                # set frame
                lwz r3, {extHitTargetPosOff(targetPosFrame)}(rExtHit)
                stw r3, {extFtDataOff(HeaderInfo, attackVecTargetPosFrame)}(rDefenderData)
                
                lbz r0, {extHitOff(hitStdFlags)}(rExtHit)
                lbz r4, {extFtDataOff(HeaderInfo, fighterFlags2)}(rDefenderData)
                
                rlwinm r3, r0, 27, 31, 31 # speed cap
                rlwimi r4, r3, 7, {flag(ffAttackVecCap)}

                rlwinm r3, r0, 28, 31, 31 # smooth
                rlwimi r4, r3, 6, {flag(ffAttackVecSmooth)}

                stb r4, {extFtDataOff(HeaderInfo, fighterFlags2)}(rDefenderData)

                rlwinm r3, r0, 29, 31, 31 # use atk momentum
                b SetAutoLinkVars

                SetDefaultsForAutoLink:
                    lfs f0, 0x4C(rHit) # hitbox pos X
                    stfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)}(rDefenderData)
                    lfs f0, 0x50(rHit) # hitbox pos y
                    stfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterY)}(rDefenderData)
                    li r0, 5
                    stw r0, {extFtDataOff(HeaderInfo, attackVecTargetPosFrame)}(rDefenderData)

                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rDefenderData)

                    li r3, 0
                    rlwimi r0, r3, 6, {flag(ffAttackVecSmooth)}

                    li r3, 1
                    rlwimi r0, r3, 7, {flag(ffAttackVecCap)}

                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rDefenderData)

                SetAutoLinkVars:
                    # r3 = use attacker momentum bool
                    cmplwi r3, 0
                    beq SetAutoLinkVars_NoAttackerMomentum

                    lhz r0, 0(rAttackerGObj)
                    addi r3, rAttackerData, 0x80
                    cmplwi r0, 0x4 # fighter
                    beq SetAutoLinkVars_AttackerVel
                    addi r3, rAttackerData, 0x40
                    cmplwi r0, 0x6 # item

                    SetAutoLinkVars_AttackerVel:
                        psq_l f0, 0(r3), 0, 0
                        addi r4, rDefenderData, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}
                        psq_st f0, 0(r4), 0, 0
                        b OriginalExit_8007a868
                    
                    SetAutoLinkVars_NoAttackerMomentum:
                        li r0, 0
                        stw r0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rDefenderData)
                        stw r0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rDefenderData)

                OriginalExit_8007a868:
                    li r3, 0
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                    rlwimi r0, r3, 4, {flag(ffAttackVecTargetPos)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                    epilog
                
                gecko.end

when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
