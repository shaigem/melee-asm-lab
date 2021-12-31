import ../../../melee

func patchMoveWithControlStick(): string =
    result = ppc:
        # MH Wait1 physics patch for movement with control stick
        gecko 0x80150870
        ba r12, 0x800ca53c
        MasterHandWait1Physics:
            prolog rFighterGObj

            epilog
            blr
        gecko.end

const FreeMovement* =
        createCode "MH/CH Free Movement":
            code:
                %patchMoveWithControlStick()


# 800ca53c physics dash start
# 0x80084db0