import ../../melee


#[ 
    
    stage.Kongo    = 0x05  # Kongo Jungle (Kongo)
    7, 6 
    
    stage.Izumi    = 0x02  # Fountain of Dreams (Izumi)
    stage.ppp      = 0x1C  # Dream Land N64 (old ppp)
    3, 3
    stage.Zebes    = 0x06  # Brinstar (Zebes)
    8, 14
    stage.Inishie2 = 0x14  # Mushroom Kingdom II (Inishie2)
    1, 6
stage.GreatBay = 0x0D  # Great Bay
    0, 3


    8015c010 - function moves towards player (follows based on x only)
    f1 = speed of movement


    mh attributes
    # 0xA0 = Gootsubusuwait # of frames before punching down (default = 80 frames)
    # 0xA4 = Gootsubusuwait target move speed
    # 0xB8 = Paatsubusu target move speed
    # 0x80 = Drill target move speed
    # 0xF4 = anim speed for rapid fire gun (default = 2.0)
    ]#

func patchFighterOnLoadMasterHand(): string =
    result = ppc:
        gecko 0x8014fcb8
        # r30 = fighter data
        # r31 = attributes start?
        data.start
        CommonDataTable:
            0:
                ".float" 5.0
            1:
                ".float" 2.0
            2:
                ".float" 45.0
            3:
                ".float" 45.0
            4:
                ".float" 2.0
            5:
                ".float" 0.0174533
            6:
                ".float" 0.872665
        data.struct 0, "", xMainMoveSpeed, 
            xSecondaryMoveSpeed,
            xStartOffsetX,
            xStartOffsetY,
            xFreeMovementSpeed,
            xRadianOneDegree,
            xRadianFiftyDegrees

        data.table masterHandData
        0: ".float" -1.6
        1: ".float" 3.25
        data.struct 0, "", xHarauLoopXVel, xYubideppou2AnimRate

        data.table crazyHandData
        0: ".float" 1.4
        data.struct 0, "", xHarauLoopXVel
        data.end r3

        lfs f0, xStartOffsetX(r3)
        stfs f0, 0x30(r31)

        lfs f0, xStartOffsetY(r3)
        stfs f0, 0x34(r31)

        lfs f0, xSecondaryMoveSpeed(r3)
        stfs f0, 0x28(r31)

        lfs f0, xMainMoveSpeed(r3)
        stfs f0, 0x2C(r31)

        data.get r3, masterHandData
        lfs f0, xYubideppou2AnimRate(r3)
        stfs f0, 0xF4(r31)

        # 80d43b8c
        lwz r0, 0x8(r4) # orig code line
        gecko.end

func patchGenericMoveToPoint(): string =
    let patchInstr = "fmuls f0, f0, f30"
    result = ppc:
        # generic move function patch
        gecko 0x8015bf20, {patchInstr}
        gecko 0x8015bf2c, {patchInstr}
        gecko 0x8015bf38, {patchInstr}

        # mh patches
        gecko 0x80152b78, nop # poke targeting move
        gecko 0x80153378, nop # gun targeting move
        gecko 0x80154548, nop # grab targeting move
        gecko 0x801549e8, nop # player gets out of grab

func patchHarauMovementLoop(): string =
    result = ppc:
        # master hand's harau loop physics
        gecko 0x80151ab0
        bla r12, {SelfInducedPhysics}
        data.table CommonDataTable
        data.end r4
        data.get r4, masterHandData
        lfs f1, xHarauLoopXVel(r4)
        bl HarauMovementPatch
        b OriginalExit_80151ab0
    
        HarauMovementPatch:
            # inputs
            # r3 = fighter data
            # f1 = xVel to add
            lfs f0, {fdSelfVelX.int}(r3)
            fadds f0, f1, f0
            stfs f0, {fdSelfVelX.int}(r3)
            blr

        OriginalExit_80151ab0:
            ""

        # crazy hand's harau loop physics
        gecko 0x80157358
        mr r3, r31
        data.table CommonDataTable
        data.end r4
        data.get r4, crazyHandData
        lfs f1, xHarauLoopXVel(r4)
        bl HarauMovementPatch
        gecko.end

func patchYubideppou1Physics(): string =
    #[ 00 00 01 3E 00 00 00 00 01 00 00 00 80 15 31 60 80 15 32 10 80 15 32 54 80 15 33 C8 80 07 61 C8 
    80153254 - physics cb follow player
    
    ]#
    result = ppc:
        gecko 0x80153254
        mflr r0
        stw r0, 0x4(sp)
        stwu sp, -0x48(sp)
        stw r31, 0x44(sp)
        stw r30, 0x40(sp)
        data.table CommonDataTable
        data.end r30
        lwz r31, 0x2C(r3)
        bla r12, {SelfInducedPhysics}

        lwz r0, 0x2208(r31)
        cmplwi r0, 0
        beq Exit_80153254

        lfs f0, -0x2978(rtoc)
        stfs f0, 0x3C(sp)
        stfs f0, 0x38(sp)
        stfs f0, 0x34(sp)
        
        # get closest player?
#        mr r5, r3
        lwz r5, 0(r31)
        addi r3, r31, 0xB0
        addi r4, sp, 0x34
        lfs f1, 0x2C(r31)
        bla r12, 0x8026B634

        # TODO if no players to target check

        # target's x check
        lfs f1, -0x2978(rtoc)
        lfs f0, 0x34(sp)
        fcmpu cr0, f1, f0
        bne lbl_802b6588
        # target's y check
        lfs f0, 0x38(sp)
        fcmpu cr0, f1, f0
        beq Exit_80153254

        lbl_802b6588:


            # next for target's pos...
            # x
            lfs f2, 0x34(sp)
            addi r3, sp, 0x1C
            lfs f1, 0xB0(r31)
            fsubs f1, f1, f2
            stfs f1, 0x1C(sp)
            # y
            lfs f2, 0x38(sp)
            lfs f1, 0xB4(r31)
            fsubs f1, f1, f2
            stfs f1, 0x20(sp)
            # z
            lfs f0, -0x2978(rtoc)
            stfs f0, 0x24(sp)
            bla r12, 0x8000D3B0

            # get angle?
            lfs f1, 0x20(sp)
            lfs f2, 0x1C(sp)
            bla r12, {Atan2}
            fmr f2, f1

            lfs f0, xRadianOneDegree(r30)
