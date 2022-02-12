#[                     stwu sp, -0x30(sp)

                    # first calculate pos diff x between hitbox & defender
                
                    lfs f1, 0x4C(r29) # hitbox x
                    lfs f0, 0x1854(r30) # defender coll x
                    fsubs f2, f1, f0 # diff x

                    bl Constants
                    mflr r3

                    lfs f0, 0x8(r3) # calculate 20% of diff x
                    fmuls f2, f2, f0

                    stfs f2, 0x14(sp) # x


                    # check if reverse hit
                    lfs f1, 0xB0(r30) # defender x
                    lfs f0, 0xB0(r31) # attacker x
                    fsubs f1, f1, f0
                    lfs f0, -0x7700(rtoc) # 0.0
                    fcmpo cr0, f1, f0
                    %`bge+` CalcDiffY
                    # if reverse hit, negate the diff x
                    fneg f2, f2

                    CalcDiffY:
                        lfs f1, 0x50(r29) # hitbox y
                        lfs f0, 0x1858(r30) # defender coll y
                        fsubs f1, f1, f0 # diff y

                        lfs f0, 0x8(r3) # 20% of diff y
                        fmuls f1, f1, f0 # diff y * 0.20
                        stfs f1, 0x18(sp) # y

                    %branchLink("0x80022c30") # atan2
                    lfs f0, -0x76C4(rtoc) # 180/PI convert radian to degrees
                    fmuls f1, f0, f1
                    fctiwz f0, f1
                    stfd f0, -0x8(sp)
                    lwz r3, -0x4(sp)
                    stw r3, 0x1848(r30) # store new kb_angle

                    # calculate magnitude of 20% hitbox opponent diff
                    addi r3, sp, 0x14
                    li r0, 0
                    stw r0, 0x1C(sp) # z
                    %branchLink("0x80342dfc") # vector magnitude

                    stfs f1, 0x2C(sp) # save our 20% hitbox opponent diff magnitude

                    # calculate magnitude of 100% attacker velocity
                    lfs f0, 0xC8(r31) # delta x
                    stfs f0, 0x14(sp)
                    lfs f0, 0xCC(r31) # delta y
                    stfs f0, 0x18(sp)
                    addi r3, sp, 0x14
                    li r0, 0
                    stw r0, 0x1C(sp) # z
                    %branchLink("0x80342dfc") # vector magnitude

                    # kb_growth = attacker speed multiplier
                    # wdsk = kb cap (100 = maximum)
                    # bkb = ?
                    lwz r3, -0x514C(r13) # static vars??
                    lfs f2, 0xF4(r3) # load 0.01 into f0

                    lwz r0, 0x24(r29) # kb_growth
                    sth r0, 0x20(sp)
                    psq_l f0, 0x20(sp), 1, 5

                    fmuls f0, f2, f0 # kb_growth * 0.01

                    fmuls f1, f1, f0 # attacker velocity magnitude * kb_growth multiplier


                    lfs f0, 0x2C(sp) # 20% mag_hitbox_opp_diff
                    fadds f1, f1, f0 # 100% mag_atk_vel + 20% mag_hitbox_opp_diff



                    bl Constants
                    mflr r3

                    # convert to knockback units
                    lfs f0, 0xC(r3)
                    fdivs f1, f1, f0

                    # adjust our force_applied kb val

                    lwz r3, -0x514C(r13) # static vars??
                    lfs f2, 0xF4(r3) # load 0.01 into f0

                    lwz r0, 0x28(r29) # wdsk
                    sth r0, 0x20(sp)
                    psq_l f0, 0x20(sp), 1, 5

                    fcmpo cr0, f1, f0 # cap
                    ble Done # <= wdsk, store
                    fmr f1, f0
                    Done:
                        stfs f1, 0x1850(r30)
                        addi sp, sp, 0x30
                    
       #[          TowardsHitboxCenter:
                    lfs f1, 0x4C(r29) # hitbox x
                    lfs f0, 0xB0(r30) # defender x
                    fsubs f2, f1, f0 # diff x
                    # check if reverse hit
                    lfs f1, 0xB0(r30) # defender x
                    lfs f0, 0xB0(r31) # attacker x
                    fsubs f1, f1, f0
                    lfs f0, -0x7700(rtoc) # 0.0
                    fcmpo cr0, f1, f0
                    %`bge+` CalcDiffY
                    # if reverse hit, negate the diff x
                    fneg f2, f2
                    CalcDiffY:
                        lfs f1, 0x50(r29) # hitbox y
                        lfs f0, 0xB4(r30) # defender y
                        fsubs f1, f1, f0 # diff y
                    %branchLink("0x80022c30") # atan2
                    lfs f0, -0x76C4(rtoc) # 180/PI convert radian to degrees
                    fmuls f1, f0, f1
                    fctiwz f0, f1
                    stfd f0, -0x8(sp)
                    lwz r3, -0x4(sp)
                    stw r3, 0x1848(r30) # store new kb_angle
                     ]# ]#


