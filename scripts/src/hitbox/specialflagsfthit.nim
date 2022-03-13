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

    CommandParsing = callbackFunc(CustomFtCmdEventCb, (cb) => (ppc do:
                        # TODO support eight hitboxes
                            # skip to next cmd event
                            addi r3, r3, {EventLength}
                            stw r3, 0x8(r29)
                        ))


var codes = @[initMeleeMainCode(SpecialFlagsMainScript)]

codes.add createCustomCmdEvent("Enable Special Flags for Fighter Hitboxes", "esffh", EventCode, EventLength, CommandParsing)

let customEventSpecialFlags*: MeleeMod = 
    initMeleeModRegular("special_flags_fthit", 
    codes,
    dependsOn = [customFtCmdMod])