import melee
import common/dataexpansion

const 
    HeaderInfo = MexHeaderInfo

const
    DamageNoReactionScript* =
        createCode "Enable Custom Armor Modes":
            description: ""
            authors: ["sushie"]
            code:

                # Patch for Adjusting Knockback for Custom No Reaction Modes
                gecko 0x8008da1c
                regs (31), rFighterData

                # f0 = adjusted knockback value
                lbz r3, {extFtDataOff(HeaderInfo, noReactionMode)}(rFighterData)
                cmplwi r3, {DamageReactionMode.drmDamagePower.int}
                beq- KnockbackAdjust_NoReaction_Damage
                cmplwi r3, {DamageReactionMode.drmReactionValue.int}
                bne- KnockbackAdjust_NoReaction_SetKb

                KnockbackAdjust_NoReaction_Knockback_Value:
                    lfs f1, 0x1834(rFighterData)
                    fcmpo cr0, f1, f0
                    blt- KnockbackAdjust_NoReaction_SetKb
                    lfs f0, -0x7700(rtoc) # 0.0
                    b KnockbackAdjust_NoReaction_SetKb

                KnockbackAdjust_NoReaction_Damage:
                    lfs f2, 0x1834(rFighterData)
                    lfs f1, 0x1838(rFighterData) # percent dealt
                    fcmpo cr0, f2, f1
                    blt- KnockbackAdjust_NoReaction_SetKb
                    lfs f0, -0x7700(rtoc) # 0.0
              
                KnockbackAdjust_NoReaction_SetKb:
                    stfs f0, 0x1850(rFighterData)
                
                gecko.end

proc getParseCmdCode*(): string =
    # r27 = fighter/item gobj
    # r30 = item/fighter data
    # r29 = command info
    ppc:
        li r3, {HeaderInfo.fighterDataSize}
        lhz r0, 0(r27)
        cmplwi r0, 0x4
        bnelr
        regs (3), rExtHit, rCmdPtr, (29), rCmdInfo, rData
        
        DamageNoReactionModeCmd_Read:
            # inputs
            # r3 = ExtHit offset
            lwz rCmdPtr, 0x8(rCmdInfo) # subaction ptr

            sp.push
            sp.temp +2, x1, x2
            lwz r0, 0(rCmdPtr)
            rlwinm r0, r0, 0, 0x1FFFFF
            sth r0, sp.x1(sp)
            psq_l f0, sp.x1(sp), 1, 3 # % threshold
            sp.pop

            lbz r0, 0x1(rCmdPtr)
            rlwinm r0, r0, 27, 29, 31 # mode
            stb r0, {extFtDataOff(HeaderInfo, noReactionMode)}(rData)

            cmplwi r0, {DamageReactionMode.drmNormal.int}
            beq DamageNoReactionModeCmd_Mode_Normal
            cmplwi r0, {DamageReactionMode.drmAlways.int}
            beq DamageNoReactionModeCmd_Mode_Always
            cmplwi r0, {DamageReactionMode.drmReactionValue.int}
            beq DamageNoReactionModeCmd_Mode_Reaction_Value
            cmplwi r0, {DamageReactionMode.drmReactionValueSub.int}
            beq DamageNoReactionModeCmd_Mode_Reaction_Value_Sub
            cmplwi r0, {DamageReactionMode.drmDamagePower.int}
            beq DamageNoReactionModeCmd_Mode_Damage_Power
            cmplwi r0, {DamageReactionMode.drmHpDamagePower.int}
            beq DamageNoReactionModeCmd_Mode_Kirby_Stone
            blr

            DamageNoReactionModeCmd_Mode_Normal:
                # turns off all armor

                lfs f0, -0x7700(rtoc) # 0.0
                li r3, 0
                stfs f0, 0x18B4(rData)
                stfs f0, 0x1834(rData)

                # disable super armor flag
                lbz r0, 0x2220(rData)
                rlwimi r0, r3, 4, 27, 27
                stb r0, 0x2220(rData)

                # disable kirby's stone armor
                lbz r0, 0x221C(rData)
                rlwimi r0, r3, 3, 28, 28 # 0x1
                stb r0, 0x221C(rData)
                blr

            DamageNoReactionModeCmd_Mode_Always:
                li r3, 1
                lbz r0, 0x2220(rData)
                rlwimi r0, r3, 4, 27, 27
                stb r0, 0x2220(rData)
                blr

            DamageNoReactionModeCmd_Mode_Damage_Power:
                DamageNoReactionModeCmd_Mode_Reaction_Value:
                    stfs f0, 0x1834(rData)
                    blr

            DamageNoReactionModeCmd_Mode_Reaction_Value_Sub:
                # yoshi
                stfs f0, 0x18B4(rData)
                blr

            DamageNoReactionModeCmd_Mode_Kirby_Stone:
                # kirby's armor (damage HP-based)
                # 800772c8 for melee hits
                li r3, 1
                lbz r0, 0x221C(rData)
                rlwimi r0, r3, 3, 28, 28 # 0x1
                stb r0, 0x221C(rData)
                stfs f0, 0x1834(rData) # HP
                blr