import ../../melee

const
    VibrateOnHit* =
        createCode "MH/CH Vibrate on Hit":
            description: "Hands will vibrate on hit"
            authors: ["sushie"]
            code:
                # patch on_damage function for MH/CH
                gecko 0x8008eb24
                # r30 = fighter data
                # damage addhitlag
                # r3 = fighter data
                # r4 = hit element
                # r5 = damage
                # r6 = move id
                # r7 = 0 ? air state?? if 0, vibrate side to side, if 1, up and down
                # f1 = hitlag multiplier
                mr r3, r30
                lwz r4, 0x1860(r30)
                lwz r5, 0x183C(r30)
                lwz r6, 0x10(r30)
                # lwz r7, 0xE0(r30)
                li r7, 0 # vibrate side to side
                lfs f1, 0x1960(r30)
                bla r12, 0x80090594 # call Damage_AddHitlag? func
                cmpwi r31, 0 # original code line
                gecko.end

when isMainModule:
    generate "./generated/vibrateonhit.asm", VibrateOnHit
