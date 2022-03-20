import melee

const
    WeightDependentThrows* =
        createCode "Weight-Dependent Throws":
            description: "Use victim's weight instead of 100 when calculating throw knockback"
            authors: ["sushie"]
            code:
                gecko 0x800ddf00, lfs f4, 0x198(r30)

when isMainModule:
    generate "./generated/wdt.asm", WeightDependentThrows