#[         patchInsertAsm "8006be00":
            lwz r3, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            cmplwi r3, 0
            beq OriginalExit
            
            VortexKnockback:
                %backup

                lwz r0, 0x18AC(r31) # time_since_hit in frames
                cmpwi r0, 5
                
#                lfs f1, -0x778C(rtoc) # 0.0
#                lfs f2, -0x778C(rtoc) # 0.0
                lfs f1, 0x8C(r31)
                lfs f2, 0x90(r31)
                bge NoMoreTime

                bl DataBob
                mflr r5


                lwz r0, 0(r3)
                cmpwi r0, 0
                addi r4, r31, {extFtDataOff(HeaderInfo, lastHitX)} # pos of hitbox
                beq Bob
#                addi r4, r3, 0x4C # pos of hitbox
                Bob:
                    mr r3, r28 # gobj
                    lfs f1, 0x8(r5) # 
                    lfs f2, 0xC(r5)
                    bl ToPointFunc

                bl CalcAttackerMomentum
                b Epilog
                CalcAttackerMomentum:


                    lwz r4, 0x1868(r31)
                    lwz r4, 0x2C(r4)


                    lfs f3, 0x84(r4)
                    lfs f0, 0xB4(r4)
                    fadds f0, f0, f3

                    lfs f3, 0xB4(r4)
                    fsubs f0, f0, f3
                    fadds f2, f0, f2


                    lfs f3, 0x80(r4)
                    lfs f0, 0xB0(r4)
                    fadds f0, f0, f3

                    lfs f3, 0xB0(r4)
                    fsubs f0, f0, f3

                    fadds f1, f0, f1

                stfs f1, 0x8C(r31)
                stfs f2, 0x90(r31)
                blr
                #b Epilog

#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f2, 0x30(r1)
                lfs f0, -0x3D60(rtoc) # 0.20

                fmuls f1, f1, f0
                fmuls f2, f2, f0

                lwz r0, 0x5c(r1)
                lfd f31, 0x50(r1)
                lfd f30, 0x48(r1)
                lfd f29, 0x40(r1)
                lwz r31, 0x3c(r1)
                lwz r30, 0x38(r1)
                addi r1, r1, 0x58
                mtlr r0
                blr
            
           
            Data:
                blrl
                %`.float`(0.20)
                %`.float`(0.12) # was 0.08
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80)

            DataBob:
                blrl
                %`.float`(0.48)
                %`.float`(0.235)
                %`.float`(0.16) # smoothTime
                %`.float`(100) # maxSpeed

                NoMoreTime:
                    li r0, 0
                    stw r0, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitX)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitY)}(r31)
                    stw r0, {extFtDataOff(HeaderInfo, lastHitZ)}(r31)
                    bl CalcAttackerMomentum
                    lfs f0, -0x13BC(rtoc) # 3.0
                    fcmpo cr0, f2, f0
                    blt CheckNegative
                    # if >= 3
                    fmr f2, f0
                    b SetYVel

                    CheckNegative:
                        lfs f0, -0x7640(rtoc) # -1
                        fcmpo cr0, f2, f0
                        bge SetYVel
                        fmr f2, f0

                    SetYVel:
                        stfs f2, 0x90(r31) # store into kb_vel y 
        
                    lfs f0, -0x13BC(rtoc) # 3.0
                    fcmpo cr0, f1, f0
                    blt CheckNegativeX
                    # if >= 3
                    fmr f1, f0
                    b SetXVel

                    CheckNegativeX:
                        lfs f0, -0x36d8(rtoc) # -3
                        fcmpo cr0, f1, f0
                        bge SetXVel
                        fmr f1, f0

                    SetXVel:
                        stfs f1, 0x8C(r31) # store into kb_vel x

