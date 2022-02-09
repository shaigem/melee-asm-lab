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

import ../melee

const
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
                gecko 0x8007a868
                # r3 = hit struct
                # r15 = attacker data
                # r25 = defender data
                # r17 = damage source?
                # r31 = points to direction var of struct dmg
                # f26/launch_speed_kb = calculated kb value based on hitbox settings

                regs (3), rHitStruct, (15), rAttackerData, (25), rDefenderData

                # check if angle of hitbox is 367
                lwz r0, 0x20(rHitStruct) # angle of hit struct
                cmplwi r0, 367
                bne+ OriginalExit_8007a868 # if not autolink angle, exit


                # -0x76CC(rtoc) = 0.01
                # -0x3A38(rtoc) = 0.03
                # -0x3D60(rtoc) = 0.20

                # init stack values to 0 for use in magnitude calculations
                stwu sp, -0x20(sp)
                li r0, 0
                stw r0, 0x14(sp) # x
                stw r0, 0x18(sp) # y
                stw r0, 0x1C(sp) # z

                # calculate pos_diff_hitbox_def
                lfs f1, 0x4C(rHitStruct) # hitbox x
                lfs f0, 0x1854(rDefenderData) # def collision x
                fsubs f2, f1, f0 # f2 = x_pos_diff_hitbox_def

                # check if it is a reverse hit
                lfs f1, 0xB0(rDefenderData) # defender x
                lfs f0, 0xB0(rAttackerData) # attacker x
                fsubs f1, f1, f0 # diff
                lfs f0, -0x7700(rtoc) # 0.0
                fcmpo cr0, f1, f0
                bge+ CalculateDiffY_8007a868
                fneg f2, f2 # negate x_pos_diff_hitbox_def
                
                CalculateDiffY_8007a868:
                    lfs f1, 0x50(rHitStruct) # hitbox y
                    lfs f0, 0x1858(rDefenderData) # def collision y
                    fsubs f1, f1, f0 # f1 = y_pos_diff_hitbox_def

                # setup stack for calculating magnitude of 20% pos_diff_hitbox_def
                lfs f0, -0x3D60(rtoc) # 0.20
                fmuls f5, f2, f0 # x_pos_diff_hitbox_def * 0.20
                stfs f5, 0x14(sp) # x
                fmuls f5, f1, f0 # y_pos_diff_hitbox_def * 0.20
                stfs f5, 0x18(sp) # y

                # calculate new kb angle by calling ATAN2
                # f2 = x_pos_diff_hitbox_def
                # f1 = y_pos_diff_hitbox_def
                bla r12, {Atan2}
                # f1 now contains new angle in radians
                # convert to degrees and store it
                lfs f0, -0x76C4(rtoc) # constant 180/PI
                fmuls f0, f0, f1
                fctiwz f0, f0
                stfd f0, 0xC(sp)
                lwz r0, 0x10(sp)
                stw r0, 0x4(r31) # store the new angle

                # calculate magnitude of pos_diff_hitbox_def
                addi r3, sp, 0x14
                bla r12, {PSVecMag}
                fmr f5, f1 # f5 = mag_pos_diff_hitbox_def
                # TODO add bkb here?

                # calculate magnitude of attacker momentum
                lfs f0, 0xC8(rAttackerData) # delta x
                stfs f0, 0x14(sp) # x
                lfs f0, 0xCC(rAttackerData) # delta y
                stfs f0, 0x18(sp) # y
                # TODO also verify if r3 is still the same 0x14 of sp
                # TODO verify if it messes with the z sp
                bla r12, {PSVecMag}

                # f1 = mag_attacker_momentum
                # adjust mag_attacker_momentum based on kb_growth of hitbox
                # kb_growth is our multiplier (100 = 1x)
                lwz rHitStruct, 0xC(r17) # hit struct
                lwz r0, 0x24(rHitStruct) # hitbox kb_growth
                sth r0, 0xC(sp)
                psq_l f3, 0xC(sp), 1, 5 # kb_growth as float
                lfs f0, -0x76CC(rtoc) # 0.01
                fmuls f0, f3, f0 # kb_growth_multiplier = kb_growth * 0.01
                fmadds f1, f1, f0, f5 # launch_speed = (mag_attacker_momentum * kb_growth_multiplier) + mag_pos_diff_hitbox_def
                
                # convert to knockback units
                lfs f0, -0x3A38(rtoc) # 0.03
                fdivs f26, f1, f0 # launch_speed_kb = launch_speed / 0.03

                # check kb cap using hitbox's WDSK value
                lwz r0, 0x28(rHitStruct) # hitbox wdsk
                sth r0, 0xC(sp)
                psq_l f0, 0xC(sp), 1, 5 # kb_cap = wdsk as float
                fcmpo cr0, f26, f0
                ble Epilog_8007a868 # launch_speed_kb <= kb_cap, don't adjust
                fmr f26, f0 # launch_speed_kb = kb_cap

                Epilog_8007a868:
                    addi sp, sp, 0x20
                    ba r12, 0x8007a938

                OriginalExit_8007a868:
                    ""

                gecko.end


when isMainModule:
    generate "./generated/autolink367.asm", AutoLink367
