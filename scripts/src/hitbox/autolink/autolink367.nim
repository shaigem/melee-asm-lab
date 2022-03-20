import ../../common/dataexpansion
import ../../melee


const
    HeaderInfo = MexHeaderInfo
    AutoLinkAngle = 367
    VortexTimeLimit = 6 # in frames

    AutoLink367 =
        createCode "Special Hitbox Angle: 367 v2.1.0":
            description: "Pulls victims towards the center of collided hitbox and adjusts launch speed"
            authors: ["sushie"]
            code:
                # TODO add x cap for 8007cd0c, if user ASDI into ground, cap speed to 1?
                # Main Patch for Pulling Opponents
                gecko 0x8006be00
                # pulls towards center of hitbox + adding attacker momentum
                # r31 = fighter data

                regs (r31), rFighterData

                # check if fighter is under the Attack_Vec_Pull effect (autolink 367)
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                "rlwinm." r0, r0, 0, {flag(ffAttackVecPull)}
                beq OriginalExit_8006BE00 # if not, exit

                prolog xTemp, xTempPosX, (0x4), xTempPosY, (0x4), xTempPosZ, (0x4)


                lbz r3, 0x221C(rFighterData)
                "rlwinm." r0, r3, 31, 31, 31
                li r3, 0
                beq StopPullIn_8006BE00

                # check vortex timer
                li r3, 1
                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames
                cmpwi r0, 0
                ble Exit_8006BE00
                cmpwi r0, {VortexTimeLimit}
                bgt StopPullIn_8006BE00

                mr r5, r0
                subi r0, r5, 1
                sth r0, sp.xTemp(sp)



                bl Data
                mflr r5

                lwz r3, {extFtDataOff(HeaderInfo, lastHitStruct)}(rFighterData)
                cmplwi r3, 0
                bgt AutoVecPull

                lwz r6, {extFtDataOff(HeaderInfo, lastExtHitStruct)}(rFighterData)
                cmplwi r6, 0
                beq StopPullIn_8006BE00

                AutoVecPullPos:
                    lwz r3, {extHitOff(targetPosNode)}(r6)
                    addi r4, r6, {extHitOff(targetPosOffsetX)}
                    addi r5, sp, sp.xTempPosX
                    bla r12, {JOBJGetWorldPos}

                    lfs f0, sp.xTempPosX(sp) # hitbox position
                    lfs f2, 0xB0(rFighterData) # pos x
                    fsubs f2, f0, f2 # hitbox x - pos x

                    lfs f0, sp.xTempPosY(sp) # hitbox position
                    lfs f1, 0xB4(rFighterData) # pos y
                    fsubs f1, f0, f1 # hitbox y - pos y

                    lwz r6, {extFtDataOff(HeaderInfo, lastExtHitStruct)}(rFighterData)
                    lfs f3, {extHitOff(targetPosPullSpeedMultiplier)}(r6)
                    b AddAtkLol

                AutoVecPull:
                    lfs f0, 0x4C(r3) # hitbox position
                    lfs f2, 0xB0(rFighterData) # pos x
                    fsubs f2, f0, f2 # hitbox x - pos x

                    lfs f0, 0x50(r3) # hitbox position
                    lfs f1, 0xB4(rFighterData) # pos y
                    fsubs f1, f0, f1 # hitbox y - pos y

                    lfs f3, 0x8(r5) # 0.20

                AddAtkLol:
                    li r3, 0
                    bl AddAtkMomentum_8006BE00
                    stfs f1, 0x90(rFighterData)
                    stfs f2, 0x8C(rFighterData)

                # psq_l f0, sp.xTemp(sp), 1, 5
                # lfs f1, 0x10(r5)
                # fdivs f3, f0, f1

                # lfs f4, -0x36d8(rtoc) # -3.0
                # fmr f1, f2 # kb_vel x
                # lfs f0, -0x36d8(rtoc) # -3.0
                # fcmpo cr0, f0, f1
                # bgt Balal
                # fneg f0, f0
                # fcmpo cr0, f1, f0
                # bgt Balal
                
                # b StoreTest
                # Balal:
                #     fmr f2, f0

                # CallLerp:
                #     bl Lerp

                # StoreTest:
                #     stfs f1, 0x8C(rFighterData)


                # lfs f1, 0x90(rFighterData)
                # lfs f0, -0x7640(rtoc) # -1.0
                # fcmpo cr0, f0, f1
                # bgt Balal2
                # lfs f0, -0x13BC(rtoc) # 3.0
                # fcmpo cr0, f1, f0
                # bgt Balal2
                
                # b StoreTest2
                # Balal2:
                #     fmr f2, f0

                # CallLerp2:
                #     bl Lerp

                # StoreTest2:
                #     stfs f1, 0x90(rFighterData)


                b Exit_8006BE00

                Lerp:
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

                SmoothDamp:
                    # r3 = current vec
                    # r4 = target vec
                    # r5 = current velocity
                    # f1 = smoothTime
                    # f2 = maxSpeed
                    # constants
                    # f3 = 0.235
                    # f5 = 0.48
                    mflr r0 
                    stw r0, 4(r1)
                    stwu r1, -0x88(r1) 
                    stfd f31, 0x80(r1) 
                    stfd f30, 0x78(r1) 
                    stfd f29, 0x70(r1)
                    stfd f28, 0x68(r1) 
                    stfd f27, 0x60(r1)
                    fmuls f27, f2, f1 # maxChange = maxSpeed * smoothTime
                    stw r31, 0x5c(r1) 
                    mr r31, r5 
                    stw  r30, 0x58(r1) 
                    addi r30, r4, 0 
                    stw  r29, 0x54(r1) 
                    addi r29, r3, 0
                    lfs f0, -0x7F64(rtoc) # 2.0
                    lfs f8, -0x7790(rtoc) # @11 # deltaTime, 1.0
                    fdivs f31, f0, f1 # omega = 2.0F / smoothTime
                    lfs f2, 4(r3) # current.y
                    lfs f1, 4(r4) # target.y
                    fmuls f9, f31, f8 # x = omega * deltaTime
                    lfs f4, 0(r3) # current.x
                    fsubs f28, f2, f1 # change_y = current - target
                    lwz r3, 0(r4) 
                    lwz r0, 4(r4) 
                    fmuls f7, f3, f9
                    lfs f3,0(r4) # target.x
                    fmuls f6,f5,f9 
                    fadds f5,f8,f9 
                    stw    r3,0x38(r1) 
                    fmuls  f7,f7,f9 
                    stw    r0,0x3c(r1) 
                    fmadds f5,f6,f9,f5 
                    lwz    r0,8(r4) 
                    fsubs  f29,f4,f3 # change_x = current.x - target.x
                    fmadds f2,f9,f7,f5 
                    stw    r0,0x40(r1) 
                    fmuls  f1,f28,f28 
                    fmuls  f0,f27,f27 # maxChangeSq
                    fdivs  f30,f8,f2 
                    fmadds f1,f29,f29,f1 # sqDist
                    fcmpo  cr0,f1,f0 
                    ble    SmoothDamp_e4
                    # clamp maximum speed
                    stfs f29, 0x20(sp) # x
                    stfs f28, 0x24(sp) # y
                    li r0, 0
                    stw r0, 0x28(sp)
                    addi r3, sp, 0x20
                    bla r12, {PSVecMag}
                    fdivs f0, f29, f1 # change_x / mag
                    fmuls f29, f27, f0
                    fdivs f0, f28, f1 # change_y / mag
                    fmuls f28, f27, f0
                    SmoothDamp_e4: 
                        lfs    f0,0(r29) 
                        fsubs  f0,f0,f29 
                        stfs   f0,0(r30) 
                        lfs    f0,4(r29) 
                        fsubs  f0,f0,f28 
                        stfs   f0,4(r30) 
                        lfs    f2,0(r31) 
                        lfs    f0,4(r31) 
                        fmadds f1,f31,f29,f2 
                        lfs    f6,-0x7790(rtoc) # 1.0 @11(0) 
                        fmadds f0,f31,f28,f0 
                        fmuls  f3,f6,f1 
                        fmuls  f4,f6,f0 
                        fnmsubs f0,f31,f3,f2 
                        fadds  f1,f28,f4 
                        fadds  f3,f29,f3 
                        fmuls  f0,f30,f0 
                        stfs   f0,0(r31) 
                        lfs    f0,4(r31) 
                        fnmsubs f0,f31,f4,f0 
                        fmuls  f0,f30,f0 
                        stfs   f0,4(r31) 
                        lfs    f0,4(r30) 
                        lfs    f2,0(r30) 
                        fmadds f0,f30,f1,f0 
                        lfs    f7,0x3c(r1) 
                        lfs    f1,4(r29) 
                        fmadds f3,f30,f3,f2 
                        lfs    f5,0x38(r1) 
                        lfs    f4,0(r29) 
                        fsubs  f2,f7,f1 
                        fsubs  f1,f0,f7 
                        lfs    f0, -0x7700(rtoc) # 0.0 @14(0) 
                        fsubs  f4,f5,f4 
                        fsubs  f3,f3,f5 
                        fmuls  f1,f2,f1 
                        fmadds f1,f4,f3,f1 
                        fcmpo  cr0,f1,f0 
                        ble    SmoothDamp_Epilog
                        fsubs  f1,f5,f5 
                        fsubs  f0,f7,f7 
                        fdivs  f1,f1,f6 
                        fdivs  f0,f0,f6 
                        stfs   f1,0(r31) 
                        stfs   f0,4(r31) 

                    # r31 = current velocity
                    # r30 = target vec
                    # r29 = current vec
                    SmoothDamp_Epilog: # 198
                        lwz r0, 0x8c(r1)                 
                        lfd f31, 0x80(r1) 
                        lfd f30, 0x78(r1) 
                        lfd f29, 0x70(r1) 
                        lfd f28, 0x68(r1) 
                        lfd f27, 0x60(r1) 
                        lwz r31, 0x5c(r1) 
                        lwz r30, 0x58(r1) 
                        lwz r29, 0x54(r1) 
                        addi r1, r1, 0x88 
                        mtlr r0 
                        blr 

                Data:
                    blrl
                    ".float" 0.48
                    ".float" 0.235
                    ".float" 0.2 # smoothTime
                    ".float" 100 # maxSpeed
                    ".float" 4

                AddAtkMomentum_8006BE00:
                    # inputs
                    # r3 = 0 to add, 1 to set
                    # f1 = y to adjust
                    # f2 = x to adjust
                    # f3 = % of attacker velocity (default: 0.20 = 20%)
                    # outputs
                    # f1 = adjusted y
                    # f2 = adjusted x
                    # adjust with attacker's momentum
                    lwz r4, 0x1868(rFighterData) # hit source/attacker
                    cmplwi r4, 0
                    "beqlr-"
                    #beq OriginalExit_8006BE00 # no attacker, skip this part (TODO check if items?)
                    regs (4), rAttackerData
                    lwz rAttackerData, 0x2C(r4) # data of attacker
                    cmplwi rAttackerData, 0
                    "beqlr-"

                    cmplwi r3, 1
                    beq SetAtkMomentum_8006BE00

                    # add momentum
                    lfs f0, 0x84(rAttackerData) # attacker vel y
                    fmadds f1, f1, f3, f0 # (y * 0.20) + attacker velocity y
                    lfs f0, 0x80(rAttackerData) # attacker vel x
                    fmadds f2, f2, f3, f0 # (x * 0.20) + attacker velocity x
                    blr

                    SetAtkMomentum_8006BE00:
                        lfs f1, 0x84(rAttackerData) # attacker vel y
                        lfs f2, 0x80(rAttackerData) # attacker vel x
                        blr


                CapGroundSpeed_8006BE00:
                    # cap 0xF0, velocity ground upon hit?
                    lfs f0, -0x36d8(rtoc) # -3.0
                    fcmpo cr0, f0, f3
                    bgt SetGroundCap_8006BE00
                    fneg f0, f0
                    fcmpo cr0, f3, f0
                    bgt SetGroundCap_8006BE00
                    b StoreGroundLaunchSpeed_8006BE00
                    SetGroundCap_8006BE00:
                        fmr f3, f0
                    StoreGroundLaunchSpeed_8006BE00:
                        stfs f3, 0xF0(rFighterData)
                    blr

                CapLaunchSpeeds_8006BE00:
                    # inputs
                    # f1 = y to cap
                    # f2 = x to cap
                    # outputs
                    # f1 = capped y
                    # f2 = capped x
                    # cap lower and upper x to -3, 3
                    lfs f0, -0x36d8(rtoc) # -3.0
                    fcmpo cr0, f0, f2
                    bgt SetXCap_8006BE00
                    fneg f0, f0
                    fcmpo cr0, f2, f0
                    bgt SetXCap_8006BE00
                    b StoreXLaunchSpeed_8006BE00
                    SetXCap_8006BE00:
                        fmr f2, f0
                    StoreXLaunchSpeed_8006BE00:
                        ""
                        #stfs f2, 0x8C(rFighterData)

                    # cap lower and upper y to -1, 3                
                    lfs f0, -0x7640(rtoc) # -1                    
                    fcmpo cr0, f0, f1
                    bgt SetYCap_8006BE00
                    lfs f0, -0x13BC(rtoc) # 3.0
                    fcmpo cr0, f1, f0
                    bgt SetYCap_8006BE00
                    b StoreYLaunchSpeed_8006BE00
                    SetYCap_8006BE00:
                        fmr f1, f0
                    StoreYLaunchSpeed_8006BE00:
                        #stfs f1, 0x90(rFighterData)
                        ""
                    blr
                
                StopPullIn_8006BE00:
                    # inputs
                    # r3 = add attacker momentum bool (1 or 0)
                    lfs f1, 0x90(rFighterData)
                    lfs f2, 0x8C(rFighterData)
                    lfs f3, -0x6A7C(rtoc) # 1
                    cmpwi r3, 0 # 0 = don't add attacker momentum
                    beq StopPullInCap_8006BE00
                    # otherwise, set our momentum to 100% of attacker momentum
