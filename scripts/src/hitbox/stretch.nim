import ../melee
import ../common/dataexpansion

const
    HitboxStretchModule* =
        createCode "sushie's Hitbox Capsule Support":
                description: ""
                authors: ["sushie"]
                code:
                    gecko 0x801510EC
                    cmpwi r4, 343
                    beq- OrigExit_801510EC

                    OrigExit_801510EC:
                        li r5, 0
                    gecko.end

let hitboxStretchModule*: MeleeMod = initMeleeModModule("hitbox_stretch_module", 
    initMeleeMainCode(HitboxStretchModule), 
    dependsOn = [dataExpansionModule])

