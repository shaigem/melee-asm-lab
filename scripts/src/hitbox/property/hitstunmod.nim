ctx.addCallbackHook(chkResetVarsPlayerThinkShieldDamage, proc(cb: Callback): string =
    # reset HitstunModifierOffset to 0.0
    ppc: stfs %(cb.regFloatZero), %%(calcOffsetFtData(ctx, HitstunModifierOffset))(%(cb.regData)))

ctx.addCallbackHook(chkSetDefenderFighterVarsOnHit, proc(cb: Callback): string =
    # set the defender's hitstun modifier variable on hit
    ppc:
        lfs f0, %%ExtHitHitstunModifierOffset(%(cb.regExtHitOff)) # load the hitstun modifier of the ExtHit
        stfs f0, %%calcOffsetFtData(ctx, HitstunModifierOffset)(%(cb.regDefData))) # set the defender's hitstun modifier to the one from ExtHit

result.addPatches ppc do:
    # hitstun mechanics patch
    gecko 0x8008DD70
    # Adds or removes frames of hitstun
    # 8008dd68: loads global hitstun multiplier of 0.4 from plco
    # f30 = calculated hitstun after multipling by 0.4
    # r29 = fighter data
    # f0 = free
    lfs f0, %%calcOffsetFtData(ctx, HitstunModifierOffset)(r29) # load modifier
    fadds f30, f30, f0 # hitstun + modifier
    fctiwz f0, f30 # original code line
    gecko.end