import ../melee

const
    CustomFtCmdExitAddr* = 0x8007332c
    CustomFtCmdFastForwardExitAddr* = 0x80073450
    CustomFtCmdFastForward2ExitAddr* = 0x80073588

    CustomFtCmdScript* =
        createCode "sushie's Custom Fighter Subaction Commands Module":
                description: ""
                authors: ["sushie"]
                code:
                    # Custom Fighter Subaction Event
                    gecko 0x80073318
                    # r27 = fighter gobj
                    # r29 = script struct ptr
                    # r30 = fighter data
                    # INSERT
                    OriginalExit_80073318:
                        lwz r12, 0(r3)

                    # Patch for Subaction_FastForward
                    gecko 0x80073430
                    subi r0, r28, 10 # orig code line
                    # INSERT
                    OriginalExit_80073430:
                        ""
                    # Patch for FastForwardSubactionPointer2
                    gecko 0x80073574
                    # fixes a crash with Kirby when using inhale with a custom subaction event
                    lwz r4, 0x8(r29) # orig code line, current action ptr
                    # INSERT

                    gecko.end
    CustomFtCmdEventCb* = Callback(kind: cbkCustomFtCmdParse, cfcpRegData: r30, cfcpRegScriptStructPtr: r29)

let customFtCmdMod*: MeleeMod = initMeleeModModule("custom_ft_cmd_module", initMeleeMainCode(CustomFtCmdScript))