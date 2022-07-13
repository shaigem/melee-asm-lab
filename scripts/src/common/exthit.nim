import ../melee
import dataexpansion

const
    HeaderInfo = MexHeaderInfo
    GetExtHitFunc* = 0x801510d4
    InitDefaultExtHitFunc* = 0x801510e4
    InitDefaultValuesMeleeHitboxInj = 0x80071288

proc createOnKnockback(): string =
    ppc:

        gecko 0x801510dc
        cmpwi r4, 343
        beq- OnKnockback_OriginalExit

        # inputs
        # r3 = source gobj
        # r4 = defender gobj
        # r5 = source hit ft/it hit struct ptr
        # r6 = optional calculated ExtHit

        # source cannot be a null ptr
        cmplwi r3, 0
        "beqlr-"

        prolog rSrcData, rDefData, rHit, rExtHit, rSrcGObj, rDefGObj
        enumb SourceFighter, DefenderFighter

        lwz rSrcData, 0x2C(r3)
        lwz rDefData, 0x2C(r4)
        mr rHit, r5
        mr rSrcGObj, r3
        mr rDefGObj, r4
        
        # if ExtHit != null, do not calculate ExtHit again
        cmplwi r6, 0
        mr rExtHit, r6
        bne- OnKnockback_DetermineEntityType

        # calculate ExtHit for given Ft/It hit ptr and attacker
        mr r3, rSrcGObj
        mr r4, rHit
        bla r12, {GetExtHitFunc}
        cmplwi r3, 0 # if ExtHit == null, exit
        beq- OnKnockback_Epilog
        mr rExtHit, r3

        OnKnockback_DetermineEntityType:
            lhz r0, 0(rSrcGObj)
            cmplwi cr0, r0, 0x4
            crmove bSourceFighter, eq
            lhz r0, 0(rDefGObj)
            cmplwi cr0, r0, 0x4
            crmove bDefenderFighter, eq
        
        # OnKnockback callbacks for source and defender regardless of entity type

        OnKnockback_StoreHitlag:
            # TODO flinchless still causes hitlag vibration if disablehitlag is true

            OnKnockback_StoreHitlag_GetMultiOff:
                addi r3, rSrcData, 0x1960
                "bt+ bSourceFighter, 0f"
                addi r3, rSrcData, {extItDataOff(HeaderInfo, hitlagMultiplier)}
                
                0: 
                    addi r4, rDefData, 0x1960
                    "bt+ bDefenderFighter, OnKnockback_StoreHitlag_CheckDisable"
                    addi r4, rDefData, {extItDataOff(HeaderInfo, hitlagMultiplier)}
            
            OnKnockback_StoreHitlag_CheckDisable:
                lbz r0, {extHitNormOff(hitFlags)}(rExtHit)
                "rlwinm." r5, r0, {32 - hfDisableHitlag.ord}, 0x1
                beq+ OnKnockback_StoreHitlag_Store
                lfs f0, -0x33A8(rtoc) # 0.0
                "bf bSourceFighter, 0f"
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rSrcData)
                rlwimi r0, r5, {flagOrd(ffDisableHitlag)}
                stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rSrcData)
                b OnKnockback_StoreHitlag_CheckDisable_Defender
                0: stfs f0, 0(r3)

                OnKnockback_StoreHitlag_CheckDisable_Defender:
                    "bf bDefenderFighter, OnKnockback_StoreHitlag_Store_Defender"
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    rlwimi r0, r5, {flagOrd(ffDisableHitlag)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    b OnKnockback_DefFighters

            OnKnockback_StoreHitlag_Store:
                lfs f0, {extHitNormOff(hitlagMultiplier)}(rExtHit) # load hitlag mutliplier
                stfs f0, 0(r3) # store for attacker

                # check electric element for defender
                lwz r0, 0x30(rHit) # dmg hit attribute
                cmplwi r0, 2 # electric
                bne+ OnKnockback_StoreHitlag_Store_Defender # not electric, just store the orig multiplier
                # Electric
                lwz r3, -0x514C(r13) # PlCo values
                lfs f1, 0x1A4(r3) # 1.5 electric hitlag multiplier
                fmuls f0, f1, f0 # 1.5 * multiplier
                OnKnockback_StoreHitlag_Store_Defender:
                    stfs f0, 0(r4)

        OnKnockback_DefFighters:
            bf bDefenderFighter, OnKnockback_Epilog

            # at this point cr6 and cr7 can be used freely

            OnKnockback_StoreHitstunModifier:
                lfs f0, {extHitNormOff(hitstunModifier)}(rExtHit)
                stfs f0, {extFtDataOff(HeaderInfo, hitstunModifier)}(rDefData)
            
            OnKnockback_StoreSDIMultiplier:
                lfs f0, {extHitNormOff(sdiMultiplier)}(rExtHit)
                stfs f0, {extFtDataOff(HeaderInfo, sdiMultiplier)}(rDefData)

            OnKnockback_StoreFacingRestrict:
                # TODO what about defender items?
                lfs f0, 0x2C(rSrcData) # facing direction of attacker
                lbz r0, {extHitNormOff(hitFlags)}(rExtHit)
                "rlwinm." r3, r0, 0, 25, 25 # check back
                bne- OnKnockback_StoreFacingRestrict_Store
                "rlwinm." r3, r0, 0, 26, 26 # check forwards
                beq+ OnKnockback_StoreAutoLink
                OnKnockback_StoreFacingRestrict_F:
                    fneg f0, f0
                OnKnockback_StoreFacingRestrict_Store:
                    stfs f0, 0x1844(rDefData)

                # lfs f0, 0x2C(rSrcData)
                # lfs f1, 0x1844(rDefData)
                # fcmpo cr1, f1, f0
                # lbz r0, {extHitNormOff(hitFlags)}(rExtHit)
                # "rlwinm." r3, r0, 0, 26, 26 # check Forward Type
                # crandc cr1.lt, cr1.eq, eq
                # "rlwinm." r3, r0, 0, 25, 25 # check Opposite Type
                # crnot eq, eq
                # crandc cr1.gt, eq, cr1.eq
                # cror eq, cr1.lt, cr1.gt
                # "bf- eq, OnKnockback_Epilog"

                # OnKnockback_StoreFacingRestrict_Store:
                #     fneg f1, f1
                #     stfs f1, 0x1844(rDefData)
            OnKnockback_StoreAutoLink:
                # TODO item defenders aren't supported
                enumb.restart
                enumb Set, Unk2, LerpAtkMom, LerpSpeedCap, UseVecTargetPos, UseAtkMom, CalcOverrideSpeed, AfterHitlag
                # init autolink flags to 0
                li r0, 0
                mtcrf 0x3, r0
                # # reset autolink vars
                # lfs f0, -0x7700(rtoc)
                # addi r3, rDefData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                # psq_st f0, 0(r3), 0, 0 # frame, posX = 0
                # psq_st f0, 0x8(r3), 0, 0 # posY, speedX = 0
                # stw r0, 0x10(r3) # speedY = 0
                # stb r0, 0x14(r3) # flags = 0

                # check if there is a custom vec target pos to calculate
                lbz r0, {extHitTargetPosOff(targetPosFlags)}(rExtHit)
                mtcrf 0x3, r0
                "bf-" bSet, OnKnockback_StoreAutoLink_CheckAngle

                # calculate target pos using given bone and offsets
                lwz r3, {extHitTargetPosOff(targetPosNode)}(rExtHit)
                addi r4, rExtHit, {extHitTargetPosOff(targetPosOffsetX)}
                addi r5, rDefData, {extFtDataOff(HeaderInfo, vecTargetPosX)} # store it in defender data
                bla r12, {JOBJGetWorldPos}

                # store # of frames
                lwz r0, {extHitTargetPosOff(targetPosFrame)}(rExtHit)
                stw r0, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}(rDefData)

                b OnKnockback_StoreAutoLink_IsAutoLink

                OnKnockback_StoreAutoLink_CheckAngle:
                    addi r3, rDefData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                    lwz r0, 0x1848(rDefData)
                    cmplwi r0, 363
                    beq OnKnockback_StoreAutoLink_Vec_Speed
                    cmplwi r0, 365
                    beq OnKnockback_StoreAutoLink_Vec_Sync
                    cmplwi r0, 366
                    beq OnKnockback_StoreAutoLink_Vec_Pull_Reaction
                    cmplwi r0, 367
                    beq OnKnockback_StoreAutoLink_Vec_Pull
                    b OnKnockback_StoreAutoLink_Exit

                OnKnockback_StoreAutoLink_Vec_Speed:
                    # 363 - sets angle to direction of attacker's momentum
                    crset bUseAtkMom

                    # no target position
                    lfs f0, -0x7700(rtoc) # 0.0
                    psq_st f0, 0x4(r3), 0, 0

                    # default 1 frame
                    li r0, 1
                    stw r0, 0(r3)
                    b OnKnockback_StoreAutoLink_IsAutoLink
            
                OnKnockback_StoreAutoLink_Vec_Sync:
                    # 365 - launch speed = 50% of attacker's momentum
                    crset bUseAtkMom
                    crset bCalcOverrideSpeed

                    # no target position
                    lfs f0, -0x7700(rtoc) # 0.0
                    psq_st f0, 0x4(r3), 0, 0

                    # default 2 frames = 50% of attacker's momentum
                    li r0, 2
                    stw r0, 0(r3)
                    b OnKnockback_StoreAutoLink_IsAutoLink

                OnKnockback_StoreAutoLink_Vec_Pull_Reaction:
                    # 366 - pulls towards hitbox + attacker's momentum,
                    # lerps to attacker's momentum at time of hit in 5 frames, does not adjust launch speed
                    crset bLerpAtkMom
                    crset bUseVecTargetPos
                    crset bUseAtkMom
                    crset bAfterHitlag

                    # use hitbox positions
                    psq_l f0, 0x4C(rHit), 0, 0
                    psq_st f0, 0x4(r3), 0, 0

                    # default 5 frames
                    li r0, 5
                    stw r0, 0(r3)
                    b OnKnockback_StoreAutoLink_IsAutoLink

                OnKnockback_StoreAutoLink_Vec_Pull:
                    crset bLerpSpeedCap
                    crset bUseVecTargetPos
                    crset bUseAtkMom
                    crset bCalcOverrideSpeed
                    crset bAfterHitlag

                    # use hitbox positions
                    psq_l f0, 0x4C(rHit), 0, 0
                    psq_st f0, 0x4(r3), 0, 0

                    # default 10 frames
                    li r0, 10
                    stw r0, 0(r3)

                OnKnockback_StoreAutoLink_IsAutoLink:
                    # inputs
                    # frame, posX, posY should all be set in defender data
                    # cr6, cr7 = autolink flags
                    mr r3, rDefData
                    addi r4, rDefData, {extFtDataOff(HeaderInfo, vecTargetPosFrame)}
                    
                    # set attacker momentum depending on entity type
                    # 0 is used if autolink does not use lerp attacker momentum or use attacker momentum
                    cror eq, bLerpAtkMom, bUseAtkMom
                    lfs f0, -0x7700(rtoc) # 0.0
                    bne OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom
                    lhz r0, 0(rSrcGObj)
                    cmplwi r0, 0x4 # fighter
                    psq_l f0, 0x80(rSrcData), 0, 0
                    beq OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom
                    cmplwi r0, 0x6 # item
                    psq_l f0, 0x40(rSrcData), 0, 0
                    
                    OnKnockback_StoreAutoLink_IsAutoLink_SetAtkMom:
                        psq_st f0, 0xC(r4), 0, 0
                    
                    bla r12, 0x801510b8
                    # returned f1 = [yVel, xVel], f2 = [xVel, yVel]

                    # if override speed && calculate using values BEFORE hitlag, save calculated launch speed
                    crandc eq, bCalcOverrideSpeed, bAfterHitlag
                    bf eq, OnKnockback_StoreAutoLink_IsAutoLink_CalcAngle

                    psq_st f2, 0x4(r4), 0, 0
                    
                    OnKnockback_StoreAutoLink_IsAutoLink_CalcAngle:
                        sp.push
                        sp.temp xTemp, (0xC)
                        lfs f0, -0x7700(rtoc) # 0.0
                        lfs f3, 0x1844(rDefData) # calculated direction
                        fcmpo cr0, f3, f0
                        "bt lt, 0f"
                        fneg f2, f2
                        0: ""
                        bla r12, {Atan2} 
                        lfs f0, -0x76C4(rtoc) # 180/PI
                        fmuls f1, f0, f1
                        fctiw f0, f1
                        stfd f0, sp.xTemp(sp)
                        lwz r0, sp.xTemp+0x4(sp)
                        stw r0, 0x1848(rDefData) # store new calculated angle
                        sp.pop

                        cror eq, bLerpAtkMom, bLerpSpeedCap # hasLerp
                        crnot lt, bCalcOverrideSpeed # !bOverrideSpeed
                        crandc eq, lt, eq # (!bOverrideSpeed && !hasLerp)
                        crandc eq, eq, bAfterHitlag # ((!bOverrideSpeed && !hasLerp) && !bAfterHitlag)
                        "bt- eq, 0f"
                        crset bSet
                        b OnKnockback_StoreAutoLink_Exit
                        0: crclr bSet

                OnKnockback_StoreAutoLink_Exit:
                    li r3, 0
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    rlwimi r0, r3, {flagOrd(ffAttackVecTargetPos)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)

                    mfcr r0
                    stb r0, {extFtDataOff(HeaderInfo, vecTargetPosFlags)}(rDefData)          

            OnKnockback_HandleSetWeight:
                lbz r0, {extHitNormOff(hitFlags)}(rExtHit)
                "rlwinm." r3, r0, {32 - hfSetWeight.ord}, 0x1
                bne OnKnockback_HandleSetWeight_SetTempVars

                OnKnockback_HandleSetWeight_Reset:
                    # not set weight, check to reset any temp variables
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    "rlwinm." r0, r0, 0, {flag(ffSetWeight)}
                    "beq-" OnKnockback_StoreDisableMeteorCancel
                    # call custom reset func
                    mr r3, rDefData
                    bla r12, 0x801510e8
                    b OnKnockback_StoreDisableMeteorCancel

                OnKnockback_HandleSetWeight_SetTempVars:
                    # use set weight so enable flag
                    lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    rlwimi r0, r3, {flagOrd(ffSetWeight)}
                    stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                    
                    data.start
                    0: ".float 0.095"
                    1: ".float 1.7"
                    data.struct 0, "sw.", xGravity, xFallSpeed
                    data.end r3
                    addi r4, rDefData, 0x110 # point to attributes of defender

                    # set gravity and fall speed to Mario's
                    psq_l f0, sw.xGravity(r3), 0, 0
                    psq_st f0, 0x5C(r4), 0, 0

            OnKnockback_StoreDisableMeteorCancel:
                lbz r0, {extHitNormOff(hitFlags)}(rExtHit)
                rlwinm r3, r0, {32 - hfNoMeteorCancel.ord}, 0x1

                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                rlwimi r0, r3, {flagOrd(ffDisableMeteorCancel)}
                stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                
            OnKnockback_StoreNoHitstunLandCancel:
                lbz r0, {extHitAdvOff(hitAdvFlags)}(rExtHit)
                rlwinm r3, r0, {32 - hafNoHitstunCancel.ord}, 0x1
                
                lbz r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                rlwimi r0, r3, {flagOrd(ffNoHitstunCancel)}
                stb r0, {extFtDataOff(HeaderInfo, fighterFlags)}(rDefData)
                
        OnKnockback_Epilog:
            epilog
            OnKnockback_Epilog_Return:
                blr

        OnKnockback_OriginalExit:
            lwz r5, 0x10C(r31)
        gecko.end