#                    li r3, 1
#                    bl AddAtkMomentum_8006BE00
                    StopPullInCap_8006BE00:
                        bl CapLaunchSpeeds_8006BE00

                        li r3, 0
                        lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                        rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
                        stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)

                StoreNewSpeeds_8006BE00:
                    stfs f1, 0x90(rFighterData)
                    stfs f2, 0x8C(rFighterData)

                Exit_8006BE00:
                    epilog

                OriginalExit_8006BE00:
                    lwz r12, 0x21D0(rFighterData)

                # # patch for NOT entering DamageFlyRoll if attack vec pull effect is active
                # gecko 0x8008e128
                # lbz r3, {extFtDataOff(HeaderInfo, fighterFlags)}(r29)
                # "rlwinm." r3, r3, 0, {flag(ffAttackVecPull)}
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
                lwz r3, 0x1848(rData) # kb_angle
                cmpwi r3, {AutoLinkAngle}
                blt OrigExit_8007DD88
                cmpwi r3, 368
                bgt OrigExit_8007DD88

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
                    rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rData)
                OrigExit_8007DD88:
                    lfd f0, 0x58(sp) # orig code line

                # # CalculateKnockback Function Patch - Sets the Necessary Hit Variables
                # gecko 0x8007a934
                # # r0 = hitbox angle
                # # r3 = hit struct
                # # r15 = attacker data
                # # r25 = defender data
                # # r17 = damage source?
                # # r31 = points to direction var of struct dmg
                # # f26/launch_speed_kb = calculated kb value based on hitbox settings
                # regs (3), rHitStruct, (15), rAttackerData, (25), rDefenderData

                # # check if angle of hitbox is 367
                # cmplwi r0, {AutoLinkAngle}
                # beq AttackVecPull
                # cmplwi r0, 368
                # bne+ OriginalExit_8007a868 # if not autolink angle, exit

                # psq_l f0, {extHitOff(targetPosOffsetX)}({cb.shvRegExtHit}), 0, 0

                # b OriginalExit_8007a868

                # AttackVecPull:
                #     lwz rHitStruct, 0xC(r17) # hit struct
                #     stw rHitStruct, {extFtDataOff(HeaderInfo, lastHitStruct)}(rDefenderData)
                # OriginalExit_8007a868:
                #     stw r0, 0x4(r31) # orig code line, sets kb_angle
                #     # reset attack vec pull effect
                #     li r3, 0
                #     lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                #     rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
                #     stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                    
                gecko.end

proc createAutolinkPatch*(): GeckoCodeScript =
    addHook(cbkSetHitVarsOnHit, (cb) => (ppc do:
        li r3, 0
        li r4, 0
        lwz r0, 0x1848({cb.shvRegDefData}) # kb_angle
        cmplwi r0, {AutoLinkAngle}
        beq shv_AttackVecPull
        cmplwi r0, 368
        beq shv_AttackVecTargetPos
        b shv_AutolinkExit

        shv_AttackVecPull:
            mr r3, {cb.shvRegHitStruct}
            b shv_AutolinkExit

        shv_AttackVecTargetPos:
            mr r4, {cb.shvRegExtHit}
        
        shv_AutolinkExit:
            stw r3, {extFtDataOff(HeaderInfo, lastHitStruct)}({cb.shvRegDefData})
            stw r4, {extFtDataOff(HeaderInfo, lastExtHitStruct)}({cb.shvRegDefData})
            li r3, 0
            lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}({cb.shvRegDefData})
            rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
            stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}({cb.shvRegDefData})
        ))
    result = AutoLink367