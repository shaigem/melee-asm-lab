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

                    # Patch for FastForwardSubactionPointer2
                    gecko 0x80073574
                    # fixes a crash with Kirby when using inhale with a custom subaction event
                    lwz r4, 0x8(r29) # orig code line, current action ptr
                    # INSERT

                    gecko.end
    CustomFtCmdEventCb* = Callback(kind: cbkCustomFtCmdParse, cfcpRegData: r30, cfcpRegScriptStructPtr: r29)

let customFtCmdMod*: MeleeMod = initMeleeModModule("custom_ft_cmd_module", initMeleeMainCode(CustomFtCmdScript))

proc createCustomCmdEvent*(name: string; key: string; eventCode: int; eventLength: int; parsingCode: string): seq[MeleeCode] =
    let 
        fastForwardBranchName = "OrigExit_ccff_" & key
        fastForward = createCode name & ": FastForward":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        cmpwi r28, {eventCode}
                        %("bne+ " & fastForwardBranchName)
                        lwz r4, 0x8(r29) # current action ptr
                        addi r4, r4, {eventLength}
                        stw r4, 0x8(r29)
                        ba r12, {CustomFtCmdFastForwardExitAddr}
                        %(fastForwardBranchName & ":")
                        ""
                        ))
        fastForward2BranchName = "OrigExit_ccff2_" & key
        fastForward2 = createCode name & ": FastForward2":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        cmpwi r28, {eventCode}
                        %("bne+ " & fastForward2BranchName)
                        addi r4, r4, {eventLength}
                        stw r4, 0x8(r29)
                        ba r12, {CustomFtCmdFastForward2ExitAddr}
                        %(fastForward2BranchName & ":")
                        ""
                        ))
        parsingBranchName = "OrigExit_ccp_" & key
        parsing = createCode name & ": Subaction Event Parsing":
                description: ""
                authors: ["sushie"]
                code:
                    %callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        cmpwi r28, {eventCode}
                        %("bne+ " & parsingBranchName)
                        %parsingCode
                        ba r12, {CustomFtCmdExitAddr}
                        %(parsingBranchName & ":")
                        ""
                        ))
    result = @[initMeleeInsertCode(customFtCmdMod, 0, parsing),
    initMeleeInsertCode(customFtCmdMod, 3, fastForward),
    initMeleeInsertCode(customFtCmdMod, 5, fastForward2)]

