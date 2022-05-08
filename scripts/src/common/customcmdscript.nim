import ../melee
import customcmds
import dataexpansion

import ../hitbox/[hitboxext, specialflagsfthit]

# TODO needs MCM library

const
    CustomCmdScript* =
        createCode "sushie's Custom Subaction Commands Loader v1.0.0":
            description: ""
            authors: ["sushie"]
            code:

                # Custom Fighter Subaction Event
                gecko 0x80073318
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                lwz r12, 0(r3) # orig code line
                bl JumpCustomCmdEvent
                cmpwi r28, 0
                beq OriginalExit_80073318
                ba r12, 0x8007332c

                JumpCustomCmdEvent:
                    # outputs
                    # r28 = 0 for unhandled, > 0 for handled
                    cmpwi r28, {HitboxExtensionAdvancedCmd.code}
                    beq CustomCmd_HitboxExtensionAdvanced
                    cmpwi r28, {HitboxExtensionCmd.code}
                    beq CustomCmd_HitboxExtension
                    cmpwi r28, {SpecialFlagsCmd.code}
                    beq CustomCmd_SpecialFlags
                    li r28, 0
                    blr

                GetCustomCmdEventLen:
                    # outputs
                    # r0 = event length
                    cmpwi r28, {HitboxExtensionAdvancedCmd.code}
                    li r0, {HitboxExtensionAdvancedCmd.eventLen}
                    beqlr
                    cmpwi r28, {HitboxExtensionCmd.code}
                    li r0, {HitboxExtensionCmd.eventLen}
                    beqlr
                    cmpwi r28, {SpecialFlagsCmd.code}
                    li r0, {SpecialFlagsCmd.eventLen}
                    beqlr
                    li r0, 0
                    blr

                # Custom Cmd Functions
                CustomCmd_HitboxExtensionAdvanced:
                    CustomCmd_HitboxExtension:
                        %hitboxext.getParseCmdCode()

                CustomCmd_SpecialFlags:
                    %specialflagsfthit.getParseCmdCode()

                OriginalExit_80073318:
                    ""

                # Custom Item Subaction Event
                gecko 0x80279abc
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                lwz r12, 0(r3) # orig code line

                bl JumpCustomCmdEvent
                cmpwi r28, 0
                beq OriginalExit_80279abc
                ba r12, 0x80279a50

                OriginalExit_80279abc:
                    ""
                gecko.end

                # Patch for Subaction_FastForward
                gecko 0x80073430
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                # r3 = free to use to check

                subi r0, r28, 10 # orig code line

                bl JumpCustomCmdEvent
                cmpwi r28, 0
                beq SubactionFastForward_OrigExit
                ba r12, 0x8007332c

                SubactionFastForward_OrigExit:
                    ""

                # Patch for FastForwardSubactionPointer2
                gecko 0x80073574
                # r3 must be restored if used
                # r0 is free
                # fixes a crash with Kirby when using inhale with a custom subaction event
                # we only need to skip
                lwz r4, 0x8(r29) # orig code line, current action ptr

                bl GetCustomCmdEventLen
                cmpwi r0, 0
                beq SubactionFastForwardPtr2_OrigExit
                
                add r4, r4, r0
                stw r4, 0x8(r29)
                ba r12, 0x80073588
              
                SubactionFastForwardPtr2_OrigExit:
                    ""
                gecko.end
