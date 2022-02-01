import ../../melee
import ../../common/dataexpansion
import strutils, sugar

type LoopPatch = proc(gameData: GameHeaderInfo, regData, regHitboxId, regNextHitPtr: Register, isItem: bool = false): string

proc offsetToNewHit(gameData: GameHeaderInfo, isItem: bool = false): int =
    let extHitOffset = if isItem: (gameData.extItDataOff(newHits)) else: (gameData.extFtDataOff(newHits))
    let hitSize = if isItem: ItHitSize else: FtHitSize
    let hitOffset = if isItem: idItHit.int else: fdFtHit.int
    result = extHitOffset - ((OldHitboxCount * hitSize) + hitOffset)

proc genericCalcNewHitOffset(gameData: GameHeaderInfo, regData, regHitboxId, regNextHitPtr: Register, isItem: bool = false): string =
    let hitOffset = offsetToNewHit(gameData, isItem)
    result = ppc:
        addi {regNextHitPtr}, {regNextHitPtr}, {hitOffset}

proc genericOrigReturn(gameData: GameHeaderInfo, regData, regHitboxId, regNextHitPtr: Register, isItem: bool = false): string =
    let dataHitOffset = if isItem: idItHit.int else: fdFtHit.int
    result = ppc:
        lwz r0, {dataHitOffset}({regNextHitPtr})

func genericLoopPatch(gameData: GameHeaderInfo, patchAddr, hitboxCountAddr: int64; regData, regHitboxId, regNextHitPtr: Register; 
    onCalcNewHitOffset: LoopPatch = genericCalcNewHitOffset, onOrigReturn: LoopPatch = genericOrigReturn, isItem: bool = false, exitBranchType: string = "bne+"): string =
    let patchAddr = patchAddr.toHex(8)
    let hitboxCountAddr = hitboxCountAddr.toHex(8)
    let exitBranchInstr = exitBranchType & " OrigExit_" & patchAddr
    result = ppc:
        gecko {"0x" & patchAddr}
        cmplwi {regHitboxId}, {OldHitboxCount}
        %exitBranchInstr

        # when id == 4
        # calculate using new starting Hit offset
        %onCalcNewHitOffset(gameData, regData, regHitboxId, regNextHitPtr, isItem)

        %("OrigExit_" & patchAddr & ":")
        %onOrigReturn(gameData, regData, regHitboxId, regNextHitPtr, isItem)
        # patch the check maximum hitbox ids
        gecko {"0x" & hitboxCountAddr}, cmplwi {regHitboxId}, {NewHitboxCount}

# TODO this func is deprecated
func genericLoop(gameData: GameHeaderInfo; loopAddr, countAddr: int64; regPtrFtHit, regHitboxId, regFtData, regNextFtHitPtr: Register; 
    checkState: bool = false; isItem: bool = false; onCalcNewHitOffset, onOrigReturn, onUseNewOffsets: string = ""): string =
    let checkStateInstr = if checkState: ppc: lwz r0, 0({regPtrFtHit}) else: ""
    let hitPtrOffset = if isItem: idItHit.int else: fdFtHit.int
    let newHitPtrOffset = if isItem: gameData.extItDataOff(newHits) else: gameData.extFtDataOff(newHits)
    let calcNewOffsetInstr = if regFtData == rNone: ppc: li {regNextFtHitPtr}, {newHitPtrOffset} else: ppc: addi {regNextFtHitPtr}, {regFtData}, {newHitPtrOffset}
    let onOrigReturn = if onOrigReturn.isEmptyOrWhitespace(): ppc: addi {regPtrFtHit}, {regNextFtHitPtr}, {hitPtrOffset} else: onOrigReturn
    let onUseNewOffsets = 
        if onUseNewOffsets.isEmptyOrWhitespace(): 
            ppc:
                mr {regPtrFtHit}, {regNextFtHitPtr}
                %checkStateInstr
        else: 
            onUseNewOffsets


    result = ppc:
        gecko {loopAddr}
        cmplwi {regHitboxId}, {OldHitboxCount}
        %onOrigReturn
        bgt {"UseNewOffsets_" & loopAddr.toHex(8)} # id > 4
        "bne+" {"OrigExit_" & loopAddr.toHex(8)} # id != 4

        # when id == 4
        # calculate using new starting Hit offset
        %onCalcNewHitOffset
        %calcNewOffsetInstr
        
        %("UseNewOffsets_" & loopAddr.toHex(8) & ":")
        %onUseNewOffsets

        %("OrigExit_" & loopAddr.toHex(8) & ":")
        ""
        # patch the check maximum hitbox ids
        gecko {countAddr}, cmplwi {regHitboxId}, {NewHitboxCount}

# TODO function is deprecated
func reversedLoop(gameData: GameHeaderInfo; loopAddr, countAddr: int64; regPtrFtHit, regHitboxId, regFtData, regNextFtHitPtr: Register; isItem: bool = false): string =
    let hitboxOffsetInstr = if isItem: ppc: lwz r0, 0x5D4({regNextFtHitPtr}) else: ppc: lwz r0, 0x914({regNextFtHitPtr})
    let newHitPtrOffset = if isItem: gameData.extItDataOff(newHits) else: gameData.extFtDataOff(newHits)
    result = ppc:
        gecko {loopAddr}
        cmplwi {regHitboxId}, {OldHitboxCount}
        %hitboxOffsetInstr
        bgt {"UseNewOffsets_" & loopAddr.toHex(8)} # id > 4
        "bne+" {"OrigExit_" & loopAddr.toHex(8)} # id != 4

        # when id == 4
        # calculate using new starting FtHit offset
        addi {regNextFtHitPtr}, {regFtData}, {newHitPtrOffset}
        
        %("UseNewOffsets_" & loopAddr.toHex(8) & ":")
        mr {regPtrFtHit}, {regNextFtHitPtr}
        lwz r0, 0({regPtrFtHit})

        %("OrigExit_" & loopAddr.toHex(8) & ":")
        ""
        # patch the check maximum hitbox ids
        gecko {countAddr}, cmplwi {regHitboxId}, {NewHitboxCount}

# TODO remove this function after converting
func o*(gameData: GameHeaderInfo; regHitboxId, regResultHitPtr: Register; hitSize, extDataOffset: int): string =
    result = ppc:
        subi {regResultHitPtr}, {regHitboxId}, {OldHitboxCount}
        mulli {regResultHitPtr}, {regResultHitPtr}, {hitSize}
        addi {regResultHitPtr}, {regResultHitPtr}, {extDataOffset}

include item
include fighter

proc patchMain(gameInfo: GameHeaderInfo): string =
    result = ppc:
        %patchItems(gameInfo)
        %patchFighters(gameInfo)
        gecko.end

const EightHitboxes* =
    createCode "Enable Eight Hitboxes":
        description: "Enables up to 8 active hitboxes for Melee"
        authors: ["sushie"]
        code:
            %patchMain(MexHeaderInfo)

proc main() =
    generate "./generated/eighthitboxes.asm", EightHitboxes

when isMainModule:
    main()