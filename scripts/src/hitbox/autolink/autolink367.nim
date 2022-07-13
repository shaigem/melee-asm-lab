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

                gecko 0x801510b8
                cmpwi r4, 343
                beq- CalcAutoLinkSpeed_OriginalExit

                # inputs
                # r3 = fighter data
                # r4 = ptr to VecTargetPos of fighter data
                # cr6, cr7 = autolink bools
                # outputs
                # f1 = vel y
                # f2 = vel x

                lfs f1, -0x7700(rtoc) # 0.0
                lfs f2, -0x7700(rtoc) # 0.0

                crnot eq, bUseAtkMom # !bUseAtkMom
                crandc eq, eq, bUseVecTargetPos # !bUseAtkMom && !bUseVecTargetPos
                "beqlr-" # if both are false, return 0

                sp.push
                sp.temp xTemp, (0xC)
                lwz r0, 0(r4)
                sth r0, sp.xTemp(sp)
                psq_l f0, sp.xTemp(sp), 1, 5
                fres f0, f0
                sp.pop

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

                    "bf- bCalcOverrideSpeed, 0f"
                    # multiply diff by 1/frames
                    ps_muls0 f2, f2, f0

                    0:
                        # add attacker momentum, if any
                        ps_add f2, f1, f2 # attacker momentum + diff
                        ps_merge10 f1, f2, f2

                blr

                CalcAutoLinkSpeed_OriginalExit:
                    stw r0, 0x4(sp)

                # Main Patch - Physics Callback
                gecko 0x8006b898
                # r31 = fighter data

                regs (r31), rFighterData

                # check if fighter is under the ATTACK_VEC_PULL effect
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                "rlwinm." r0, r0, 0, {flag(ffAttackVecTargetPos)}
                beq AutoLinkPhysics_OriginalExit # if not, exit

                prolog xU, (0x2), xL, (0x2), xTempFrameInfo, (0x4), xTempVec2, (0x8)
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
                cmplwi r0, 1
#                cror lt, bCalcOverrideSpeed, bAfterHitlag
#                crand eq, eq, lt
#                bt eq, AutoLinkPhysics_SetLaunchSpeeds
                beq- AutoLinkPhysics_SetLaunchSpeeds


                addi r3, rFighterData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                psq_l f0, 0x4(r3), 0, 0
                psq_st f0, 0x8C(rFighterData), 0, 0

                psq_l f1, sp.xTempFrameInfo(sp), 0, 0
                bl AutoLinkPhysics_LerpVels
                b AutoLinkPhysics_Exit

                AutoLinkPhysics_SetLaunchSpeeds:
                    addi r4, rFighterData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}

                    bt bAfterHitlag, AutoLinkPhysics_SetLaunchSpeeds_Recalc

                    AutoLinkPhysics_SetLaunchSpeeds_NoCalc:
                        psq_l f2, 0x8C(rFighterData), 0, 0
                        bf bCalcOverrideSpeed, AutoLinkPhysics_SetLaunchSpeeds_Set
                        psq_l f2, 0x4(r4), 0, 0
                        b AutoLinkPhysics_SetLaunchSpeeds_Set

                    AutoLinkPhysics_SetLaunchSpeeds_Recalc:
                        mr r3, rFighterData
                        bla r12, 0x801510b8

                        bt bCalcOverrideSpeed, AutoLinkPhysics_SetLaunchSpeeds_Set

                        # otherwise, change current launch speed direction
                        
                        # normalize the new speed vectors
                        addi r3, sp, sp.xTempVec2
                        psq_st f2, 0(r3), 0, 0
                        bla r12, 0x8000d3b0

                        # calc magnitude of old speed
                        addi r3, rFighterData, 0x8C
                        bla r12, 0x80342dfc
                        
                        psq_l f2, sp.xTempVec2(sp), 0, 0
                        ps_mul f2, f2, f1
                        b AutoLinkPhysics_SetLaunchSpeeds_Set

                    AutoLinkPhysics_SetLaunchSpeeds_Set:
                        psq_st f2, 0x8C(rFighterData), 0, 0
                        psq_st f2, 0x4(r4), 0, 0
                        b AutoLinkPhysics_Exit

                AutoLinkPhysics_LerpVels:
                    # inputs
                    # f1[0] = currentFrame, f1[1] = 1/frames
                    ps_muls1 f4, f1, f1 # multiply currentFrame by 1/frames to get t
                    addi r3, rFighterData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                    psq_l f1, 0x4(r3), 0, 0
                    #psq_l f1, 0x8C(rFighterData), 0, 0
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

                gecko.end

when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
