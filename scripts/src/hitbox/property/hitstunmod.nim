ctx.addCallbackHook(chkResetVarsPlayerThinkShieldDamage, proc(cb: Callback): string =
    # reset HitstunModifierOffset to 0.0
    ppc: stfs %(cb.regFloatZero), %%(calcOffsetFtData(ctx, HitstunModifierOffset))(%(cb.regFighterData)))
    
result.add ppc do:
    # hitstun mechanics patch
    gecko 0x8008DD70
    # Adds or removes frames of hitstun
    # 8008dd68: loads global hitstun multiplier of 0.4 from plco
    # f30 = calculated hitstun after multipling by 0.4
    # r29 = fighter data
    # f0 = free
    lfs f0, %%(calcOffsetFtData(ctx, HitstunModifierOffset))(r29) # load modifier
    fadds f30, f30, f0 # hitstun + modifier
    fctiwz f0, f30 # original code line
    gecko.end