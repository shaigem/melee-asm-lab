import ../../../melee
import ../controlallports


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
    # 0xBC = Paatsubusu move to x start up
    # 0xC0 = Paatsubusu move to y start up
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
                ".float" 3.0
            2:
                ".float" 2.0
            3:
                ".float" 0.0174533
            4:
                ".float" 93
            5:
                ".float" 42.0
        data.struct 0, "", xMainMoveSpeed, 
            xSecondaryMoveSpeed,
            xFreeMovementSpeed,
            xRadianOneDegree,
            xPaatsubusuStartFrame,
            xPaatsubusuStartY

        data.table masterHandData
        0: ".float" -1.6
        1: ".float" 3.25
        2: ".float" 45.0
        3: ".float" 45.0
        data.struct 0, "mh.", xHarauLoopXVel, 
            xYubideppou2AnimRate,
            xStartOffsetX,
            xStartOffsetY

        data.table crazyHandData
        0: ".float" 1.4
        1: ".float" -45.0
        2: ".float" -45.0
        data.struct 0, "ch.", xHarauLoopXVel,
            xStartOffsetX,
            xStartOffsetY
        data.end r3

        lfs f0, xSecondaryMoveSpeed(r3)
        stfs f0, 0x28(r31)

        lfs f0, xMainMoveSpeed(r3)
        stfs f0, 0x2C(r31)

        lfs f0, xPaatsubusuStartY(r3)
        stfs f0, 0xC0(r31)

        # start mh specific attribute patches
        data.get r3, masterHandData
        lfs f0, mh.xStartOffsetX(r3)
        stfs f0, 0x30(r31)

        lfs f0, mh.xStartOffsetY(r3)
        stfs f0, 0x34(r31)

        lfs f0, mh.xYubideppou2AnimRate(r3)
        stfs f0, 0xF4(r31)

        lwz r0, 0x8(r4) # orig code line

        gecko 0x80155e68 # patch fighter on load for crazy hand
        data.table CommonDataTable
        data.end r3

        lfs f0, xSecondaryMoveSpeed(r3)
        stfs f0, 0x10(r31)

        lfs f0, xMainMoveSpeed(r3)
        stfs f0, 0x14(r31)

        # ch specific attribute patches
        data.get r3, crazyHandData
        # TODO need to redo how custom data works...    
        # lfs f0, ch.xStartOffsetX(r3)
        # stfs f0, 0x18(r31)

        # lfs f0, ch.xStartOffsetY(r3)
        # stfs f0, 0x1C(r31)

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
        # poke targeting move
        gecko 0x80152b78, nop
        gecko 0x80152b48, lfs f0, 0x28(r30) # was 0x2C, use the secondary move speed

        # gun targeting move
        gecko 0x80153378, nop

        # grab targeting move
        gecko 0x80154548, nop
        gecko 0x80154518, lfs f0, 0x28(r30) # was 0x2C, use the secondary move speed
        gecko 0x801549e8, nop # player gets out of grab, disable moving back to starting point

        gecko 0x80152334, nop # used to set the x velocity of hand to 0 in drill physics

        # ch patches
        # poke targeting move
        gecko 0x801580f0, nop
        gecko 0x801580c0, lfs f0, 0x10(r30) # was 0x14, use the secondary move speed

        # grab targeting move
        gecko 0x80158da4, nop
        gecko 0x80158d74, lfs f0, 0x10(r30) # was 0x14, use the secondary move speed
        gecko 0x80159244, nop # player gets out of grab, disable moving back to starting point

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
    result = ppc:
        # yubideppou1 physics patch
        gecko 0x80153348
        lwz r3, 0(r31)
        lfs f1, 0x28(r30)
        bl RotTowardsTarget
        b OriginalExit_801533ac

        # function for rotating fighter towards target
        RotTowardsTarget:
            # TODO to make this function reuseable, rewrite it to not use 0x2340 state_var
            # uses 0x2340 of fighter data to store current rotation
            # inputs
            # r3 = source gobj
            # f1 = rotate speed multiplier
            prolog rSrcData, fRotSpeedMulti, xVec3, (0xC)
            lwz rSrcData, 0x2C(r3)
            fmr fRotSpeedMulti, f1
            regs (4), rTempVec
            addi rTempVec, sp, sp.xVec3
            # init temp vector to (0, 0, 0)
            lfs f0, -0x2978(rtoc)
            stfs f0, 0(rTempVec)
            stfs f0, 4(rTempVec)
            stfs f0, 8(rTempVec)
            # call the get closest player function
            lwz r5, 0x10C(rSrcData)
            bla r12, 0x8015c208
            # TODO check if no valid players...
            # targeted player's topn coordinates are stored in the stack (r4)

            # get the vector diff of target's pos & src pos
            lfs f4, 0(rTempVec) # target's x
            lfs f3, 0xB0(rSrcData) # src x pos
            fsubs f2, f3, f4 # diff x
            lfs f4, 4(rTempVec) # target's y
            lfs f3, 0xB4(rSrcData) # src y pos
            fsubs f1, f3, f4 # diff y
            # calculate desired angle
            bla r12, {Atan2}
            # f1 = desired angle
            data.table CommonDataTable
            data.end r3
            lfs f3, xRadianOneDegree(r3)
            fmuls f3, f3, fRotSpeedMulti
            lfs f2, 0x2340(r31) # current hand rotation
            lfs f4, -0x57E8(rtoc) # 0
            fsubs f1, f1, f2 # desired dir - current dir
            fcmpu cr0, f1, f4
            bge- CurrentBiggerThanTarget_RotTowardsTarget
            fneg f0, f1
            b CheckCurrent_RotTowardsTarget

            CurrentBiggerThanTarget_RotTowardsTarget:
                fmr f0, f1
            
            CheckCurrent_RotTowardsTarget:
                fcmpo cr0, f0, f3
                ble- ClampRot_RotTowardsTarget

            fcmpu cr0, f1, f4
            ble- MoveDown_RotTowardsTarget

            fmr f0, f3
            b AddToRot_RotTowardsTarget

            MoveDown_RotTowardsTarget:
                fneg f0, f3
            
            AddToRot_RotTowardsTarget:
                fadds f0, f2, f0
                stfs f0, 0x2340(rSrcData)    
                b Rotate_RotTowardsTarget

            ClampRot_RotTowardsTarget:
                fadds f1, f2, f1
                stfs f1, 0x2340(rSrcData)

            Rotate_RotTowardsTarget:
                lfs f1, 0x2340(rSrcData)
                mr r3, rSrcData
                li r4, 0
                bla r12, {FighterSetBoneRotX}

            Epilog_RotTowardsTarget:
                epilog
                blr

        OriginalExit_801533ac:
            lfs f0, 0x28(r30) # was 0x2C

        # reset rotation state var to 0 on yubideppou1 change action state
        gecko 0x80153144
        # r0 = 0
        stw r0, 0x2340(r31)
        lwz r0, 0x3C(sp) # orig code line

        # patch yubideppou2 action state start function
        # apply rotation
        gecko 0x80153450
        # r31 = fighter data
        lfs f1, 0x2340(r31)
        mr r3, r31
        li r4, 0
        bla r12, {FighterSetBoneRotX}
        lwz r0, 0x24(sp) # orig code line

        # patch yubideppou2 interrupt for rapid fire
        # change rotation again since it gets reset when changing action state to yubideppou2 for rapid fire
        gecko 0x801534f4
        # r29 = fighter gobj
        # r30 = fighter data
        lfs f1, 0x2340(r30)
        mr r3, r30
        li r4, 0
        bla r12, {FighterSetBoneRotX}
        mr r3, r29 # orig code line

        # patch yubideppou bullet spawn
        # update velocity directions to match rotation
        gecko 0x801536f8
        # f1 needs to be facing direction of fighter data
        # f2 needs to be x velocity of bullet
        # f3 needs to be y velocity of bullet
        regs (1), fCurrentRot, fXVel, fYVel

        # calculate y velocity of bullet based on current fighter rotation
        lfs fCurrentRot, 0x2340(r31)
        bla r12, {Sin}
        fmr f31, f1 # save y vel for later use

        # calculate x velocity of bullet based on current fighter rotation
        lfs fCurrentRot, 0x2340(r31)
        bla r12, {Cos} # cos
        fmr fXVel, f1

        # load facing direction and fix y bullet direction
        fmr fYVel, f31 # restore y vel
        lfs f1, 0x2C(r31) # facing direction
        fmuls fYVel, fYVel, f1 # fix y bullet velocity direction
        
        # apply speed multiplier
        lfs f0, 0xD4(r30) # 5.0 is now our speed multiplier
        fmuls fXVel, fXVel, f0
        fmuls fYVel, fYVel, f0
        
        mr r3, r28
        mr r7, r29
        addi r4, sp, 40 # orig code line

        # patch yubideppou bullet adjust rotation
        gecko 0x802f0b80
        addi r31, r3, 0 # orig line
        lwz r3, 0x2C(r30) # fighter data
        lwz r3, 0x2340(r3) # get our current direction/rotation var
        lwz r4, 0x28(r31) # get jobj of bullet
        stw r3, 0x1C(r4) # set bone rot x

        # don't adjust bullet rotation with hardcoded attribute
        gecko 0x802f0ca0, nop # yubideppou bullet
        gecko 0x802f0de4, nop # yubideppou bullet rapid 

