import ../melee
import dataexpansion

const
    HeaderInfo = MexHeaderInfo
    GetExtHitFunc* = 0x801510d4
    CommonExtHitUtilsScript* =
        createCode "sushie's Common ExtHit Functions":
            description: ""
            authors: ["sushie"]
            code:
            
                gecko {GetExtHitFunc}
                cmpwi r4, 343
                beq- GetExtHit_OrigExit

                # inputs
                # r3 = attacker gobj
                # r4 = attacker hit ft/it hit struct ptr
                # returns
                # r3 = ptr to ExtHit of attacker
                cmplwi r3, 0
                beq GetExtHit_Invalid
                cmplwi r4, 0
                beq GetExtHit_Invalid

                # stack
                # 0x14 - # of extra hitboxes
                # 0x10 - attacker data ptr + Extra Ft/ItHit struct offset
                stwu sp, -0x18(sp)
                # calculate & store # of extra hitboxes to account for
                li r0, {NewHitboxCount - OldHitboxCount}
                stw r0, 0x14(sp)
                # set the initial loop count
                li r0, {OldHitboxCount}
                mtctr r0

                # check attacker type
                lhz r0, 0(r3)
                lwz r3, 0x2C(r3) # fighter data
                cmplwi r0, 4 # fighter type
                beq GetExtHit_Fighter
                cmplwi r0, 6 # item type
                beq GetExtHit_Item
                b GetExtHit_Invalid

                GetExtHit_Item:
                    addi r5, r3, {extItDataOff(HeaderInfo, newHits) - ItHitSize} # attacker data ptr + Extra FtHit struct offset
                    stw r5, 0x10(sp)
                    addi r5, r3, 1492 # attacker data ptr + hit struct offset
                    addi r3, r3, {HeaderInfo.itemDataSize} # attacker data ptr + Exthit struct offset
                    li r0, {ItHitSize}
                b GetExtHit

                GetExtHit_Fighter:
                    addi r5, r3, {extFtDataOff(HeaderInfo, newHits) - FtHitSize} # attacker data ptr + Extra ItHit struct offset
                    stw r5, 0x10(sp)
                    addi r5, r3, 2324 # attacker data ptr + hit struct offset
                    addi r3, r3, {HeaderInfo.fighterDataSize} # attacker data ptr + Exthit struct offset
                    li r0, {FtHitSize}

                GetExtHit:
                    # uses
                    # r3 = points to ExtHit struct offset
                    # r4 = target hit struct ptr
                    # r5 = temp var holding our current hit struct ptr
                    # r0 = sizeof hit struct ptr
                    b GetExtHit_Comparison
                    GetExtHit_Loop:
                        add r5, r5, r0 # point to next hit struct
                        addi r3, r3, {sizeof(SpecialHit)} # point to next ExtHit struct
                        GetExtHit_Comparison:
                            cmplw r5, r4 # hit struct ptr != given hit struct ptr
                            bdnzf eq, GetExtHit_Loop
                # if we found our SpecialHit struct, exit
                beq GetExtHit_Exit
                # otherwise, check to see if we have any new hitboxes to look for
                lwz r5, 0x14(sp) # number of new hitboxes to account for
                cmplwi r5, 0
                beq GetExtHit_Invalid
                mtctr r5 # set loop count
                # reset number of new hitboxes count
                li r5, 0
                stw r5, 0x14(sp)
                # find the ExtHit using new Hit offset
                lwz r5, 0x10(sp)
                b GetExtHit_Loop

                GetExtHit_Invalid:
                    li r3, 0

                GetExtHit_Exit:
                    addi sp, sp, 0x18
                    blr


                GetExtHit_OrigExit:
                    lwz r31, 0x2C(r3)


                gecko.end


when isMainModule:
    generate "./generated/de/exthit.asm", CommonExtHitUtilsScript
