import ../melee
import ../common/customcmd


const 
    EventCode = 0x3D
    EventLength = 0x4

const
    SpecialFlagsMainScript* =
        createCode "Enable Special Flags for Fighter Hitboxes":
                        description: "Enables special flags such as rehit, blockability & more from Item hitboxes"
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
                            gecko.end
                                    
    CmdParsing =
        createCode "Enable Special Flags for Fighter Hitboxes: Subaction Event":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:

                        # TODO support eight hitboxes

                        cmpwi r28, {EventCode}
                        "bne+" OriginalExit_sff

                        lwz r3, 0x8({cb.cfcpRegScriptStructPtr}) # load current subaction ptr
                        lbz r4, 0x1(r3)
                        rlwinm r4, r4, 27, 29, 31 # 0xE0 start hitbox id
                        lbz r7, 0x1(r3)
                        rlwinm r7, r7, 30, 29, 31 # 0x1C end hitbox id
                        sub r7, r7, r4 # end - start
                        addi r7, r7, 1

                        cmpwi r7, 0
                        bgt GetHitStruct_sff # loop count > 0, then start the loop

                        li r7, 1

                        GetHitStruct_sff:
                            # get hitbox struct from ID
                            mulli r4, r4, {FtHitSize}
                            addi r4, r4, {FighterData.fdFtHit.int}
                            add r4, r30, r4
                        
                        mtctr r7
                        
                        ReadLoop_sff:
                            # r4 contains FtHit struct
                            # rehit rate
                            lhz r5, 0x40(r4)
                            lbz r6, 0x2(r3) # load rehit rate
                            rlwimi r5, r6, 4, 20, 27
                            sth r5, 0x40(r4)
                            # timed rehit on non-fighter
                            lbz r5, 0x41(r4)
                            lbz r6, 0x3(r3)
                            rlwimi r5, r6, 28, 28, 28 # 0x80
                            stb r5, 0x41(r4)
                            # timed rehit on fighter
                            lbz r5, 0x41(r4)
                            lbz r6, 0x3(r3)
                            rlwimi r5, r6, 28, 29, 29 # 0x40
                            stb r5, 0x41(r4)
                            # timed rehit on shield
                            lbz r5, 0x41(r4)
                            lbz r6, 0x3(r3)
                            rlwimi r5, r6, 28, 30, 30 # 0x20
                            stb r5, 0x41(r4)
                            # blockability
                            lbz r5, 0x42(r4)
                            lbz r6, 0x3(r3)
                            rlwimi r5, r6, 4, 25, 25 # 0x4
                            stb r5, 0x42(r4)
                            # hit facing only
                            lbz r5, 0x42(r4)
                            lbz r6, 0x3(r3)
                            rlwimi r5, r6, 4, 26, 26 # 0x2
                            stb r5, 0x42(r4)
                            addi r4, r4, {FtHitSize} # goto next hit struct ptr
                            bdnz+ ReadLoop_sff
                            # skip to next cmd event
                            addi r3, r3, {EventLength}
                            stw r3, 0x8(r29)
                        ba r12, {CustomFtCmdExitAddr}

                        OriginalExit_sff:
                            ""
                        ))

    FastForward =
        createCode "Enable Special Flags for Fighter Hitboxes: FastForward":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        cmpwi r28, {EventCode}
                        "bne+" OriginalExit_sff_ff
                        lwz r4, 0x8(r29) # current action ptr
                        addi r4, r4, {EventLength}
                        stw r4, 0x8(r29)
                        ba r12, {CustomFtCmdFastForwardExitAddr}
                        OriginalExit_sff_ff:
                            ""
                        ))

    FastForwardSubactionPointer2 =
        createCode "Enable Special Flags for Fighter Hitboxes: FastForward2":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        cmpwi r28, {EventCode}
                        "bne+" OriginalExit_sff_ff2
                        addi r4, r4, {EventLength}
                        stw r4, 0x8(r29)
                        ba r12, {CustomFtCmdFastForward2ExitAddr}
                        OriginalExit_sff_ff2:
                            ""
                        ))

let customEventSpecialFlags*: MeleeMod = 
    initMeleeModRegular("special_flags_fthit",
    initMeleeMainCode(SpecialFlagsMainScript),
    initMeleeInsertCode(customFtCmdMod, 1, CmdParsing), 
    initMeleeInsertCode(customFtCmdMod, 3, FastForward), 
    initMeleeInsertCode(customFtCmdMod, 5, FastForwardSubactionPointer2), 
    dependsOn = [customFtCmdMod])