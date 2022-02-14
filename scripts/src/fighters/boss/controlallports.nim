import ../../melee

const
    ControllableAnyPort* =
        createCode "MH/CH Control with Any Port":
            description: "Enables you to control MH/CH with any port instead of being restricted to ports 3 & 4"
            authors: ["sushie", "Achilles1515"]
            code:
                # patch that uses the correct input struct depending on the player for Master Hand
                # Master Hand needs a longer patch to fix the broken grab inputs
                gecko 0x801508b8
                # r3 = HSD_InputStructStart
                # r4 = fighter data
                regs rInputStructStart, rFighterData, (6), rInputStruct 
                lbz rInputStruct, 0xC(rFighterData) # player index
                mulli rInputStruct, rInputStruct, 0x44 # player index * sizeof each input struct
                add rInputStruct, rInputStruct, rInputStructStart # get proper input struct for calculated input struct offset
                lwz r6, 0(rInputStruct) # load the input
                gecko.end

                # patch for enabling control with crazy hand
                gecko 0x80156AFC, lwz r0, 0x65C(r6)

when isMainModule:
    generate "./generated/mhch/controlallports.asm", ControllableAnyPort
