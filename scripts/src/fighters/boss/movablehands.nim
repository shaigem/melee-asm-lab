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
        data.struct 0, "", xMainMoveSpeed, 
            xSecondaryMoveSpeed,
            xStartOffsetX,
            xStartOffsetY,
            xFreeMovementSpeed

        data.table masterHandData
        0: ".float" -1.6
        data.struct 0, "", xHarauLoopXVel

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

    NoAttackStartup* =
        createCode "MH/CH No Attack Startup":
            code:
                # human-controlled master hand laser
                gecko 0x80150b24
                bla 0x80152BCC
                gecko.end


when isMainModule:
    generate "./generated/handstages.asm", ControllableAllPorts, NoLerpMovement, HarauCleanMovement, NoAttackStartup