# meteor cancelling disabled
#[                     fmr f0, f2
                    fmr f2, f1
                    fmr f1, f0
                    %branchLink("0x80022c30") # atan2
                    lfs f0, -0x76c4(rtoc) # 180/pi. Convert radians to degrees
                    fmuls f1, f0, f1
                    fctiw f0, f1
                    stfd f0, -8(sp)
                    lwz r3, -4(sp)
                    cmpwi r3, 0 # force angle into [0, 360]
                    bge positive_angle # (so meteor cancelling works)
                    addi r3, r3, 360
                    positive_angle:
                        # check for meteor cancelling
                        li r0, 230
                        cmplw r0, r3
                        bgt Epilog
                        li r0, 310
                        cmplw r3, r0
                        bgt Epilog
                        # allow meteor cancelling
                        li r0, 1
                        stb r0, 0x235A(r31) # can meteor cancel
                        lwz r3, -0x514C(r13)
                        lwz r0, 0x7f0(r3) # window of 8 frames
                        stb r0, 0x235B(r31) # window ]#
                Epilog:
                    %restore

            OriginalExit:
                lwz r12, 0x21D0(r31) # orig code line



#[         # Reset Custom ExtFighterData vars that are involved at the end of Hitlag for Fighters
        patchInsertAsm "8006d1d8":
            # reset vars that need to be 1
            # r31 = fighter data
            lfs f0, -0x7790(rtoc) # 1
            stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(r31)


            lwz r3, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            cmplwi r3, 0
            beq Exit

            stwu sp, -0x30(sp)
            # first calculate pos diff x between hitbox & defender
                
            lfs f1, 0x4C(r3) # hitbox x
            lfs f0, 0xB0(r31) # defender coll x
            fsubs f2, f1, f0 # diff x

            lfs f0, -0x3D60(rtoc) # calculate 20% of diff x
            fmuls f2, f2, f0
            stfs f2, 0x14(sp) # x

            lwz r4, 0x1868(r31)
            lwz r4, 0x2C(r4)

            # check if reverse hit
            lfs f1, 0xB0(r31) # defender x
            lfs f0, 0xB0(r4) # attacker x
            fsubs f1, f1, f0
            lfs f0, -0x7700(rtoc) # 0.0
            fcmpo cr0, f1, f0
            %`bge+` CalcDiffY
            # if reverse hit, negate the diff x
            fneg f2, f2
            CalcDiffY:
                lfs f1, 0x50(r3) # hitbox y
                lfs f0, 0xB4(r31) # defender coll y
                fsubs f1, f1, f0 # diff y
                lfs f0, -0x3D60(rtoc) # 20% of diff y
                fmuls f1, f1, f0 # diff y * 0.20
                stfs f1, 0x18(sp) # y

            bl Data
            mflr r5

            addi r4, r3, 0x4C # pos of hitbox
            lwz r3, 0(r31)
            lfs f1, 0(r5)
            lfs f2, 0x4(r5)
            bl ToPointFunc

            lwz r4, 0x1868(r31)
            lwz r4, 0x2C(r4)


            lfs f3, 0x84(r4)
            lfs f0, 0xB4(r4)
            fadds f0, f0, f3

            lfs f3, 0xB4(r4)
            fsubs f0, f0, f3


            fadds f2, f0, f2 # attacker y + 20% diffy
            lfs f0, -0x13BC(rtoc) # 3.0
            fcmpo cr0, f2, f0
            blt CheckNegative
            # if >= 3
            fmr f2, f0
            b SetYVel

            CheckNegative:
                lfs f0, -0x7640(rtoc) # -1
                fcmpo cr0, f2, f0
                bge SetYVel
                fmr f2, f0

            SetYVel:
                stfs f2, 0x90(r31) # store into kb_vel y 

            lfs f3, 0x80(r4)
            lfs f0, 0xB0(r4)
            fadds f0, f0, f3

            lfs f3, 0xB0(r4)
            fsubs f0, f0, f3