proc createInitDefaultValuesMeleeHitbox(): string =
    ppc:
        # Init Default Values for ExtHit - Melee
        # SubactionEvent_0x2C_HitboxMelee_StoreInfoToDataOffset
        gecko {InitDefaultValuesMeleeHitboxInj}
        # r0 = hitbox ID
        # r31 = fighter data
        mulli r3, r0, {sizeof(SpecialHit)}
        addi r3, r3, {HeaderInfo.fighterDataSize}
        add r3, r31, r3
        bla r12, {InitDefaultExtHitFunc}
        lwz r0, 0(r30) # orig code line
        gecko.end

proc createInitDefaultExtHitValuesFunc(): string =
    ppc:
        gecko {InitDefaultExtHitFunc}
        # inputs
        # r3 = ExtHit
        # TODO samus create hitbox?
        cmpwi r4, 343
        beq- InitDefaultExtHit_OrigExit

        # reset vars that need to be 1
        lfs f0, -0x7790(rtoc) # 1
        stfs f0, {extHitNormOff(hitlagMultiplier)}(r3)
        stfs f0, {extHitNormOff(sdiMultiplier)}(r3)
        stfs f0, {extHitNormOff(shieldstunMultiplier)}(r3)

        # reset vars that need to be 0
        lfs f0, -0x778C(rtoc) # 0.0
        stfs f0, {extHitNormOff(hitstunModifier)}(r3)
        li r0, 0
        stw r0, {extHitAtkCapOff(offsetX2)}(r3)
        stw r0, {extHitAtkCapOff(offsetY2)}(r3)
        stw r0, {extHitAtkCapOff(offsetZ2)}(r3)

        stw r0, {extHitAdvOff(hitAdvFlags)}(r3)
        stw r0, {extHitOff(hitStdFlags)}(r3)
        stw r0, {extHitNormOff(hitFlags)}(r3)

        stw r0, {extHitTargetPosOff(targetPosNode)}(r3)
        stw r0, {extHitTargetPosOff(targetPosFrame)}(r3)
        stw r0, {extHitTargetPosOff(targetPosOffsetX)}(r3)
        stw r0, {extHitTargetPosOff(targetPosOffsetY)}(r3)
        stw r0, {extHitTargetPosOff(targetPosOffsetZ)}(r3)
        stw r0, {extHitTargetPosOff(targetPosFlags)}(r3)
        blr

        InitDefaultExtHit_OrigExit:
            lfs f2, -0x5B3C(rtoc) # orig code line
        gecko.end

proc createGetExtHitFunc(): string =
    ppc:
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


const
    CommonExtHitUtilsScript* =
        createCode "sushie's Common ExtHit Functions":
            description: ""
            authors: ["sushie"]
            code:
                %createInitDefaultExtHitValuesFunc()
                %createGetExtHitFunc()
                %createInitDefaultValuesMeleeHitbox()
                %createOnKnockback()

when isMainModule:
    generate "./generated/de/exthit.asm", CommonExtHitUtilsScript
