ctx.addCallbackHook(chkResetVarsItems, proc(cb: Callback): string =
    # reset custom hitlag multiplier for items to 1.0
    ppc: stfs %(cb.regFloatOne), %%(calcOffsetItData(ctx, ExtItHitlagMultiplierOffset))(%(cb.regData)))

ctx.addCallbackHook(chkSetDefsAtksVarsOnHit, proc(cb: Callback): string =
    ppc:
        lfs f0, %%ExtHitHitlagOffset(%(cb.regExtHitOff)) # load hitlag multiplier
        # calculate hitlag multiplier offsets depending if it's a item or fighter
        # for src
        mr r3, %(cb.regSrcType)
        bl CalculateHitlagMultiOffset_HitlagMulti
        add r4, %(cb.regSrcData), r3

        # for def
        mr r3, %(cb.regDefGObj)
        bl IsItemOrFighter
        mr %(cb.regDefType), r3 # backup def type
        bl CalculateHitlagMultiOffset_HitlagMulti
        add r5, %(cb.regDefData), r3
        
        # check if hit was electric
        lwz r0, 0x30(%(cb.regHitOff)) # dmg hit attribute
        cmplwi r0, 2 # electric
        bne+ NotElectric_HitlagMulti
        # Electric
        lwz r3, -0x514C(r13) # PlCo values
        lfs f1, 0x1A4(r3) # 1.5 electric hitlag multiplier
        fmuls f1, f1, f0 # 1.5 * multiplier
        # store extra hitlag for DEFENDER ONLY in Melee
        # TODO idk if i should check if src & defender data is valid before setting...
        stfs f1, 0(r5) # store extra hitlag for defender
        b UpdateHitlagForAttacker_HitlagMulti

        NotElectric_HitlagMulti:
                stfs f0, 0(r5) # store hitlag multi for defender

                UpdateHitlagForAttacker_HitlagMulti:
                    stfs f0, 0(r4) # store hitlag multi for source

        b Exit_HitlagMulti

        CalculateHitlagMultiOffset_HitlagMulti:
            cmpwi r3, 1
            beq Return1960_HitlagMulti
            cmpwi r3, 2
            bne Exit_CalculateHitlagMultiOffset
            li r3, %(calcOffsetItData(ctx, ExtItHitlagMultiplierOffset))
            b Exit_CalculateHitlagMultiOffset
            Return1960_HitlagMulti:
                li r3, 0x1960
            Exit_CalculateHitlagMultiOffset:
                blr

        Exit_HitlagMulti:
            ""
)

result.addPatches ppc do:
    # Fix for Hitlag multipliers not affecting hits within grabs
    # TODO what about for item related hitlag?
    gecko 0x8006d95c
    # reset multiplier ONLY when there isn't a grabbed_attacker ptr
    # r30 = fighter data
    lwz r3, 0x1A58(r30) # grab_attacker ptr
    cmplwi r3, 0
    bne Exit_8006d95c # if someone is grabbing us, don't reset the multiplier
    stfs f0, 0x1960(r30) # else reset it to 1.0
    Exit_8006d95c:
        li r3, 0 # restore r3

    # Hitlag Function For Other Entities
    gecko 0x8026b454
    # patch hitlag function used by other entities
    # r31 = itdata
    # f0 = floored hitlag frames
    lfs f1, %%calcOffsetItData(ctx, ExtItHitlagMultiplierOffset)(r31)
    fmuls f0, f0, f1 # calculated hitlag frames * multiplier

    # check if calculated hitlag is 0, then set it to a minimum of 1
    lfs f1, -0x7790(rtoc) # 1.0
    fcmpo cr0, f0, f1
    bge+ Exit_8026b454
    fmr f0, f1 # set f0 to 1.0

    Exit_8026b454:
        fctiwz f0, f0

    gecko.end
    