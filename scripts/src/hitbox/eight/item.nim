proc patchItems*(gameInfo: GameHeaderInfo): string =

    let subactionEventPatches = proc(): string = result = ppc:
        # Patch Parse Event 0x2C - Create Hitbox Projectile
        # r30 = item data
        # r4 = hitbox id
        gecko 0x802790F8
        regs (0), rItemData, (29), rItHitPtr
        cmplwi r4, {OldHitboxCount}
        blt+ OrigExit_802790F8 # id < 4
        %o(gameInfo, regHitboxId = r4, regResultHitPtr = r29, hitSize = ItHitSize, extDataOffset = gameInfo.extItDataOff(ExtData, specialHits))
        OrigExit_802790F8:
            add rItHitPtr, rItemData, rItHitPtr

        # Item Hitbox Multiply Size - Patch
        gecko 0x80275594
        # r4 = hitbox id
        regs (4), rHitboxId
        cmplwi rHitboxId, {OldHitboxCount}
        mulli rHitboxId, rHitboxId, {ItHitSize} # orig code line
        blt+ OrigExit_80275594
        addi rHitboxId, rHitboxId, {offsetToNewHit(gameInfo, isItem = true)}
        OrigExit_80275594:
            ""

        # Item Hitbox Set Size Event - Patch
        gecko 0x80279634
        regs (4), rHitboxId, rItHitPtr
        cmplwi rHitboxId, {OldHitboxCount}
        addi rItHitPtr, rItHitPtr, {idItHit.int} # orig code line
        blt+ OrigExit_80279634
        addi rItHitPtr, rItHitPtr, {offsetToNewHit(gameInfo, isItem = true)}
        OrigExit_80279634:
            ""

        # Item Hitbox Set Damage Event - Patch
        gecko 0x80279590
        # r3 = hitbox id
        regs (3), rHitboxId
        cmplwi rHitboxId, {OldHitboxCount}
        mulli rHitboxId, rHitboxId, {ItHitSize}
        blt+ OrigExit_80279590
        addi rHitboxId, rHitboxId, {offsetToNewHit(gameInfo, isItem = true)}
        OrigExit_80279590:
            ""

        # Item Hitbox Deactivate Specific ID Patch
        gecko 0x80272564
        # r3 = hitbox id
        regs (4), rHitboxId
        cmplwi rHitboxId, {OldHitboxCount}
        mulli rHitboxId, rHitboxId, {ItHitSize} # orig code line
        blt+ OrigExit_80272564
        addi rHitboxId, rHitboxId, {offsetToNewHit(gameInfo, isItem = true)}
        OrigExit_80272564:
            ""

        # Item Hitbox Reactivate Specific ID Patch
        gecko 0x80272688
        # r4 = hitbox id
        regs (4), rHitboxId
        cmplwi rHitboxId, {OldHitboxCount}
        mulli r30, rHitboxId, {ItHitSize} # orig code line
        blt+ OrigExit_80272688
        addi r30, r30, {offsetToNewHit(gameInfo, isItem = true)}
        OrigExit_80272688:
            ""

    let miscLoopPatches = proc(): string = result = ppc:
        # Check if Item has an Active Hitbox Patch
        gecko 0x802758cc
        addi r3, r3, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r0, {NewHitboxCount - OldHitboxCount}
        mtctr r0
        Loop_802758cc:
            lwz r0, {idItHit.int + ItHitSize}(r3)
            addi r3, r3, {ItHitSize}
            cmpwi r0, 0
            "bdnzt+" eq, Loop_802758cc
        # loop exit
        li r3, 0
        beq Exit_802758cc
        li r3, 1
        Exit_802758cc:
            ""

        # Unknown Patch When Item is Thrown
        gecko 0x80275934
        addi r3, r3, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r0, {NewHitboxCount - OldHitboxCount}
        mtctr r0
        Loop_80275934:
            lwz r0, {idItHit.int + ItHitSize}(r3)
            addi r3, r3, {ItHitSize}
            cmpwi r0, 0
            "bdnzt+" eq, Loop_80275934
        # loop exit
        li r0, 0
        beq Exit_80275934
        li r0, 1
        Exit_80275934:
            ""
        # Unknown Patch When Item is Thrown/Released (Damage?)
        gecko 0x802759c0, beq 0x18
        gecko 0x802759d0, bne 0x8
        gecko 0x802759d8
        addi r3, r3, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r7, {(NewHitboxCount - OldHitboxCount) + 1}

        Loop_802759d8:
            "subic." r7, r7, 1
            beqlr
            lwz r0, 0x710(r3)
            addi r5, r3, {idItHit.int + ItHitSize}
            addi r3, r3, {ItHitSize}
            cmpwi r0, 0
            beq Loop_802759d8
            lfs f0, 0xC(r5)
            fcmpo cr0, f1, f0
            cror 2, 0, 2
            bne Loop_802759d8
            fmr f1, f0
            b Loop_802759d8
        
        # Item Patch Set Scale? Used In Mewtwo's Disable And Warp Star
        gecko 0x8027562c, beq 0x10
        gecko 0x8027563c
        addi r3, r3, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r7, {(NewHitboxCount - OldHitboxCount) + 1}

        Loop_8027563c:
            "subic." r7, r7, 1
            beqlr
            lwz r0, 0x710(r3)
            addi r4, r3, {idItHit.int + ItHitSize}
            addi r3, r3, {ItHitSize}
            cmpwi r0, 0
            beq Loop_8027563c
            lfs f0, 0x1C(r4)
            fmuls f0, f0, f1
            stfs f0, 0x1C(r4)
            b Loop_8027563c
           
        # ItemHitbox Set Scale For Active Hitboxes Patch
        gecko 0x80275588, beq 0x8
        gecko 0x80275590
        addi r3, r3, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r0, {NewHitboxCount - OldHitboxCount}
        mtctr r0
        Loop_80275590:
            lwz r0, {idItHit.int + ItHitSize}(r3)
            addi r4, r3, {idItHit.int + ItHitSize}
            addi r3, r3, {ItHitSize}
            cmpwi r0, 0
            beq CheckToLoop
            stfs f1, 0x1C(r4) # store new size
            CheckToLoop:
                bdnz+ Loop_80275590
        Exit_80275590:
            blr

        # Unknown Item Patch Victim Array
        gecko 0x8026fe2c
        addi r5, r5, {offsetToNewHit(gameInfo, isItem = true) + ItHitSize}
        li r7, {(NewHitboxCount - OldHitboxCount) + 1}

        Loop_8026fe2c:
            "subic." r7, r7, 1
            li r0, 0
            beq- Exit_8026fe2c
            addi r3, r5, {idItHit.int + ItHitSize}
            cmplw r3, r30
            addi r5, r5, {ItHitSize}
            beq Loop_8026fe2c
            lwz r0, 0(r3)
            cmpwi r0, 0
            beq Loop_8026fe2c
            lwz r4, 0x4(r3)
            lwz r0, 0x4(r30)
            cmplw r4, r0
            bne Loop_8026fe2c
            mr r4, r30
            bla r12, 0x800084FC
            li r0, 1

        Exit_8026fe2c:
            ""

    let miscPatches = proc(): string = result = ppc:
        # ItemHitbox_Draw - Collision Bubbles for Item
        %genericLoopPatch(gameInfo, patchAddr = 0x8026ed70, hitboxCountAddr = 0x8026ed88, regData = rNone, regHitboxId = r27, regNextHitPtr = r28, isItem = true, 
        onOrigReturn = (gameInfo, regData, regHitboxId, regNextHitPtr, isItem) => (ppc do: addi r3, {regNextHitPtr}, {idItHit.int}))

        # Item_UpdateHitboxPositions - Item Hitboxes
        %genericLoopPatch(gameInfo, patchAddr = 0x8027139c, hitboxCountAddr = 0x8027144c, regData = rNone, regHitboxId = r28, regNextHitPtr = r31, isItem = true, 
        onOrigReturn = (gameInfo, regData, regHitboxId, regNextHitPtr, isItem) => (ppc do: addi r29, {regNextHitPtr}, {idItHit.int}))

        # CPU_CheckForNearbyItemHitbox(r3=CPUData,r4=ItemData) - Items
        gecko 0x800bb240
        # save item data to stack for later use
        mr r29, r4 # orig code line, store item data
        stw r4, 0x10(sp)

        %genericLoop(gameInfo, loopAddr = 0x800bb3e8, countAddr = 0x800bb4e8, r25, regHitboxId = r31, regFtData = r29, r29, checkState = true, isItem = true,
        onCalcNewHitOffset = "lwz r29, 0x10(sp)")

        %genericLoop(gameInfo, loopAddr = 0x800bb500, countAddr = 0x800bb614, r25, regHitboxId = r31, regFtData = r29, r29, checkState = true, isItem = true,
        onCalcNewHitOffset = "lwz r29, 0x10(sp)")

        %genericLoop(gameInfo, loopAddr = 0x800bb63c, countAddr = 0x800bb73c, r25, regHitboxId = r27, regFtData = r26, r26, checkState = true, isItem = true,
        onCalcNewHitOffset = "lwz r26, 0x10(sp)")

        # Items_OnReflect - Patches
        %genericLoopPatch(gameInfo, patchAddr = 0x8026a020, hitboxCountAddr = 0x8026a074, regData = r31, regHitboxId = r28, regNextHitPtr = r29, isItem = true)

        # Hitbox_EntityVSProjectileMain = Projectile Hits an Item Clank
        # uses hitboxId < 4 to exit instead of != 4 because it can skip 4 where it calculates the new offset for our hits 4-7
        %genericLoopPatch(gameInfo, patchAddr = 0x80270938, hitboxCountAddr = 0x80270a1c, regData = rNone, regHitboxId = r18, regNextHitPtr = r23, isItem = true,
        exitBranchType = "blt+", onOrigReturn = (gameInfo, regData, regHitboxId, regNextHitPtr, isItem) => (ppc do: addi r4, {regNextHitPtr}, {idItHit.int}))

        # Unknown Item Storing Victim
        %genericLoopPatch(gameInfo, patchAddr = 0x8026fa5c, hitboxCountAddr = 0x8026faa0, regData = rNone, regHitboxId = r28, regNextHitPtr = r30, isItem = true)
        # Related to Item Hitboxes When Touching Ground (e.g. apple falling)
        %genericLoopPatch(gameInfo, patchAddr = 0x80275670, hitboxCountAddr = 0x802756a0, regData = rNone, regHitboxId = r30, regNextHitPtr = r31, isItem = true)
        %genericLoopPatch(gameInfo, patchAddr = 0x8026fb24, hitboxCountAddr = 0x8026fb68, regData = rNone, regHitboxId = r25, regNextHitPtr = r24, isItem = true)
        # Unknown Projectile Logic On Player
        %genericLoopPatch(gameInfo, patchAddr = 0x8026fc54, hitboxCountAddr = 0x8026fc84, regData = rNone, regHitboxId = r27, regNextHitPtr = r26, isItem = true)
        %genericLoopPatch(gameInfo, patchAddr = 0x8026fca8, hitboxCountAddr = 0x8026fcd8, regData = rNone, regHitboxId = r27, regNextHitPtr = r26, isItem = true)

        # Items_RemoveAllHitboxes - Clear All Item Hitboxes
        %genericLoop(gameInfo, loopAddr = 0x80272604, countAddr = 0x80272610, r3, regHitboxId = r29, regFtData = r30, r31, isItem = true)
        gecko 0x80272630, cmplwi r31, {NewHitboxCount}
        # Unknown Item Hitbox Function Patch
        gecko 0x802712a0
        mr r5, r4 # store hitbox id to r5 for later use
        mulli r4, r4, {ItHitSize} # orig code line
        gecko 0x802712b4
        # r5 = hitbox id
        regs (5), rHitboxId, (30), rItHitPtr
        cmplwi rHitboxId, {OldHitboxCount}
        addi rItHitPtr, r4, {idItHit.int} # use old r4 orig line
        blt+ OrigExit_802712b4
        %o(gameInfo, regHitboxId = r5, regResultHitPtr = r30, hitSize = ItHitSize, extDataOffset = gameInfo.extItDataOff(ExtData, specialHits))
        OrigExit_802712b4:
            ""
        # ProjectileLogicOnEntity Patches - Stores Victim
        gecko 0x8026fae4
        addi r31, r7, 0 # orig code line
        stw r27, 0x20(sp) # save item data for later use
        %genericLoop(gameInfo, loopAddr = 0x8026fb9c, countAddr = 0x8026fbdc, r3, regHitboxId = r25, regFtData = r23, r23, checkState = true, isItem = true,
        onCalcNewHitOffset = "lwz r23, 0x20(sp)")

        # Hitbox_ProjectileHitboxAndFighterHitbox Patches
        %genericLoop(gameInfo, loopAddr = 0x8007942c, countAddr = 0x80079a7c, r23, regHitboxId = r28, regFtData = r24, r29, checkState = true, isItem = true)

        # Hitbox_EntityVSProjectileMain = Projectile Hits an Item Patches
        %reversedLoop(gameInfo, loopAddr = 0x80270808, countAddr = 0x80270880, r3, regHitboxId = r20, regFtData = r31, r23, isItem = true)
        %genericLoop(gameInfo, loopAddr = 0x8027089c, countAddr = 0x80270ca4, r19, regHitboxId = r20, regFtData = r27, r21, checkState = true, isItem = true)

        # Item_ResetAllHitboxesHitPlayers - Patches
        gecko 0x8027148c
        # store item data in stack for later use
        # this function doesn't save it :(
        add r31, r3, r0
        stw r3, 0xC(sp)
        %genericLoop(gameInfo, loopAddr = 0x80271490, countAddr = 0x8027149c, r3, regHitboxId = r30, regFtData = r31, r31, isItem = true,
        onCalcNewHitOffset = "lwz r31, 0xC(sp)") # restore item data that is used to calculate new hit offset

        # GrabLogic for Items - Like Like
        %reversedLoop(gameInfo, loopAddr = 0x8027029c, countAddr = 0x802703bc, r3, regHitboxId = r26, regFtData = r31, r27, isItem = true)

    result = ppc:
        %subactionEventPatches()
        %miscLoopPatches()
        %miscPatches()
        gecko.end