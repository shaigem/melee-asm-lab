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
                enumb Set, Unk2, LerpAtkMom, LerpSpeedCap, UseVecTargetPos, UseAtkMom, CalcOverrideSpeed, AfterHitlag
                "enum" (0), +4, xVecTargetPosFrame, xVecTargetPosX, xVecTargetPosY, xVecTargetAtkSpeedX, xVecTargetAtkSpeedY, xVecTargetPosFlags

                # Main Patch - Physics Callback
                gecko 0x8006b898
                # r31 = fighter data

                regs (r31), rFighterData

                # check if fighter is under the ATTACK_VEC_PULL effect
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                "rlwinm." r0, r0, 0, {flag(ffAttackVecTargetPos)}
                beq AutoLinkPhysics_OriginalExit # if not, exit

                prolog xU, (0x2), xL, (0x2), xTempFrameInfo, (0x4)
                lbz r0, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rFighterData)
                mtcrf 0x3, r0

                # xTempFrameInfo[0] = time_since_hit - 1, [1] = 1/frames
                lwz r3, 0x18AC(rFighterData) # time_since_hit in frames
                subi r3, r3, 1
                sth r3, sp.xU(sp)
                lwz r3, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}(rFighterData)
                sth r3, sp.xL(sp)
                psq_l f0, sp.xU(sp), 0, 5
                ps_res f1, f0
                ps_merge01 f0, f0, f1
                psq_st f0, sp.xTempFrameInfo(sp), 0, 0

                # check if in hitstun
                lbz r0, 0x221C(rFighterData)
                "rlwinm." r0, r0, 31, 31, 31
                beq AutoLinkPhysics_ResetEffect # if not, reset the pull effect

                # time since hit checks
                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames
                lwz r3, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}(rFighterData)

                addi r3, r3, 2
                cmpwi r0, 0 # safety check
                blt AutoLinkPhysics_ResetEffect
                cmpw r0, r3 # ending timer
                bge AutoLinkPhysics_ResetEffect_TurnOff

                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames

                cmplwi r0, 1 # time since hit is 1 frame, don't cap speeds
                beq AutoLinkPhysics_Exit

                psq_l f1, sp.xTempFrameInfo(sp), 0, 0
                bl AutoLinkPhysics_LerpVels

                b AutoLinkPhysics_Exit


                AutoLinkPhysics_LerpVels:
                    # inputs
                    # f1[0] = currentFrame, f1[1] = 1/frames
                    ps_muls1 f4, f1, f1 # multiply currentFrame by 1/frames to get t
                    psq_l f1, 0x8C(rFighterData), 0, 0
                    bt bLerpSpeedCap, AutoLinkPhysics_LerpVels_Speed
                    bt bLerpAtkMom, AutoLinkPhysics_LerpVels_AtkMom
                    blr

                    AutoLinkPhysics_LerpVels_Speed:
                        # check if current speed exceeds speed cap
                        # f1[0] = x vel, f1[1] = y vel
                        # f2[0] = upper x, f2[1] = upper y
                        # f3[0] = lower x, f3[1] = lower y
                        lfs f2, -0x13BC(rtoc) # 3.0 for upper x and y
                        lfs f3, -0x7790(rtoc) # 1.0

                        ps_merge01 f3, f2, f3 # lower x = 3.0, lower y = 1.0
                        ps_neg f3, f3 # negate since it's lower caps

                        # select upper if exceeds upper limit
                        ps_sub f0, f1, f2
                        ps_sel f2, f0, f2, f1

                        # select lower if exceeds lower limit
                        ps_sub f0, f1, f3
                        ps_sel f2, f0, f2, f3

                        fmr f3, f4
                        b AutoLinkPhysics_Lerp


                    AutoLinkPhysics_LerpVels_AtkMom:
                        addi r3, rFighterData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                        psq_l f2, 0xC(r3), 0, 0
                        fmr f3, f4
                        b AutoLinkPhysics_Lerp

                AutoLinkPhysics_Lerp:
                    # inputs
                    # f1 = cur x, cur y
                    # f2 = target x, target y
                    # f3[0] = t
                    ps_sub f0, f2, f1 # (b - a)
                    ps_madds0 f0, f0, f3, f1 # ((b - a) * t) + a
                    psq_st f0, 0x8C(rFighterData), 0, 0

                    # check to see if we need to adjust ground x vel
                    lfs f2, -0x76B0(rtoc) # 0.0
                    lfs f1, 0xF0(rFighterData)
                    fcmpu cr0, f2, f1
                    "beqlr-"
                    stfs f0, 0xF0(rFighterData)
                    blr

                AutoLinkPhysics_ResetEffect:
                    lfs f1, -0x7790(rtoc) # 1.0
                    bl AutoLinkPhysics_LerpVels
                    AutoLinkPhysics_ResetEffect_TurnOff:
                        # turn off the ATTACK_VEC_PULL effect
                        li r3, 0
                        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                        rlwimi r0, r3, 4, {flag(ffAttackVecTargetPos)}
                        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)


                AutoLinkPhysics_Exit:
                    epilog

                AutoLinkPhysics_OriginalExit:
                    lwz r12, 0x21A4(rFighterData)

                

              


                # bl CalculateLaunchSpeed_8006BE00
               
                # lwz r0, 0x18AC(rFighterData) # time_since_hit in frames

                # cmpwi r0, 1 # time since hit is 1 frame, don't cap speeds
                # beq Exit_8006BE00                

                # LerpSpeedCap_8006BE00:
                #     bl ExceedsYSpeedCap_8006BE00
                #     cmpwi r3, 0
                #     lfs f0, 0x90(rFighterData)
                #     beq CheckXLerpCap
                #     bl SetupLerpSpeed_8006BE00
                #     stfs f1, 0x90(rFighterData)

                #     CheckXLerpCap:
                #         bl ExceedsXSpeedCap_8006BE00
                #         cmpwi r3, 1
                #         lfs f0, 0x8C(rFighterData)
                #         bne Exit_8006BE00
                #         bl SetupLerpSpeed_8006BE00
                #         stfs f1, 0x8C(rFighterData)

                #     b Exit_8006BE00

                #     SetupLerpSpeed_8006BE00:
                #         fmr f2, f1 # target speed
                #         fmr f1, f0 # current speed
                        
                #         lwz r3, 0x18AC(rFighterData)
                #         subi r3, r3, 1
                #         sth r3, sp.xTempCurrentFrame(sp)
                        
                #         psq_l f0, sp.xTempCurrentFrame(sp), 1, 5
                #         lfs f3, sp.xSpeed(sp) #-0x784C(rtoc) # 0.2
                #         fmuls f3, f0, f3 # current time since hit * 0.2
                
                # Lerp_8006BE00:
                #     # inputs
                #     # f1 = a
                #     # f2 = b
                #     # f3 = t
                #     # outputs
                #     # f1 = result
                #     fsubs f0, f2, f1 # (b - a)
                #     fmuls f0, f0, f3 # (b - a) * t
                #     fadds f1, f1, f0 # a + ((b - a) * t)
                #     blr

                # CalculateLaunchSpeed_8006BE00:
                #     # for 367
                #     # launch speed = attacker momentum + (hitbox position - opponent's position) * 0.20

                #     lwz r3, 0x18AC(rFighterData)
                #     cmpwi r3, 1
                #     beq Calc

                #     # reuse
                #     lfs f1, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData)
                #     lfs f2, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)
                    
                #     lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                #     "rlwinm." r0, r0, 0, {flag(ffAttackVecSmooth)}
                #     beq CalcStore

                #     li r0, 0
                #     stw r0, 0x84(rFighterData)

                #     b CalcStore

                #     Calc:
                #         # first calculate diff between hitbox and opponent positions
                #         lfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)}(rFighterData)
                #         lfs f2, 0xB0(rFighterData) # pos x
                #         fsubs f2, f0, f2 # hitbox x - pos x
                #         lfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterY)}(rFighterData)
                #         lfs f1, 0xB4(rFighterData) # pos y
                #         fsubs f1, f0, f1 # hitbox y - pos y
                        
                #         # next, add the atacker's momentum and 20%
                #         lfs f3, sp.xSpeed(sp)#-0x784C(rtoc) # 0.2
                #         # add momentum
                #         lfs f0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData) # attacker vel y
                #         fmadds f1, f1, f3, f0 # (y * 0.20) + attacker velocity y
                #         lfs f0, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)  # attacker vel x
                #         fmadds f2, f2, f3, f0 # (x * 0.20) + attacker velocity x

                #         CheckSmooth:
                #             lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                #             "rlwinm." r0, r0, 0, {flag(ffAttackVecSmooth)}
                #             beq SavePullSpeed

                #             li r0, 0
                #             stw r0, 0x84(rFighterData)

                #             lfs f0, 0x16C(rFighterData)
                #             fadds f1, f1, f0

                #         SavePullSpeed:
                #             stfs f1, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedY)}(rFighterData)
                #             stfs f2, {extFtDataOff(HeaderInfo, attackVecLastAttackerSpeedX)}(rFighterData)


                #     # store launch speeds
                #     CalcStore:

                #         stfs f1, 0x90(rFighterData)
                #         stfs f2, 0x8C(rFighterData)

                #         blr

                # ExceedsYSpeedCap_8006BE00:
                #     lfs f1, 0x90(rFighterData)
                #     lfs f2, -0x13BC(rtoc) # 3.0
                #     lfs f3, -0x7640(rtoc) # -1
                #     b ExceedsSpeedCap_8006BE00

                # ExceedsXSpeedCap_8006BE00:
                #     lfs f1, 0x8C(rFighterData)
                #     lfs f2, -0x13BC(rtoc) # 3.0
                #     fneg f3, f2

                # ExceedsSpeedCap_8006BE00:
                #     # inputs
                #     # f1 = original value
                #     # f2 = upper cap
                #     # f3 = lower cap
                #     # returns
                #     # f1 = original or capped value
                #     li r3, 0
                #     lbz r0, {extFtDataOff(HeaderInfo, fighterFlags2)}(rFighterData)
                #     "rlwinm." r0, r0, 0, {flag(ffAttackVecCap)}
                #     beqlr
                #     fmr f0, f3
                #     fcmpo cr0, f0, f1
                #     bgt ExceedsSpeedCap_True
                #     fmr f0, f2
                #     fcmpo cr0, f1, f0
                #     bgt ExceedsSpeedCap_True
                #     blr
                #     ExceedsSpeedCap_True:
                #         fmr f1, f0
                #         li r3, 1
                #         blr


                    
               

                # Exit_8006BE00:
                #     epilog

                # OriginalExit_8006BE00:
                #     lwz r12, 0x21A4(rFighterData)

                # # patch for NOT entering DamageFlyRoll if attack vec pull effect is active
                # gecko 0x8008e128
                # lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r29)
                # "rlwinm." r3, r3, 0, {flag(ffAttackVecTargetPos)}
                # beq OrigExit_8008e128
                # lfs f1, -0x7790(rtoc) # use value of 1.0 to skip the use of DamageFlyRoll
                # OrigExit_8008e128:
                #     lwz r3, -0x514C(r13) # orig code line

                # enable attack vec pull effect if kb_angle is an autolink angle
                # happens when sent into hitstun
                gecko 0x8008dd88
                # r29 = fighter data
                # free registers: r3, r0
                regs (29), rData
                lbz r3, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rData)
                mtcrf 0x3, r3
                "bf+" bSet, OrigExit_8007DD88
                li r3, 1
                EnablePullEffect_8008dd88:
                    crclr bSet
                    mfcr r0
                    stb r0, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rData)
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rData)
                    rlwimi r0, r3, {flagOrd(ffAttackVecTargetPos)}
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

                # TODO apply only if there is kb > 0

                prolog rDmgLog, rAttackerData, rAttackerGObj, rExtHit, rHit, xTemp, (0xC)
                regs (17), rDmgSrc, (25), rDefenderData
                lwz rHit, 0xC(rDmgSrc)
                lwz rAttackerGObj, 0x8(rDmgSrc)

                # init the autolink flags to 0
                # we use cr6 and cr7
                li r0, 0
                mtcrf 0x3, r0

                cmplwi rAttackerGObj, 0
                beq SetAutoLinkVars_CheckAngle

                # attacker exists, get the ExtHit struct
                lwz rAttackerData, 0x2C(rAttackerGObj)
                mr r3, rAttackerGObj
                mr r4, rHit
                bla r12, {GetExtHitFunc}
                mr rExtHit, r3
                cmplwi r3, 0
                beq SetAutoLinkVars_CheckAngle

                # if ExtHit exists, check if there is a custom vec target pos to calculate
                lbz r0, {extHitTargetPosOff(targetPosFlags)}(rExtHit)
                mtcrf 0x3, r0
                "bf-" bSet, SetAutoLinkVars_CheckAngle

                SetAutoLinkVars_CustomVecTargetPos:
                    # calculate target pos using given bone and offsets
                    lwz r3, {extHitTargetPosOff(targetPosNode)}(rExtHit)
                    addi r4, rExtHit, {extHitTargetPosOff(targetPosOffsetX)}
                    addi r5, rDefenderData, {extFtDataOff(HeaderInfo, vecTargetPosX)} # store it in defender data
                    bla r12, {JOBJGetWorldPos}

                    # store # of frames
                    lwz r0, {extHitTargetPosOff(targetPosFrame)}(rExtHit)
                    stw r0, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}(rDefenderData)
                    b SetAutoLinkVars_IsAutoLink

                SetAutoLinkVars_CheckAngle:
                    nop
                
                SetAutoLinkVars_IsAutoLink:
                    # inputs
                    # frame, posX, posY should all be set in defender data
                    # cr6, cr7 = autolink flags

                    mr r3, rDefenderData
                    addi r4, rDefenderData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}

                    # TODO redo getting the attacker speed 
                    # if no attacker, turn off lerp attacker momentum                   
                    psq_l f0, 0x80(rAttackerData), 0, 0
                    psq_st f0, 0xC(r4), 0, 0

                    bl CalculateAutoLinkLaunchSpeed
                    # returned f1[0] = y vel, f2[0] = x vel
                    
                    # if override speed && calculate using values BEFORE hitlag, save calculated launch speed
                    crandc eq, bCalcOverrideSpeed, bAfterHitlag
                    bf eq, SetAutoLinkVars_IsAutoLink_CalcAngle

                    psq_st f2, 0x4(r4), 0, 0

                    SetAutoLinkVars_IsAutoLink_CalcAngle:
                        # calculate launch angle and store it
                        lfs f0, -0x7700(rtoc) # 0.0
                        lfs f3, 0(rDmgLog) # calculated direction
                        fcmpo cr0, f3, f0
                        "bt lt, 0f"
                        fneg f2, f2
                        0: ""
                        bla r12, {Atan2} 
                        lfs f0, -0x76C4(rtoc) # 180/PI
                        fmuls f1, f0, f1
                        fctiw f0, f1
                        stfd f0, sp.xTemp(sp)
                        lwz r0, sp.xTemp+0x4(sp)
                        stw r0, 0x4(rDmgLog) # store new calculated angle

                    cror eq, bLerpAtkMom, bLerpSpeedCap # hasLerp
                    crnot lt, bCalcOverrideSpeed # !bOverrideSpeed
                    crandc eq, lt, eq # (!bOverrideSpeed && !hasLerp)
                    "bt- eq, 0f"
                    crset bSet
                    b SetAutoLinkVars_Exit
                    0: crclr bSet
                    b SetAutoLinkVars_Exit

                CalculateAutoLinkLaunchSpeed:
                    # inputs
                    # r3 = fighter data
                    # r4 = ptr to VecTargetPos of fighter data
                    # cr6, cr7 = autolink bools
                    # outputs
                    # f1 = vel y
                    # f2 = vel x
                    sp.push
                    sp.temp xTemp, (0xC)
                    lwz r0, 0(r4)
                    sth r0, sp.xTemp(sp)
                    psq_l f0, sp.xTemp(sp), 1, 5
                    fres f0, f0
                    lfs f1, -0x7700(rtoc) # 0.0
                    sp.pop
                    #crand eq, bUseAtkMom, bUseVecTargetPos
                    #crorc eq, bUseAtkMom

                    # TODO what if useAtkMom and useVecTargetPos is not set?

                    bf bUseAtkMom, CalculateAutoLinkLaunchSpeed_TargetPos

                    CalculateAutoLinkLaunchSpeed_AtkMom:
                        psq_l f1, 0xC(r4), 0, 0
                        bt bUseVecTargetPos, CalculateAutoLinkLaunchSpeed_TargetPos
                        ps_muls0 f2, f1, f0 # multiply by 1/frames
                        ps_merge10 f1, f2, f2
                        blr
                        
                    CalculateAutoLinkLaunchSpeed_TargetPos:
                        psq_l f2, 0x4(r4), 0, 0 # load target pos x and y
                        psq_l f3, 0xB0(r3), 0, 0 # load defender x and y pos
                        ps_sub f2, f2, f3 # diff = (target pos - def pos)

                        # multiply diff by 1/frames
                        ps_muls0 f2, f2, f0

                        # add attacker momentum, if any
                        ps_add f2, f1, f2 # attacker momentum + diff
                        ps_merge10 f1, f2, f2

                    blr

                SetAutoLinkVars_Exit:
                    # TODO turn off ffAttackVecTargetPos?
                    mfcr r0
                    stb r0, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rDefenderData)
                    epilog
                
                #prolog rDefenderData, rAttackerData, rAttackerGObj, rExtHit, rHit, rDmgLog, rVecTargetPos, fVelX, fVelY,
                #    xVecTargetPos, (6 * 4), xTemp, (0xC)

                # mr rDmgLog, r31
                # mr rDefenderData, r25
                # mr rHit, r3
                # lwz rHit, 0xC(r17)
                # lwz rAttackerGObj, 0x8(r17)
                

                #addi rVecTargetPos, sp, sp.xVecTargetPos

                # li r0, 0
                # mtcrf 0x3, r0                

                # # TODO if defender is an item & autolink, just use the hitbox's pos as the angle

                # cmplwi rAttackerGObj, 0
                # beq SetAutoLinkVars_Exit # TODO make it actually calculate but using 0 for momentum

                # lwz rAttackerData, 0x2C(rAttackerGObj)

                # # get ExtHit
                # mr r3, rAttackerGObj
                # mr r4, rHit
                # bla r12, {GetExtHitFunc}
                # "mr." rExtHit, r3
                # beq SetAutoLinkVars_CheckAngle

                # lbz r0, {extHitTargetPosOff(targetPosFlags)}(rExtHit)
                # mtcrf 0x3, r0
                # "bf-" bSet, SetAutoLinkVars_CheckAngle
                
                # # if set via subaction event, then calculate the target pos using the given bone
                # lwz r3, {extHitTargetPosOff(targetPosNode)}(rExtHit)
                # addi r4, rExtHit, {extHitTargetPosOff(targetPosOffsetX)}
                # addi r5, rVecTargetPos, xVecTargetPosX
                # bla r12, {JOBJGetWorldPos}
               
                # lwz r0, {extHitTargetPosOff(targetPosFrame)}(rExtHit)
                # stw r0, xVecTargetPosFrame(rVecTargetPos)
                # b SetAutoLinkVars_Set

                # SetAutoLinkVars_CheckAngle:
                #     li r0, 1
                #     stw r0, xVecTargetPosFrame(rVecTargetPos)

                #     lwz r0, 0x4(rDmgLog) # kb_angle
                #     cmplwi r0, 367
                #     beq SetAutoLinkVars_Set_Vec_Pull
                #     b SetAutoLinkVars_Exit
                
                # SetAutoLinkVars_Set_Vec_Pull:
                #     crset bLerpSpeedCap
                #     crset bCalcVecPull
                #     crset bCalcOverrideSpeed
                #     crset bAfterHitlag

                #     psq_l f0, 0x4C(rHit), 0, 7
                #     psq_st f0, xVecTargetPosX(rVecTargetPos), 0, 0

                #     li r0, 10
                #     stw r0, xVecTargetPosFrame(rVecTargetPos)
                #     b SetAutoLinkVars_Set

                # SetAutoLinkVars_Set:
                #     crset bSet

                #     crorc eq, bCalcVecTargetPos, bCalcVecPull # both use the XYZ/target pos

                #     # get and set attacker speed if any
                #     psq_l f0, 0x80(rAttackerData), 0, 7
                #     psq_st f0, xVecTargetAtkSpeedX(rVecTargetPos), 0, 0

                #     # calculate the launch speed on hit
                #     mr r3, rDefenderData
                #     mr r4, rVecTargetPos
                #     bl CalculateAutoLinkLaunchSpeed
                #     # calculate launch angle and store it
                #     lfs f0, -0x7700(rtoc) # 0.0
                #     lfs f3, 0(rDmgLog) # calculated direction
                #     fcmpo cr0, f3, f0
                #     "bt lt, 0f"
                #     fneg f2, f2
                #     0: ""
                #     bla r12, {Atan2} 
                #     lfs f0, -0x76C4(rtoc) # 180/PI
                #     fmuls f1, f0, f1
                #     fctiw f0, f1
                #     stfd f0, sp.xTemp(sp)
                #     lwz r0, sp.xTemp+0x4(sp)
                #     stw r0, 0x4(rDmgLog) # store new calculated angle

                #     # check to see if we need to adjust the launch speed or have any lerp effects
                #     cror eq, bCalcOverrideSpeed, bLerpSpeedCap
                #     cror eq, bLerpAtkMom, eq
                #     "bf-" eq, SetAutoLinkVars_Exit
                    
                #     lwz r0, xVecTargetPosFrame(rVecTargetPos)
                #     stw r0, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}(rDefenderData)
                #     psq_l f0, xVecTargetPosX(rVecTargetPos), 0, 7
                #     addi r3, rDefenderData, {extFtDataOff(HeaderInfo, vecTargetPosX)}
                #     psq_st f0, 0(r3), 0, 0
                    
                #     psq_l f0, xVecTargetAtkSpeedX(rVecTargetPos), 0, 7
                #     addi r3, r3, 0x8
                #     psq_st f0, 0(r3), 0, 0
                #     b SetAutoLinkVars_Exit

               
                #     # inputs
                #     # r3 = fighter data
                #     # r4 = VecTargetPos struct info
                #     # cr6-cr7 = autolink bools
                #     # outputs
                #     # f1 = vel y
                #     # f2 = vel x
                #     CalculateAutoLinkLaunchSpeed:
                #         # TODO don't need to store frame...
                #         sp.push
                #         sp.temp xTemp, (0xC)
                #         lwz r0, xVecTargetPosFrame(r4)
                #         sth r0, sp.xTemp(sp)
                #         psq_l f3, sp.xTemp(sp), 1, 5
                #         fres f3, f3
                #         sp.pop
                #         cror eq, bCalcVecTargetPos, bCalcVecPull # both use the XYZ/target pos
                #         "bt-" eq, SetAutoLinkVars_CalcTargetPos

                #         SetAutoLinkVars_CalcAttackerMomentum:
                #             lfs f2, xVecTargetAtkSpeedX(r4)
                #             lfs f1, xVecTargetAtkSpeedY(r4)
                #             fmuls f2, f2, f3
                #             fmuls f1, f1, f3
                #             blr

                #         SetAutoLinkVars_CalcTargetPos:
                #             lfs f0, xVecTargetPosX(r4)
                #             lfs f2, 0xB0(r3) # def pos x
                #             fsubs f2, f0, f2 # target pos x - def pos x
                #             fmuls f2, f2, f3 # diff x * 1/frame
                #             lfs f0, xVecTargetPosY(r4)
                #             lfs f1, 0xB4(r3) # def pos y
                #             fsubs f1, f0, f1 # target pos y - def pos y
                #             fmuls f1, f1, f3 # diff y * 1/frame
                #             "bflr-" bCalcVecPull 

                #             SetAutoLinkVars_AddAttackerMom:
                #                 # TODO handle NULL attacker and items
                #                 lfs f0, xVecTargetAtkSpeedX(r4)          
                #                 fadds f2, f2, f0 # (diff x * (1/frame)) + attacker velocity x
                #                 lfs f0, xVecTargetAtkSpeedY(r4)          
                #                 fadds f1, f1, f0 # (diff y * (1/frame)) + attacker velocity y
                #         CalculateAutoLinkLaunchSpeed_Exit:
                #             blr
                            

                # SetAutoLinkVars_Exit:
                #     mfcr r0
                #     stb r0, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rDefenderData)
                #     epilog

                
                gecko.end

when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
