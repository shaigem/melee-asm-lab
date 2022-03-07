import geckon, sugar
export geckon, sugar

import sequtils
import jsony

type 
    GameDataType* = enum
        Vanilla, A20XX, Mex

    MeleeModKind* = enum
        mmkModule, mmkRegular

    MeleeCodeKind* = enum
        mckMain, mckInsert

type
    CallbackKind* = enum
        cbkCustomFtCmdParse

    Callback* = object
        case kind*: CallbackKind
        of cbkCustomFtCmdParse:
            cfcpRegData*, cfcpRegScriptStructPtr*: Register

    CallbackHookHandler* = proc (cb: Callback): string {.closure.}

    MeleeCode* = object
        case kind: MeleeCodeKind
        of mckInsert:
            insertModName: string
            insertLineIndex: int
        of mckMain: discard
        script*: GeckoCodeScript
        geckoCode*: string

    MeleeMod* = object
        name*: string
        case kind: MeleeModKind
        of mmkModule:
            code*: MeleeCode
        of mmkRegular:
            dependsOn*: seq[string]
            codes*: seq[MeleeCode]

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
    PSVecSubtract* = 0x80342d78
    Vector3SubtractR5* = 0x8000d4f8 # returns in r5
    Vector3Normalize* = 0x8000d2ec

proc callbackFunc*(callback: Callback, handler: CallbackHookHandler): string =
    handler(callback)

proc initMeleeModRegular*(name: string; codes: varargs[MeleeCode]; dependsOn: openArray[MeleeMod] = []): MeleeMod =
    result.kind = mmkRegular
    result.name = name
    result.dependsOn = collect(newSeq):
        for i in dependsOn:
            i.name
    result.codes = codes.toSeq()

proc initMeleeModModule*(name: string; code: MeleeCode): MeleeMod =
    result.kind = mmkModule
    result.name = name
    result.code = code

proc initMeleeInsertCode*(insertToMod: MeleeMod; insertLineIndex: int; script: GeckoCodeScript): MeleeCode = 
    MeleeCode(kind: mckInsert, insertModName: insertToMod.name, insertLineIndex: insertLineIndex, script: script, geckoCode: script.toGeckoCode())

proc initMeleeMainCode*(script: GeckoCodeScript): MeleeCode =
    MeleeCode(kind: mckMain, script: script, geckoCode: script.toGeckoCode())

when isMainModule:

    # generate all module codes
    import common/customcmd
    
    let moduleMods = @[customFtCmdMod]
    writeFile("./output/modules.json", moduleMods.toJson)

    # generate all other code mods
    import hitbox/[specialflagsfthit]

    let codeMods = @[customEventSpecialFlags]
    writeFile("./output/codes.json", codeMods.toJson)
