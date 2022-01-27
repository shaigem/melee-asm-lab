import ../melee

const 
    FtHitSize = 312
    ItHitSize = 316
    OldHitboxCount = 4
    NewHitboxCount = 8

# New variable pointer offsets for FIGHTERS only
const
    FtHit4 = 0x0
    FtHit5 = FtHit4 + FtHitSize
    FtHit6 = FtHit5 + FtHitSize
    FtHit7 = FtHit6 + FtHitSize
    
# New variable pointer offsets for ITEMS only
const
    ItHit4 = 0x0
    ItHit5 = ItHit4 + ItHitSize
    ItHit6 = ItHit5 + ItHitSize
    ItHit7 = ItHit6 + ItHitSize
    
const 
    ExtFighterDataSize = (FtHit7 + ItHitSize)
    ExtItemDataSize = (ItHit7 + ItHitSize)

func calcOffsetFtData*(gameData: GameData, varOff: int): int = gameData.fighterDataSize + varOff
func calcOffsetItData*(gameData: GameData, varOff: int): int = gameData.itemDataSize + varOff

func genericLoop(gameData: GameData; loopAddr, countAddr: int64; regPtrFtHit, regHitboxId, regFtData, regNextFtHitPtr: Register; checkState: bool = false; isItem: bool = false;): string =
    let checkStateInstr = if checkState: ppc: lwz r0, 0({regPtrFtHit}) else: ""
    let hitPtrOffset = if isItem: idItHit.int else: fdFtHit.int
    let newHitPtrOffset = if isItem: calcOffsetItData(gameData, ItHit4) else: calcOffsetFtData(gameData, FtHit4)
    let calcNewOffsetInstr = if regFtData == rNone: ppc: li {regNextFtHitPtr}, {newHitPtrOffset} else: ppc: addi {regNextFtHitPtr}, {regFtData}, {newHitPtrOffset}
    result = ppc:
        gecko {loopAddr}
        cmplwi {regHitboxId}, {OldHitboxCount}
        addi {regPtrFtHit}, {regNextFtHitPtr}, {hitPtrOffset}
        bgt {"UseNewOffsets_" & loopAddr.toHex(8)} # id > 4
        "bne+" {"OrigExit_" & loopAddr.toHex(8)} # id != 4

        # when id == 4
        # calculate using new starting Hit offset
        %calcNewOffsetInstr
        
        %("UseNewOffsets_" & loopAddr.toHex(8) & ":")
        mr {regPtrFtHit}, {regNextFtHitPtr}
        %checkStateInstr

        %("OrigExit_" & loopAddr.toHex(8) & ":")
        ""
        # patch the check maximum hitbox ids
        gecko {countAddr}, cmplwi {regHitboxId}, {NewHitboxCount}

func reversedLoop(gameData: GameData; loopAddr, countAddr: int64; regPtrFtHit, regHitboxId, regFtData, regNextFtHitPtr: Register): string =
    result = ppc:
        gecko {loopAddr}
        cmplwi {regHitboxId}, {OldHitboxCount}
        lwz r0, 0x914({regNextFtHitPtr})
        bgt {"UseNewOffsets_" & loopAddr.toHex(8)} # id > 4
        "bne+" {"OrigExit_" & loopAddr.toHex(8)} # id != 4

        # when id == 4
        # calculate using new starting FtHit offset
        addi {regNextFtHitPtr}, {regFtData}, {calcOffsetFtData(gameData, FtHit4)}
        
        %("UseNewOffsets_" & loopAddr.toHex(8) & ":")
        mr {regPtrFtHit}, {regNextFtHitPtr}
        lwz r0, 0({regPtrFtHit})

        %("OrigExit_" & loopAddr.toHex(8) & ":")
        ""
        # patch the check maximum hitbox ids
        gecko {countAddr}, cmplwi {regHitboxId}, {NewHitboxCount}

func patchSubactionEventParsing(gameData: GameData): string =
    result = ppc:

        # Patch Parse Event 0x2C - Create Fighter Hitbox
        # r31 = fighter data
        # r0 = hitbox id
        gecko 0x80071284
        regs rHitboxId, (30), rFtHitPtr, rFighterData

        cmplwi r0, {OldHitboxCount}
        blt+ OrigExit_8007127C # id < 4

        mr rHitboxId, r0
        subi rHitboxId, rHitboxId, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli r3, rHitboxId, {FtHitSize} # id * ft hitbox size
        addi rFtHitPtr, r3, {calcOffsetFtData(gameData, FtHit4)}

        OrigExit_8007127C:
            add rFtHitPtr, rFighterData, rFtHitPtr

        # # Patch Parse Event 0x2C - Create Hitbox Projectile
        # # r30 = item data
        # # r4 = hitbox id
        # gecko 0x802790F8
        # regs (0), rItemData, (29), rItHitPtr

        # cmplwi r4, {OldHitboxCount}
        # blt+ OrigExit_802790F8 # id < 4
        # subi r3, r4, {OldHitboxCount} # new hitbox id = (id - 4)
        # mulli r3, r3, {ItHitSize} # id * it hitbox size
        # addi rItHitPtr, r3, {calcOffsetItData(gameData, ItHit4)}

        # OrigExit_802790F8:
        #     add rItHitPtr, rItemData, rItHitPtr
        
        gecko.end

