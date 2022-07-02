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
                # if timer == 1 and overrideSpeed is enabled
                cmplwi r0, 1
                crand eq, eq, bCalcOverrideSpeed
                bt eq, AutoLinkPhysics_SetLaunchSpeeds
                
                psq_l f1, sp.xTempFrameInfo(sp), 0, 0
                bl AutoLinkPhysics_LerpVels
                b AutoLinkPhysics_Exit

                AutoLinkPhysics_SetLaunchSpeeds:
                    addi r4, rFighterData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                    bf bAfterHitlag, AutoLinkPhysics_SetLaunchSpeeds_UsePrecalc             

                    AutoLinkPhysics_SetLaunchSpeeds_CalcNew:  
                        mr r3, rFighterData
                        bl CalculateAutoLinkLaunchSpeed
                        b AutoLinkPhysics_SetLaunchSpeeds_Set

                    AutoLinkPhysics_SetLaunchSpeeds_UsePrecalc: 
                        psq_l f2, 0x4(r4), 0, 0

                    AutoLinkPhysics_SetLaunchSpeeds_Set:
                        psq_st f2, 0x8C(rFighterData), 0, 0
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
                    # TODO should we reset the cr6-cr7 in case it isn't an autolink?
                    # seems to be fine without resetting...
                    lwz r0, 0x4(rDmgLog) # kb_angle
                    cmplwi r0, 367
                    beq SetAutoLinkVars_Set_Vec_Pull
                    b SetAutoLinkVars_Exit

                SetAutoLinkVars_Set_Vec_Pull:
                    crset bLerpSpeedCap
                    crset bUseVecTargetPos
                    crset bUseAtkMom
                    crset bCalcOverrideSpeed
                    crset bAfterHitlag

                    addi r3, rDefenderData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}

                    # use hitbox positions
                    psq_l f0, 0x4C(rHit), 0, 0
                    psq_st f0, 0x4(r3), 0, 0

                    # default 10 frames
                    li r0, 10
                    stw r0, 0(r3)

                SetAutoLinkVars_IsAutoLink:
                    # inputs
                    # frame, posX, posY should all be set in defender data
                    # cr6, cr7 = autolink flags

                    mr r3, rDefenderData
                    addi r4, rDefenderData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}

                    # set attacker speed to 0 if there is no attacker
                    # otherwise, use appropriate speed var if they are item or fighter
                    cmplwi rAttackerGObj, 0
                    beq- SetAutoLinkVars_IsAutoLink_NoAttacker

                    lhz r0, 0(rAttackerGObj)
                    cmplwi r0, 0x4 # fighter
                    psq_l f0, 0x80(rAttackerData), 0, 0
                    beq SetAutoLinkVars_IsAutoLink_SetAtkMom
                    cmplwi r0, 0x6 # item
                    psq_l f0, 0x40(rAttackerData), 0, 0
                    beq SetAutoLinkVars_IsAutoLink_SetAtkMom
                    
                    SetAutoLinkVars_IsAutoLink_NoAttacker:
                        crclr bLerpAtkMom
                        lfs f0, -0x7700(rtoc) # 0.0

                    SetAutoLinkVars_IsAutoLink_SetAtkMom:
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
                
                gecko.end

when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
