import strutils
type CustomCmd* = object
    name*: string
    id*: int
    code*: int
    eventLen*: int

const 
    HitboxExtensionAdvancedCmd* = CustomCmd(name: "HitboxExtAdv", id: 0x3B, code: 0xEF, eventLen: 0x8)
    HitboxExtensionCmd* = CustomCmd(name: "HitboxExtStd", id: 0x3C, code: 0xF1, eventLen: 0x8)
    SpecialFlagsCmd* = CustomCmd(name: "SpecialFlags", id: 0x3D, code: 0xF5, eventLen: 0x4)
    AttackCapsuleCmd* = CustomCmd(name: "AttackCapsule", id: 0x3E, code: 0xF8, eventLen: 0x8)
    SetVecTargetPosCmd* = CustomCmd(name: "SetVecTargetPos", id: 0x3A, code: 0xEA, eventLen: 0xC)

func asHeaderString*(c: CustomCmd): string =
    var l = 0
    l = l or (c.id shl 24)
    l = l or (c.code shl 16)
    l = l or (c.eventLen shl 8)
    "0x" & l.toHex(8)