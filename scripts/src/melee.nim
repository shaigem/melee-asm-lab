import geckon
export geckon
type GameDataType* = enum
        Vanilla, A20XX, Mex

type
    GameData* = object
        dataType*: GameDataType
        fighterDataSize*: int
        itemDataSize*: int

type FighterData* = enum
    fdScript = 0x3E4

type Script* = enum
    sEventTimer = 0x0
    sFrameTimer = 0x4
    sCurrent = 0x8

const
    FighterDataOrigSize* = 0x23EC
    ItemDataOrigSize* = 0xFCC

const
    VanillaGameData* = GameData(dataType: GameDataType.Vanilla,
    fighterDataSize: FighterDataOrigSize,
    itemDataSize: ItemDataOrigSize)
    
    A20XXGameData* = GameData(dataType: GameDataType.A20XX,
    fighterDataSize: FighterDataOrigSize,
    itemDataSize: ItemDataOrigSize)

    # as of commit #f779005 Nov-29-2021 @ 1:28 AM EST
    MexGameData* = GameData(dataType: GameDataType.Mex,
    fighterDataSize: FighterDataOrigSize + 16 + 32,
    itemDataSize: ItemDataOrigSize + 0x4)

const 
    SelfInducedPhysics* = 0x80085134
    ZeroDataLength* = 0x8000C160

func patchFighterDataAllocation*(gameData: GameData; dataSizeToAdd: int): string =
    result = ppc:
        # patch init player block values
        gecko 0x80068EEC
        # extra stuff for 20XX
        block:
            if gameData.dataType == GameDataType.A20XX:
                ppc:
                    li r4, 0
                    stw r4, 0x20(r31)
                    stw r4, 0x24(r31)
                    stb r4, 0x0D(r3)
                    sth r4, 0x0E(r3)
                    stb r4, 0x21FD(r3)
                    sth r4, 0x21FE(r3)
            else:
                ""
        addi r30, r3, 0 # backup data pointer
        load r4, 0x80458fd0
        lwz r4, 0x20(r4)
        bla r12, %ZeroDataLength
        # exit
        mr r3, r30
        lis r4, 0x8046

        # next patch, adjust the fighter data size
        gecko 0x800679BC, li r4, %(gameData.fighterDataSize + dataSizeToAdd)

        # finally, any specific game mod patches
        block:
            if gameData.dataType == GameDataType.A20XX:
                # fixes crash for 20XX when loading marth & roy
                # NOTE: this will break the 'Marth and Roy Sword Swing File Colors'!!!
                ppc: gecko 0x8013651C, blr
            else:
                ""
        gecko.end

func patchItemDataAllocation*(gameData: GameData; dataSizeToAdd: int): string =
    let newDataSize = gameData.itemDataSize + dataSizeToAdd
    result = ppc:
        # size patch
        gecko 0x80266FD8, li r4, %newDataSize
        # init extended item data patch
        gecko 0x80268754
        addi r29, r3, 0 # backup r3
        li r4, %newDataSize
        bla r12, %ZeroDataLength
        # _return
        mr r3, r29 # restore r3
        `mr.` r6, r3
        gecko.end