#            lfs f1, 0x14(sp)
            fadds f1, f0, f1 # attacker x + 20% diff x
            
            lfs f0, -0x13BC(rtoc) # 3.0
            fcmpo cr0, f1, f0
            blt CheckNegativeX
            # if >= 3
            fmr f1, f0
            b SetXVel

            CheckNegativeX:
                fneg f0, f0
                fcmpo cr0, f1, f0
                bge SetXVel
                fmr f1, f0

            SetXVel:
                stfs f1, 0x8C(r31) # store into kb_vel x

            li r0, 0
            stw r0, {extFtDataOff(HeaderInfo, lastHitPtr)}(r31)
            
            addi sp, sp, 0x30

            b Exit

#[ f1 = speed stuff
   f2 = speed stuff
   r3 = our gobj
   r4 = vec pos of where to go ]#
            ToPointFunc:
                mflr r0
                stw r0, 4(r1)
                stwu r1, -0x58(r1)
                stfd f31, 0x50(r1)
                fmr f31, f2
                stfd f30, 0x48(r1)
                fmr f30, f1
                stfd f29, 0x40(r1)
                stw r31, 0x3c(r1)
                stw r30, 0x38(r1)
#                addi r30, r5, 0
                addi r5, r1, 0x2c
                lwz r31, 0x2c(r3)
                addi r3, r4, 0
                addi r4, r31, 0xb0
                %branchLink("0x8000D4F8")
                #bl func_8000D4F8
                lfs f1, 0x2c(r1)
                lfs f0, 0x30(r1)
                fmuls f2, f1, f1
                lfs f3, 0x34(r1)
                fmuls f1, f0, f0
                lfs f0, -0x57E8(rtoc)
                fmuls f3, f3, f3
                fadds f1, f2, f1
                fadds f29, f3, f1
                fcmpo cr0, f29, f0
                ble lbl_8015BEF8
                frsqrte f1, f29
                lfd f3, -0x57D8(rtoc)
                lfd f2, -0x57D0(rtoc)
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f1, f1, f0
                fmul f0, f1, f1
                fmul f1, f3, f1
                fnmsub f0, f29, f0, f2
                fmul f0, f1, f0
                fmul f0, f29, f0
                frsp f0, f0
                stfs f0, 0x24(r1)
                lfs f29, 0x24(r1)
                lbl_8015BEF8:
                    fcmpo cr0, f29, f30
                    bge lbl_8015BF0C
                    b lbl_8015BF40
                lbl_8015BF0C:
#                    stfs f29, 0(r30)
                    addi r3, r1, 0x2c
                    %branchLink("0x8000D2EC")