#            fcmpo cr0, f1, f0
#            blt- Exit_80153254

            # f2 = target rotation angle
            lfs f3, xRadianOneDegree(r30)
            lfs f1, 0x2340(r31) # current hand rotation
            lfs f0, -0x57E8(rtoc) # 0
            fsubs f1, f2, f1
            fcmpo cr0, f1, f0
            bge- CurrentBiggerThanTarget
            fneg f0, f1
            b CheckCurrent

            CurrentBiggerThanTarget:
                fmr f0, f1
            
            CheckCurrent:
                fcmpo cr0, f0, f3
                ble- HandCurrentLess

            lfs f0, -0x57E8(rtoc)
            fcmpo cr0, f1, f0
            ble- MoveDown

            fmr f0, f3
            b SetRotation

            MoveDown:
                fneg f0, f3
            
            SetRotation:
                lfs f1, 0x2340(r31)
                fadds f0, f1, f0
                stfs f0, 0x2340(r31)

            b Exit_80153254
            
            HandCurrentLess:
                lfs f1, 0x2340(r31)
                nop
                stfs f1, 0x2340(r31)

        Exit_80153254:
            lfs f1, 0x2340(r31)
            mr r3, r31
            li r4, 0
            bla r12, 0x8007592C # ChangeRotation_Yaw
            lwz r0, 0x4C(sp)
            lwz r31, 0x44(sp)
            lwz r30, 0x40(sp)
            addi sp, sp, 0x48
            mtlr r0
            blr


        # reset state var to 0 on yubideppou
        gecko 0x80153144
        stw r0, 0x2340(r31)
        lwz r0, 0x3C(sp) # orig code line

        # patch yubideppou2 action state start function
        # apply rotation
        gecko 0x80153450
        lfs f1, 0x2340(r31)
        mr r3, r31
        li r4, 0
        bla r12, 0x8007592C # ChangeRotation_Yaw
        lwz r0, 0x24(sp) # orig code line

        # patch yubideppou2 interrupt for rapid fire
        # change rotation again since it gets reset upon rapid fire
        gecko 0x801534f4
        # r29 = fighter gobj
        # r30 = fighter data
        lfs f1, 0x2340(r30)
        mr r3, r30
        li r4, 0
        bla r12, 0x8007592C # ChangeRotation_Yaw
        mr r3, r29 # orig code line

        # patch yubideppou bullet spawn
        # update velocity directions to match rotation
        gecko 0x801536f8
        lfs f1, 0x2340(r31)
        bla r12, 0x80326240 # cos
        stfs f1, 0x60(sp)

        lfs f1, 0x2340(r31)
        bla r12, 0x803263d4 # sin

        fmr f3, f1
        lfs f1, 0x2C(r31) # facing direction
        fmuls f3, f3, f1
        lfs f2, 0x60(sp)
        
        lfs f0, 0xD4(r30) # 5.0 is now our speed multiplier
        fmuls f2, f2, f0
        fmuls f3, f3, f0
        
        mr r3, r28
        mr r7, r29
        addi r4, sp, 40 # orig code line

        # patch yubideppou bullet adjust rotation
        gecko 0x802f0b80
        addi r31, r3, 0 # orig line
        lwz r3, 0x2C(r30)
        lwz r3, 0x2340(r3)
        lwz r4, 0x28(r31)
        stw r3, 0x1C(r4)

        # don't adjust bullet rotation with hardcoded attribute
        gecko 0x802f0ca0, nop # yubideppou bullet
        gecko 0x802f0de4, nop # yubideppou bullet rapid 

        # patch item environment collision for bullet
        # make bullets explode upon stage contact instead of bouncing off
        gecko 0x802f0eec
        bla r12, 0x8026DAA8 # check for stage collision
        "rlwinm." r0, r3, 0, 28, 31
        beq Exit_802f0eec

        li r3, 1
        ba r12, 0x802f0ef4

        Exit_802f0eec:
            ""
        gecko.end



const
    ControllableAllPorts* =
        createCode "MH & CH Controlled by All Ports":
            code:
                # TODO grab doesn't work for MH
                gecko 0x801508b8, lwz r6, 0x65C(r4) # mh
                gecko 0x80156AFC, lwz r0, 0x65C(r6) # ch
    
    NoLerpMovement* =
        createCode "MH/CH No Smooth Movement":
            code: 
                %patchFighterOnLoadMasterHand()
                %patchGenericMoveToPoint()

    HarauCleanMovement* =
        createCode "MH/CH Harau Movement Fix":
            code:
                # TODO this depends on NoLerpMovement...
                %patchHarauMovementLoop()

    GunPointTowards* =
        createCode "MH Point Gun Towards Target":
            code:
                %patchYubideppou1Physics()     

    NoAttackStartup* =
        createCode "MH/CH No Attack Startup":
            code:
                # human-controlled master hand laser
                gecko 0x80150b24
                bla r12, 0x80152BCC
                gecko.end


when isMainModule:
    generate "./generated/handstages.asm", ControllableAllPorts, NoLerpMovement, HarauCleanMovement, NoAttackStartup, GunPointTowards
