type GameDataType* = enum
        Vanilla, A20XX, Mex

type
    GameData* = object
        dataType*: GameDataType
        fighterDataSize*: int
        itemDataSize*: int

const
    FighterDataOrigSize* = 0x23EC
    ItemDataOrigSize* = 0xFCC

const
    VanillaGameDat* = GameData(dataType: GameDataType.Vanilla,
    fighterDataSize: FighterDataOrigSize,
    itemDataSize: ItemDataOrigSize)
    
    A20XXGameData* = GameData(dataType: GameDataType.A20XX,
    fighterDataSize: FighterDataOrigSize,
    itemDataSize: ItemDataOrigSize)

    # as of commit #f779005 Nov-29-2021 @ 1:28 AM EST
    MexGameData* = GameData(dataType: GameDataType.Mex,
    fighterDataSize: FighterDataOrigSize + 16 + 32,
    itemDataSize: ItemDataOrigSize + 0x4)

const ZeroDataLength* = 0x8000C160