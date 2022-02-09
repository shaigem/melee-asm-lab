import geckon
export geckon
type GameDataType* = enum
        Vanilla, A20XX, Mex

type
    GameData* = object
        dataType*: GameDataType
        fighterDataSize*: int
        itemDataSize*: int

    FighterData* = enum
        fdSelfVelX = 0x80
        fdSelfVelY = 0x84
        fdelfVelZ = 0x88
        fdScript = 0x3E4
        fdFtHit = 0x914

    ItemData* = enum
        idItHit = 0x5D4

    Script* = enum
        sEventTimer = 0x0
        sFrameTimer = 0x4
        sCurrent = 0x8

const
    FighterDataOrigSize* = 0x23EC
    ItemDataOrigSize* = 0xFCC
    FtHitSize* = 312
    ItHitSize* = 316

const 
    SelfInducedPhysics* = 0x80085134
    ZeroDataLength* = 0x8000C160
    HumanOrCPUCheck* = 0x800a2040
    Atan2* = 0x80022c30
    FighterSetBoneRotX* = 0x8007592C
    Sin* = 0x803263d4
    Cos* = 0x80326240
    PSVecMag* = 0x80342dfc