func patchCollisionDrawLogic(gameData: GameData): string =
    result = ppc:
        # PlayerDisplayState_Draw_Logic - Collision Bubbles for Fighters
        # r25 = hitbox id
        # r31 = fighter data
        %genericLoop(gameData, loopAddr = 0x80080614, countAddr = 0x8008062c, r3, regHitboxId = r25, regFtData = r31, r26)
        # ItemHitbox_Draw - Collision Bubbles for Item
#        %genericLoop(gameData, loopAddr = 0x8026ed70, countAddr = 0x8026ed88, r3, regHitboxId = r27, regFtData = r31, r28, isItem = true)
        gecko.end

func patchUpdateHitboxPositions(gameData: GameData): string =
    result = ppc:
        # Hitbox_UpdateAllHitboxPositions - Update Positions for Fighter Hitboxes
        %genericLoop(gameData, loopAddr = 0x8007aeac, countAddr = 0x8007aeb8, r4, regHitboxId = r29, regFtData = r30, r31)
        # Item_UpdateHitboxPositions - Item Hitboxes
#        %genericLoop(gameData, loopAddr = 0x8027139c, countAddr = 0x8027144c, r29, regHitboxId = r28, regFtData = rNone, r31, isItem = true)        
        gecko.end

func patchRemoveAllHitboxes(gameData: GameData): string =
    result = ppc:
        # Hitbox_Deactivate_All - SubactionEvent Clear All Fighter Hitboxes
        %genericLoop(gameData, loopAddr = 0x8007b020, countAddr = 0x8007b02c, r3, regHitboxId = r29, regFtData = r30, r31)
        gecko.end

func patchAttackLogic(gameData: GameData): string =
    result = ppc:
        # Hitbox_MeleeAttackLogicMain Patches
        %genericLoop(gameData, loopAddr = 0x80078d88, countAddr = 0x80078e2c, r4, regHitboxId = r23, regFtData = r28, r30, checkState = true)
        %genericLoop(gameData, loopAddr = 0x80078e48, countAddr = 0x8007922c, r23, regHitboxId = r30, regFtData = r24, r29, checkState = true)
        # %genericLoop(gameData, loopAddr = 0x80078f7c, countAddr = 0x80078fc4, r16, regHitboxId = r18, regFtData = r28, r19)

        # Hitbox_MeleeAttackLogicOnPlayer Patches
        #%genericLoop2(gameData, loopAddr = 0x8007706c, countAddr = 0x80077098, r3, regHitboxId = r30, regFtData = r26, r24)
        %genericLoop(gameData, loopAddr = 0x80077210, countAddr = 0x8007723c, r3, regHitboxId = r25, regFtData = r26, r23, checkState = true)

        # Hitbox_ProjectileHitboxAndFighterHitbox Patches???
        %reversedLoop(gameData, loopAddr = 0x8007937c, countAddr = 0x80079410, r3, regHitboxId = r20, regFtData = r27, r22)

        # Hitbox_EntityVSMeleeMain - Hits an Item (e.g. Goomba) with Melee Patches
        %genericLoop(gameData, loopAddr = 0x802704c4, countAddr = 0x802706a0, r26, regHitboxId = r27, regFtData = r28, r31, checkState = true)

        gecko.end

proc patchMain(gameData: GameData): string =
    result = ppc:
        %patchSubactionEventParsing(gameData)
        %patchCollisionDrawLogic(gameData)
        %patchUpdateHitboxPositions(gameData)
        %patchRemoveAllHitboxes(gameData)
        %patchAttackLogic(gameData)
        gecko.end

const EightHitboxes* =
    createCode "Eight Hitboxes":
        code:
            %patchFighterDataAllocation(MexGameData, ExtFighterDataSize)
            %patchItemDataAllocation(MexGameData, ExtItemDataSize)
            %patchMain(MexGameData)

proc main() =
    generate "./generated/eighthitboxes.asm", EightHitboxes

when isMainModule:
    main()