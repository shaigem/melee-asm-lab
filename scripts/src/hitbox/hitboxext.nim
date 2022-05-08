import ../melee
import ../common/dataexpansion
import ../common/customcmds

const 
    HeaderInfo = MexHeaderInfo
    CustomFunctionReadEvent = "0x801510e0"

proc getParseCmdCode*(): string =
    # r27 = fighter/item gobj
    ppc:
        prolog
        lhz r0, 0(r27)
        cmplwi r0, 0x4
        beq HitboxExtCmd_SetupFighter
        cmplwi r0, 0x6
        bne HitboxExtCmd_Exit # INVALID, TODO OSPrint?

        HitboxExtensionCmd_SetupItem:
            li r3, 0
            li r4, 0
            li r5, {HeaderInfo.itemDataSize}
            li r6, {ItemData.idItHit.int}
            li r7, {ItHitSize}
            li r8, {extItDataOff(HeaderInfo, newHits) - ((OldHitboxCount * ItHitSize) + ItemData.idItHit.int)}
            b HitboxExtCmd_ReadEvent

        HitboxExtCmd_SetupFighter:
            lwz r3, 0x8(r29)
            lbz r3, 0x7(r3) # flags 1
            "rlwinm." r3, r3, 0, {flag(hfAffectOnlyThrow)}
            li r3, 0
            li r4, 0
            beq HitboxExtCmd_SetupFighter_NoThrow
            addi r3, r30, {extFtDataOff(HeaderInfo, specialThrowHit)}
            addi r4, r30, 0xDF4
            HitboxExtCmd_SetupFighter_NoThrow:
                li r5, {HeaderInfo.fighterDataSize}
                li r6, {FighterData.fdFtHit.int}
                li r7, {FtHitSize}
                li r8, {extFtDataOff(HeaderInfo, newHits) - ((OldHitboxCount * FtHitSize) + FighterData.fdFtHit.int)}

        HitboxExtCmd_ReadEvent:
            cmpwi r28, {HitboxExtensionAdvancedCmd.code}
            li r9, 1
            beq HitBoxEventCmd_ReadEvent_Branch
            li r9, 0
            HitBoxEventCmd_ReadEvent_Branch:
                bla r12, {CustomFunctionReadEvent}

        HitboxExtCmd_Exit:
            epilog
            blr