#                    bl func_8000D2EC
                    fmuls f1, f29, f31
                    lfs f0, 0x2c(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x2c(r1)
                    lfs f0, 0x30(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x30(r1)
                    lfs f0, 0x34(r1)
                    fmuls f0, f0, f1
                    stfs f0, 0x34(r1)
                lbl_8015BF40:
                    lfs f1, 0x2c(r1)
#                    stfs f0, 0x8c(r31)
                    lfs f2, 0x30(r1)
#                    stfs f0, 0x90(r31)
                    lwz r0, 0x5c(r1)
                    lfd f31, 0x50(r1)
                    lfd f30, 0x48(r1)
                    lfd f29, 0x40(r1)
                    lwz r31, 0x3c(r1)
                    lwz r30, 0x38(r1)
                    addi r1, r1, 0x58
                    mtlr r0
                    blr
            Data:
                blrl
                %`.float`(0.20)
                %`.float`(0.12) # was 0.08
                %`.float`(0.50)
                %`.float`(10)
                %`.float`(80)

            Exit:
                lwz r0, 0x24(sp)
                

 ]# ]#

import ../melee
import ../common/dataexpansion

const
    HeaderInfo = MexHeaderInfo
    VortexTimeLimit = 5 # in frames

    AutoLink367* =
        createCode "Special Hitbox Angle: 367":
            description: "Pulls victims towards the center of collided hitbox and adjusts launch speed"
            authors: ["sushie"]
            code:
                # Launch speed = attacker momentum + (hitbox position - opponent position) * 0.2, credits to DrakRoar#7297
                # Victims are pulled towards center of hitbox
                # Overriden Hitbox Settings:
                # BKB = base knockback
                # WDSK = kb cap
                # KB Growth = attacker momentum multiplier

                gecko 0x8006be00
                # r31 = fighter data

                regs (r31), rFighterData

                # check if fighter is under the Attack_Vec_Pull effect (autolink 367)
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                "rlwinm." r0, r0, 0, {flag(ffAttackVecPull)}
                beq OriginalExit_8006BE00 # if not, exit

                prolog xDiffX, (0x4), xDiffY, (0x4), xDiffZ, (0x4)

                # check vortex timer
                lwz r0, 0x18AC(rFighterData) # time_since_hit in frames
                cmpwi r0, {VortexTimeLimit} # TODO check when it goes to FFFFFFFF
                bge StopPullIn_8006BE00

                # calculate (hitbox position - opponent position)
                addi r3, rFighterData, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)} # hitbox position
                addi r4, rFighterData, 0xB0 # defender's position
                addi r5, sp, sp.xDiffX
                bla r12, {Vector3SubtractR5}
                lfs f2, sp.xDiffX(sp)
                lfs f1, sp.xDiffY(sp)
                bl AddAtkMomentum_8006BE00
                b StoreNewSpeeds_8006BE00

                AddAtkMomentum_8006BE00:
                    # inputs
                    # f1 = y to adjust
                    # f2 = x to adjust
                    # outputs
                    # f1 = adjusted y
                    # f2 = adjusted x
                    # adjust with attacker's momentum
                    lwz r3, 0x1868(rFighterData) # hit source/attacker
                    cmplwi r3, 0
                    "beqlr-"
                    #beq OriginalExit_8006BE00 # no attacker, skip this part (TODO check if items?)
                    regs (3), rAttackerData
                    lfs f3, -0x3D60(rtoc) # 0.20
                    lwz rAttackerData, 0x2C(r3) # data of attacker
                    lfs f0, 0x84(rAttackerData) # attacker vel y
                    fmadds f1, f1, f3, f0 # (y * 0.20) + attacker velocity y
                    lfs f0, 0x80(rAttackerData) # attacker vel x
                    fmadds f2, f2, f3, f0 # (x * 0.20) + attacker velocity x
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
                    li r3, 0
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                    rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rFighterData)
                    lfs f1, 0x90(rFighterData)
                    lfs f2, 0x8C(rFighterData)
                    #lfs f1, -0x778C(rtoc) # 0.0
                    #fmr f2, f1 # 0.0
                    bl AddAtkMomentum_8006BE00
                    bl CapLaunchSpeeds_8006BE00

                StoreNewSpeeds_8006BE00:
                    stfs f1, 0x90(rFighterData)
                    stfs f2, 0x8C(rFighterData)

                Exit_8006BE00:
                    epilog

                OriginalExit_8006BE00:
                    lwz r12, 0x21D0(rFighterData)


                gecko 0x8007a86c
                # r0 = hitbox angle
                # r3 = hit struct
                # r15 = attacker data
                # r25 = defender data
                # r17 = damage source?
                # r31 = points to direction var of struct dmg
                # f26/launch_speed_kb = calculated kb value based on hitbox settings
                regs (3), rHitStruct, (15), rAttackerData, (25), rDefenderData

                # check if angle of hitbox is 367
                cmplwi r0, 367
                li r3, 0
                bne+ OriginalExit_8007a868 # if not autolink angle, exit
                
                # TODO set angle to 80 if grounded?
                
                lwz rHitStruct, 0xC(r17) # hit struct
                lfs f0, 0x4C(rHitStruct) # hitbox pos X
                stfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterX)}(rDefenderData)
                lfs f0, 0x50(rHitStruct) # hitbox pos y
                stfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterY)}(rDefenderData)
                lfs f0, 0x54(rHitStruct) # hitbox pos z
                stfs f0, {extFtDataOff(HeaderInfo, lastHitboxCollCenterZ)}(rDefenderData)
                li r3, 1
                OriginalExit_8007a868:
                    cmplwi r0, 362 # orig code line
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                    rlwimi r0, r3, 4, {flag(ffAttackVecPull)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefenderData)
                    
                gecko.end


when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
