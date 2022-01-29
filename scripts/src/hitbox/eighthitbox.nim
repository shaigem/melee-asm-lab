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
    ExtFighterDataSize = (FtHit7 + FtHitSize)
    ExtItemDataSize = (ItHit7 + ItHitSize)

func calcOffsetFtData*(gameData: GameData, varOff: int): int = gameData.fighterDataSize + varOff
func calcOffsetItData*(gameData: GameData, varOff: int): int = gameData.itemDataSize + varOff

func genericLoop(gameData: GameData; loopAddr, countAddr: int64; regPtrFtHit, regHitboxId, regFtData, regNextFtHitPtr: Register; checkState: bool = false; isItem: bool = false; onCalcNewHitOffset: string = ""): string =
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
        %onCalcNewHitOffset
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
        blt+ OrigExit_80071284 # id < 4
        mr rHitboxId, r0
        subi rHitboxId, rHitboxId, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli r3, rHitboxId, {FtHitSize} # id * ft hitbox size
        addi rFtHitPtr, r3, {calcOffsetFtData(gameData, FtHit4)}

        OrigExit_80071284:
            add rFtHitPtr, rFighterData, rFtHitPtr
        
        # Fighter_InitHitbox UNK - Patch
        gecko 0x80076984
        # r3 - 0x270/624 = fighter data
        # r4 - fthit, never changes
        li r7, {NewHitboxCount - OldHitboxCount}
        addi r6, r3, {calcOffsetFtData(gameData, FtHit4) - 624} # previous instructions added 624
        b LoopBody_80076984

        Loop_80076984:
            "subic." r7, r7, 1
            beq- InitVictimArray_80076984
            addi r6, r6, {FtHitSize}
            LoopBody_80076984:
                cmplw r6, r4
                beq Loop_80076984
                lwz r0, 0(r6)
                cmpwi r0, 0
                beq Loop_80076984
                lwz r5, 0x4(r6)
                lwz r0, 0x4(r4)
                cmplw r5, r0
                bne Loop_80076984
                mr r3, r6
                bla r12, 0x800084fc

        InitVictimArray_80076984:
            mr r3, r4
        
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

        # SubactionEvent_0x3C_MeleeHitboxRemoveSpecific
        # r3 = fighter gobj
        # r4 = hitbox id
        gecko 0x8007afcc
        regs (3), rGObj, rHitboxId

        cmplwi rHitboxId, {OldHitboxCount}
        blt+ Exit_8007afcc # id < 4

        lwz r3, 0x2C(rGObj)
        subi rHitboxId, rHitboxId, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli r4, rHitboxId, {FtHitSize} # id * ft/it hitbox size
        
        regs (3), rData, rNextHitOff
        addi rNextHitOff, rNextHitOff, {calcOffsetFtData(gameData, FtHit4)}
        add rNextHitOff, rNextHitOff, rData
        # set hitbox state to 0
        li r0, 0
        stw r0, 0(rNextHitOff)
        blr
        Exit_8007afcc:
            mulli rHitboxId, rHitboxId, 312

        # SubactionEvent_0x30_DecayHitboxDamage - Fighter Hitboxes
        gecko 0x80071660
        # r6 = fighter data

        cmplwi r0, {OldHitboxCount}
        blt+ OrigExit_80071660 # id < 4

        mr r3, r0
        subi r3, r3, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli r3, r3, {FtHitSize} # id * ft hitbox size
        addi r3, r3, {calcOffsetFtData(gameData, FtHit4)}
        OrigExit_80071660:
            add r3, r6, r3

        # SubactionEvent_0x34_ModifyHitboxSize - Fighter Hitboxes
        gecko 0x800716d4
        # r0 = hitbox id
        cmplwi r0, {OldHitboxCount}
        blt+ OrigExit_800716d4 # id < 4
        regs (5), rFtHitSizePtr
        mr rFtHitSizePtr, r0
        subi rFtHitSizePtr, rFtHitSizePtr, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli rFtHitSizePtr, rFtHitSizePtr, {FtHitSize} # id * ft hitbox size
        addi r0, rFtHitSizePtr, {calcOffsetFtData(gameData, FtHit4) + 0x1C} # point to size of hitbox
        b Exit_800716d4
        
        OrigExit_800716d4:
            addi r0, r5, {fdFtHit.int + 0x1C}

        Exit_800716d4:
            ""

        # SubactionEvent_0x38_SetHitboxInteraction - Fighter Hitboxes
        gecko 0x80071728, nop # orig was addi r5, r5, 2324
        gecko 0x80071724
        # r0 = hitbox id
        cmplwi r0, {OldHitboxCount}
        addi r5, r5, {fdFtHit.int}
        blt+ OrigExit_80071724 # id < 4
        regs (5), rFtHitPtr
        mr rFtHitPtr, r0
        subi rFtHitPtr, rFtHitPtr, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli rFtHitPtr, rFtHitPtr, {FtHitSize} # id * ft hitbox size
        addi r5, rFtHitPtr, {calcOffsetFtData(gameData, FtHit4)}    
        OrigExit_80071724:
            rlwinm r0, r3, 31, 31, 31

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

        # Hitbox_MeleeAttackLogicOnPlayer Patches
        %genericLoop(gameData, loopAddr = 0x80077210, countAddr = 0x8007723c, r3, regHitboxId = r25, regFtData = r26, r23, checkState = true)
        %genericLoop(gameData, loopAddr = 0x8007706c, countAddr = 0x80077098, r3, regHitboxId = r30, regFtData = r26, r24, checkState = true)

        # Hitbox_ProjectileHitboxAndFighterHitbox Patches - Not sure what this part does TODO
        %reversedLoop(gameData, loopAddr = 0x8007937c, countAddr = 0x80079410, r3, regHitboxId = r20, regFtData = r27, r22)
        %genericLoop(gameData, loopAddr = 0x8007968c, countAddr = 0x80079748, r4, regHitboxId = r19, regFtData = r27, r20)

        # Hitbox_EntityVSMeleeMain - Hits an Item (e.g. Goomba) with Melee Patches
        %genericLoop(gameData, loopAddr = 0x802704c4, countAddr = 0x802706a0, r26, regHitboxId = r27, regFtData = r28, r31, checkState = true)
        # LoopThroughPlayerHitboxes - Patches
        gecko 0x80076828
        # store fighter data in stack for later use
        # this function doesn't save it :(
        addi r30, r3, 0 # orig code line
        stw r30, 0x10(sp)
        %genericLoop(gameData, loopAddr = 0x8007683c, countAddr = 0x8007687c, r3, regHitboxId = r28, regFtData = r30, r30, checkState = true, 
        onCalcNewHitOffset = "lwz r30, 0x10(sp)") # restore fighter data that is used to calculate new hit offset
        
        # Hitbox_MeleeAttackLogicOnShield - Melee on Shield
        %genericLoop(gameData, loopAddr = 0x80076ce4, countAddr = 0x80076d10, r3, regHitboxId = r28, regFtData = r29, r27, checkState = true)
        
        # MeleeAttackLogic_Clank - Fighters Clanking with Melee
        %genericLoop(gameData, loopAddr = 0x80076a78, countAddr = 0x80076ab0, r3, regHitboxId = r26, regFtData = r30, r24, checkState = true)
        %genericLoop(gameData, loopAddr = 0x80078f7c, countAddr = 0x80078fc4, r16, regHitboxId = r18, regFtData = r28, r19)
        %genericLoop(gameData, loopAddr = 0x80076bc4, countAddr = 0x80076bf0, r3, regHitboxId = r26, regFtData = r28, r23, checkState = true)

        # Hitbox_ProjectileLogicOnHittableProjectile Patches
        # Rebound with a hittable item
        %genericLoop(gameData, loopAddr = 0x80077a4c, countAddr = 0x80077a84, r3, regHitboxId = r26, regFtData = r30, r24, checkState = true)

        # Hitbox_GrabAttackLogic Patches - Grabbing
        %reversedLoop(gameData, loopAddr = 0x80078b10, countAddr = 0x80078c40, r3, regHitboxId = r27, regFtData = r30, r31)
        # Grab_CheckForGrabBoxOverlap - Grabbing Items like Goombas Patches
        %reversedLoop(gameData, loopAddr = 0x8007bd00, countAddr = 0x8007be0c, r3, regHitboxId = r26, regFtData = r31, r27)

        # CPU_CheckForNearbyMeleeHitbox(r3=CPUData,r4=OpponentData) - Fighters
        gecko 0x800bb12c
        # save opponent data to stack
        li r30, 0 # orig code line
        stw r4, 0x10(sp)
        %genericLoop(gameData, loopAddr = 0x800bb138, countAddr = 0x800bb1f4, r29, regHitboxId = r30, regFtData = r31, r31, checkState = true,
        onCalcNewHitOffset = "lwz r31, 0x10(sp)")

        # Hitbox_RefreshHitbox(r3=player,r4=hitboxID) - Fighter Hitboxes Only
        # Links Down Air uses this
        # r3 = fighter gobj
        # r4 = hitbox id
        gecko 0x8007b068
        mr r5, r4 # backup hitbox id to r5 for later use
        mulli r4, r4, 312
        gecko 0x8007b078
        regs (5), rHitboxId, (31), rNextHitOff

        cmplwi rHitboxId, {OldHitboxCount}
        addi rNextHitOff, r4, {fdFtHit.int}
        blt+ OrigExit_8007b078 # id < 4
        
        subi rNextHitOff, rHitboxId, {OldHitboxCount} # new hitbox id = (id - 4)
        mulli rNextHitOff, rNextHitOff, {FtHitSize} # id * ft/it hitbox size
        addi rNextHitOff, rNextHitOff, {calcOffsetFtData(gameData, FtHit4)}

        OrigExit_8007b078:
            ""
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