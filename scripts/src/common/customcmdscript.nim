import ../melee
import customcmds

import ../hitbox/[hitboxext, specialflagsfthit]

# TODO needs MCM library

proc getCmdSwitchString(jmpLabel: string; useEventLen: bool = false): string =

    proc genCmpFor(customCmd: CustomCmd): string =
        ppc:
            cmpwi r28, {customCmd.code}
            block:
                if useEventLen:
                    "li r0, " & $customCmd.eventLen
                else:
                    "li r3, " & $customCmd.id
            %("beq- " & jmpLabel)

    ppc:
        %genCmpFor(HitboxExtensionCmd)
        %genCmpFor(SpecialFlagsCmd)

const 

    CustomFighterCmdJumpLbl = "CustomFighterCmd_Jump"
    CustomItemCmdJumpLbl = "CustomItemCmd_Jump"
    CustomFighterCmdFastForwardJumpLbl = "CustomFighterCmd_FastForward_Jump"
    CustomSubactionFastForwardPtr2 = "SubactionFastForwardPtr2_Skip"

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
                %getCmdSwitchString(CustomFighterCmdJumpLbl)
                b OriginalExit_80073318

                # Custom Cmd Functions
                CustomCmd_HitboxExtension:
                    "hitboxextcmd.__start = ."
                    prolog
                    %hitboxext.getParseCmdCode()
                    epilog
                    blr

                CustomCmd_SpecialFlags:
                    "specialflagscmd.__start = ."
                    %specialflagsfthit.getParseCmdCode()
                    blr

                # Init Functions for Jumping to Custom Cmd Functions
                %(CustomItemCmdJumpLbl & ":")
                bl CustomCmd_DetermineJump
                ba r12, 0x80279ad0

                %(CustomFighterCmdJumpLbl & ":")
                bl CustomCmd_DetermineJump
                ba r12, 0x8007332c

                %(CustomFighterCmdFastForwardJumpLbl & ":")
                bl CustomCmd_DetermineJump
                ba r12, 0x80073450

                # Jumps to custom cmd function based on given id/index
                CustomCmd_DetermineJump:
                    # inputs
                    # r3 = index of custom cmd
                    prolog
                    bl CustomCmd_JumpTable
                    mflr r4
                    slwi r0, r3, 2
                    lwzx r0, r4, r0
                    sub r0, r4, r0 # custom cmd addr = (address to jmptbl - custom cmd label offset)
                    # now branch to custom function
                    mtctr r0
                    bctrl
                    # end
                    epilog
                    blr

                CustomCmd_JumpTable:
                    blrl
                    "customcmdjmp.__start = ."
                    ".4byte customcmdjmp.__start - hitboxextcmd.__start"
                    ".4byte customcmdjmp.__start - specialflagscmd.__start"
                
                OriginalExit_80073318:
                    ""

                # Custom Item Subaction Event
                gecko 0x80279abc
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                lwz r12, 0(r3) # orig code line

                %getCmdSwitchString(CustomItemCmdJumpLbl)

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
                %getCmdSwitchString(CustomFighterCmdFastForwardJumpLbl)

                SubactionFastForward_OrigExit:
                    ""

                # Patch for FastForwardSubactionPointer2
                gecko 0x80073574
                # r3 must be restored if used
                # r0 is free
                # fixes a crash with Kirby when using inhale with a custom subaction event
                # we only need to skip
                lwz r4, 0x8(r29) # orig code line, current action ptr

                %getCmdSwitchString(CustomSubactionFastForwardPtr2, useEventLen = true)
                b SubactionFastForwardPtr2_OrigExit

                %(CustomSubactionFastForwardPtr2 & ":")
                add r4, r4, r0
                stw r4, 0x8(r29)
                ba r12, 0x80073588

                SubactionFastForwardPtr2_OrigExit:
                    ""
                gecko.end