#[         # patch item environment collision for bullet
        # make bullets explode upon stage contact instead of bouncing off
        gecko 0x802f0eec
        bla r12, 0x8026DAA8 # check for stage collision
        "rlwinm." r0, r3, 0, 28, 31
        beq Exit_802f0eec

        li r3, 1
        ba r12, 0x802f0ef4

        Exit_802f0eec:
            "" ]#
        gecko.end

func patchPaatsubusu*(): string =
    # TODO customizable move speeds for gootsubusuwait? what if paatsubusu targets faster or slower?
    const 
        MasterHandGootsubusuup = 0x80152370
        CrazyHandGootsubusuup = 0x801578E8
    const
        MhPaatsubusuActionStateId = 358
        ChPaatsubusuActionStateId = 354
        MhGootsubusudownActionStateId = 357
        ChGootsubusudownActionStateId = 353
        StateVarActionStateId = 0x2394
        StateVarStartFrame = 0x2390
    result = ppc:
        # master hand research
        #[mh research for gootsubusuup
        
        355/309 = gootsubusuup
        801509D0 = player inputs this move
        80150608 = cpu inputs this move
        function 0x80152370
        01 35 00 00 00 00 01 00 00 00 80 15 23 BC 80 15 24 14 80 15 24 58 80 15 24 78 80 07 61 C8
        interrupt cb = 801523BC
        - on frame end, instr at 801523f0 calls function 8015247C which is gootsubusuwait

        356/310 = gootsubusuwait
        interrput cb = 801524C8
        - after var 0x2348 reaches 0, call func_801525E0 (gootsubusudown)

        paatsubusu
        358/312 = paatsubusu
        801526D8 = start function

        crazy hand research
        354/308 = paatsubusu
        CrazyHandGootsubusuup = 0x801578E8

        ]#
        
        # patch mh gootsubusuup function to use custom state_vars to store gootsubusudown
        gecko 0x801523a8 # for mh
        # purpose of this patch is to always reset the state var to the default gootsubusudown action state
        # r31 = fighter gobj
        lwz r3, 0x2C(r31)
        li r0, {MhGootsubusudownActionStateId}
        stw r0, {StateVarActionStateId}(r3)
        li r0, 0
        stw r0, {StateVarStartFrame}(r3)
        lwz r0, 0x1C(sp) # orig code line

        # patch ch gootsubusuup function to use custom state_vars to store gootsubusudown
        gecko 0x80157920 # for ch
        lwz r3, 0x2C(r31)
        li r0, {ChGootsubusudownActionStateId}
        stw r0, {StateVarActionStateId}(r3)
        li r0, 0
        stw r0, {StateVarStartFrame}(r3)
        lwz r0, 0x1C(sp) # orig code line

        # patch paatsubusu action state functions to use gootsubusuup
        gecko 0x80152708 # for mh
        # r3 = fighter gobj
        # r31 = fighter data
        # r30 = fighter gobj
        bla r12, {MasterHandGootsubusuup}
        li r3, {MhPaatsubusuActionStateId}
        stw r3, {StateVarActionStateId}(r31)
        data.table CommonDataTable
        data.end r3
        lfs f0, xPaatsubusuStartFrame(r3)
        stfs f0, {StateVarStartFrame}(r31)
        ba r12, 0x80152718 # epilog of function

        gecko 0x80157c80 # for ch
        # r3 = fighter gobj
        # r31 = fighter data
        # r30 = fighter gobj
        bla r12, {CrazyHandGootsubusuup}
        li r3, {ChPaatsubusuActionStateId}
        stw r3, {StateVarActionStateId}(r31)
        data.table CommonDataTable
        data.end r3
        lfs f0, xPaatsubusuStartFrame(r3)
        stfs f0, {StateVarStartFrame}(r31)
        ba r12, 0x80157c90 # epilog of function

        # patch mh gootsubusudown to use paatsubusu
        gecko 0x8015260c
        # r5 = fighter data
        lwz r4, {StateVarActionStateId}(r5)
        lfs f1, {StateVarStartFrame}(r5)
        li r5, 0 # original code line

        # patch ch gootsubusudown to use paatsubusu
        gecko 0x80157b84
        lwz r4, {StateVarActionStateId}(r5)
        lfs f1, {StateVarStartFrame}(r5)
        li r5, 0 # original code line

        # patch to make paatsubusu unable to move while slapped down
        gecko 0x801527f4, fmr f1, f0 # mh set frames elasped to 1
        gecko 0x80157d6c, fmr f1, f0 # ch set frames elasped to 1
        gecko.end

func patchCrazyHandLaserSpawn(): string =
    let codeLine = "li r7, 0x7F"
    result = ppc:
        gecko 0x80158584, {codeLine}
        gecko 0x801585B8, {codeLine}
        gecko 0x801585EC, {codeLine}
        gecko 0x80158620, {codeLine}
#    for i in 0..3:
#        result &= "gecko " & $(baseAddr + (i * 52)) & ", " & codeLine & "\n"

const
    NoLerpMovement* =
        createCode "MH/CH No Lerp Movement":
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

    PaatsubusuFix* =
        createCode "MH/CH Paatsubusu Uses Gootsubusu Action States":
            code:
                %patchPaatsubusu()

    NoAttackStartup* =
        createCode "MH/CH No Attack Startup":
            code:
                # human-controlled master hand laser
                gecko 0x80150b24
                bla r12, 0x80152BCC
                gecko.end

    CHUseOwnLasers* =
        createCode "CH Uses His Own Lasers":
            code:
                %patchCrazyHandLaserSpawn()


when isMainModule:
    generate "./generated/mhch/handstages.asm", ControllableAnyPort, NoLerpMovement, HarauCleanMovement, NoAttackStartup, GunPointTowards, PaatsubusuFix, CHUseOwnLasers
