import ../melee
import ../common/customcmds

const
    SpecialFlagsFtHitScript* =
        createCode "Enable Special Flags for Fighter Hitboxes v2.0.0":
            description: "Lets you use special flags that are normally found in item hitboxes"
            authors: ["sushie"]
            code:
                
                # Enable bit 0x20 - Hit Facing flag of ItHit to be usable for Fighter Hitboxes
                gecko 0x80078ea0
                lbz r0, 0x42(r23)
                "rlwinm." r0, r0, 27, 31, 31 # 0x20
                beq OriginalExit_80078ea0 # if hit facing != true, exit
                # or else, check directions
                lfs f1, 0x2C(r28) # defender facing direction
                lfs f0, 0x2C(r24) # source facing direction
                fcmpu cr0, f1, f0
                beq CanHit_80078ea0
                b OriginalExit_80078ea0
                CanHit_80078ea0:
                    ba r12, 0x80079228
                OriginalExit_80078ea0:
                    lbz r0, 0x134(r23)                
                    
                # Enable bit 0x40 - Blockability (Can Shield) flag of ItHit to be usable for Fighter Hitboxes
                gecko 0x80078fe8
                # can hit fighters through shield if 0x40 is set to 0
                lbz r0, 0x42(r23)
                "rlwinm." r0, r0, 26, 31, 31 # 0x40
                bne Exit_80078fe8 # can shield == true
                SkipShield: # else, skip shield check
                    ba r12, 0x800790B4
                Exit_80078fe8:
                    "rlwinm." r0, r3, 28, 31, 31 # original code line

                # Reset Hit Players for Fighter Hitboxes
                gecko 0x8006ab2c
                mr r3, r30 # r30 is gobj
                # inputs
                # r3 = fighter gobj
                prolog rHitStruct, rLoopCount
                li rLoopCount, 0
                mulli r0, rLoopCount, {FtHitSize}
                lwz r3, 0x2C(r3) # fighter data
                add rHitStruct, r3, r0
                Loop_8006c9cc:
                    addi r3, rHitStruct, {FighterData.fdFtHit.int}
                    bla r12, 0x80008a5c # goto reset hit players
                    addi rLoopCount, rLoopCount, 1
                    cmplwi rLoopCount, 4
                    addi rHitStruct, rHitStruct, {FtHitSize}
                blt+ Loop_8006c9cc
                epilog
            
                # restore r3
                mr r3, r30

                # Enable Rehit Rate on Fighter Hitboxes Vs Players
                gecko 0x80077230
                # r27 = hit struct
                lbz r4, 0x41(r27)
                "rlwinm." r4, r4, 30, 31, 31 # 0x4
                li r4, 0 # orig code line
                beq Exit_80077230 # no timed rehit on fighters
                li r4, 5 
                Exit_80077230:
                    ""

                # Enable Rehit Rate on Fighter Hitboxes Vs Shields
                gecko 0x80076d04
                # r30 = hit struct
                lbz r4, 0x41(r30)
                "rlwinm." r4, r4, 31, 31, 31 # 0x2
                li r4, 1 # orig code line
                beq Exit_80076d04 # no timed rehit on shields
                li r4, 2
                Exit_80076d04:
                    ""
                # Enable Rehit Rate on Fighter Hitboxes Vs Non-Fighters
                gecko 0x8027058C
                # r26 = hit struct
                lbz r5, 0x41(r26)
                "rlwinm." r5, r5, 29, 31, 31 # 0x8
                li r5, 0 # orig code line
                beq Exit_8027058C # no timed rehit on non-fighters
                li r5, 8
                Exit_8027058C:
                    ""
                gecko.end

proc getParseCmdCode*(): string =
    ppc:
        lwz r3, 0x8(r29) # load current subaction ptr
        lbz r4, 0x1(r3)
        li r7, {HitboxCount}

        "rlwinm." r0, r4, 0, 27, 27 # 0x10, apply to all active hitboxes
        rlwinm r4, r4, 27, 29, 31 # 0xE0 start hitbox id
        beq SpecialFlagsCmd_GetHitStruct # no looping

        # start at hitbox id 0
        li r4, 0
        li r7, 0 # current hitbox id loop counter

        SpecialFlagsCmd_GetHitStruct:
            # get hitbox struct from ID
            mulli r4, r4, {FtHitSize}
            addi r4, r4, {FighterData.fdFtHit.int}
            add r4, r30, r4

        regs (3), rCmdEvtPtr, rHitStruct

        SpecialFlagsCmd_ReadLoop:
            # r4 contains FtHit struct
            lwz r0, 0(r4) # active
            cmpwi r0, 0
            beq SpecialFlagsCmd_ReadLoop_Next
            # rehit rate
            lhz r5, 0x40(rHitStruct)
            lbz r6, 0x2(rCmdEvtPtr) # load rehit rate
            rlwimi r5, r6, 4, 20, 27
            sth r5, 0x40(rHitStruct)
            # timed rehit on non-fighter
            lbz r5, 0x41(rHitStruct)
            lbz r6, 0x3(rCmdEvtPtr)
            rlwimi r5, r6, 28, 28, 28 # 0x80
            stb r5, 0x41(rHitStruct)
            # timed rehit on fighter
            lbz r5, 0x41(rHitStruct)
            lbz r6, 0x3(rCmdEvtPtr)
            rlwimi r5, r6, 28, 29, 29 # 0x40
            stb r5, 0x41(rHitStruct)
            # timed rehit on shield
            lbz r5, 0x41(rHitStruct)
            lbz r6, 0x3(rCmdEvtPtr)
            rlwimi r5, r6, 28, 30, 30 # 0x20
            stb r5, 0x41(rHitStruct)
            # blockability
            lbz r5, 0x42(rHitStruct)
            lbz r6, 0x3(rCmdEvtPtr)
            rlwimi r5, r6, 4, 25, 25 # 0x4
            stb r5, 0x42(rHitStruct)
            # hit facing only
            lbz r5, 0x42(rHitStruct)
            lbz r6, 0x3(rCmdEvtPtr)
            rlwimi r5, r6, 4, 26, 26 # 0x2
            stb r5, 0x42(rHitStruct)
            SpecialFlagsCmd_ReadLoop_Next:
                addi r7, r7, 1
                cmplwi r7, {HitboxCount}
                addi r4, r4, {FtHitSize}
                blt SpecialFlagsCmd_ReadLoop

        blr