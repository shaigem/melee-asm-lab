import ../melee
import customcmds
import dataexpansion
import strutils

import ../hitbox/[hitboxext, specialflagsfthit, attackcapsule, vectargetpos]

# TODO needs MCM library

func addCmds(cmds: varargs[tuple[cmd: CustomCmd, b: string]]): string =

    # create the table headers like so:
    #[0:
        .4byte 0x3AEA0C00
        .4byte e$0
      1: ...]#
    for i in 0..cmds.len - 1:
        result.add &""" 
{i}:
.4byte {cmds[i].cmd.asHeaderString}
.4byte e${i}
"""
    result.add "customCmdTable.__count = (. - customCmdTable.__start) / 8\n"

    # add the functions and resolve their offsets
    for i in 0..cmds.len - 1:
        let (cmd, b) = cmds[i]
        result.add &"""
CustomCmd_{cmd.name}:
e.solve CustomCmd_{cmd.name} - ((8 * {i}) + _data.table)
{b}
"""

const
    CustomCmdScript* =
        createCode "sushie's Custom Subaction Commands Loader v1.0.0":
            description: ""
            authors: ["sushie"]
            code:
                
                gecko 0x801510e0
                cmpwi r4, 343
                beq OriginalExit_801510E0
                %hitboxext.parseHitboxExt()
                OriginalExit_801510E0:
                    fmr f3, f1

                # Custom Fighter Subaction Event
                gecko 0x80073318

                bl CustomFighterCmdHandler_Start

                # format
                # code, id, event length
                # function ptr
                "_customCmdTable:"
                blrl
                data.table customCmdTable
                errata.new e
                errata.mode e, stack, solve_iter
                "customCmdTable.__start = ."
               
                %addCmds(
                    (SetVecTargetPosCmd, vectargetpos.getParseCmdCode()),
                    (HitboxExtensionAdvancedCmd, ppc do:
                        li r3, 1
                        b HitboxExtCmd_Begin),
                    (HitboxExtensionCmd, ppc do:
                        li r3, 0
                        HitboxExtCmd_Begin:
                            %hitboxext.getParseCmdCode()),
                    (SpecialFlagsCmd, specialflagsfthit.getParseCmdCode()),
                    (AttackCapsuleCmd, attackcapsule.getParseCmdCode()))

                CustomFighterCmdHandler_Start:
                    lwz r12, 0(r3) # orig code line
                    mflr r3
                    addi r3, r3, 0x4
                    bl CustomCmdTable_Find
                    cmplwi r3, 0
                    beq OriginalExit_80073318
                    load r4, 0x8007332c

                CustomCmdTable_Handle:
                    # inputs
                    # r3 = CustomCmd table
                    # r4 = exit address
                    # handle custom cmd event
                    sp.push
                    sp.temp +4, xCustomCmdTable, xExitPtr
                    stw r3, sp.xCustomCmdTable(sp)
                    stw r4, sp.xExitPtr(sp)
                    lwz r0, 0x4(r3) # handler func offset
                    add r0, r3, r0
                    mr r3, r27 # ft/it gobj
                    mr r4, r29 # cmd info
                    mtlr r0
                    blrl

                    # advance script
                    lwz r3, sp.xCustomCmdTable(sp)
                    lbz r0, 0x2(r3) # event len
                    lwz r4, 0x8(r29)
                    add r0, r4, r0
                    stw r0, 0x8(r29)
                    
                    # go to exit
                    lwz r12, sp.xExitPtr(sp)
                    mtctr r12
                    sp.pop
                    bctr

                CustomCmdTable_Find:
                    # inputs
                    # r3 = CustomCmd table
                    # outputs
                    # r3 = CustomCmd table or 0 if not found
                    li r0, "customCmdTable.__count"
                    mtctr r0
                    b CustomCmdTable_Find_Loop_Body
                    
                CustomCmdTable_Find_Loop:
                    addi r3, r3, 0x8
                    CustomCmdTable_Find_Loop_Body:
                        lbz r0, 0x0(r3) # id
                        cmpw r28, r0
                        bdnzf eq, CustomCmdTable_Find_Loop
                        beqlr
                        li r3, 0
                        blr

                OriginalExit_80073318:
                    ""

                # Custom Item Subaction Event
                gecko 0x80279abc
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                lwz r12, 0(r3) # orig code line

                bl "_customCmdTable"
                mflr r3
                bl CustomCmdTable_Find
                cmplwi r3, 0
                beq OriginalExit_80279abc

                load r4, 0x8007332c
                b CustomCmdTable_Handle

                OriginalExit_80279abc:
                    ""
                gecko.end

                # Patch for Subaction_FastForward
                gecko 0x80073430
                # r27 = item/fighter gobj
                # r29 = script struct ptr
                # r30 = item/fighter data
                # r3 = free to use to check

                bl "_customCmdTable"
                mflr r3
                bl CustomCmdTable_Find
                cmplwi r3, 0
                beq SubactionFastForward_OrigExit
                load r4, 0x80073450
                b CustomCmdTable_Handle

                SubactionFastForward_OrigExit:
                    subi r0, r28, 10 # orig code line

                # Patch for FastForwardSubactionPointer2
                gecko 0x80073574
                # r3 must be restored if used
                # r0 is free
                # fixes a crash with Kirby when using inhale with a custom subaction event
                # we only need to skip

                bl "_customCmdTable"
                mflr r3
                bl CustomCmdTable_Find
                cmplwi r3, 0
                beq SubactionFastForwardPtr2_OrigExit

                lwz r4, 0x8(r29) # current action ptr
                lbz r0, 0x2(r3) # event len
                add r4, r4, r0
                stw r4, 0x8(r29)
                ba r12, 0x80073588
              
                SubactionFastForwardPtr2_OrigExit:
                    add r3, r31, r28 # restore r3
                    lwz r4, 0x8(r29) # orig code line, current action ptr

                gecko.end
