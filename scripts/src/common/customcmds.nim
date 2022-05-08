type CustomCmd* = object
    id*: int
    code*: int
    eventLen*: int

const 
    HitboxExtensionAdvancedCmd* = CustomCmd(id: 0, code: 0x3B, eventLen: 0xC)
    HitboxExtensionCmd* = CustomCmd(id: 1, code: 0x3C, eventLen: 0x8)
    SpecialFlagsCmd* = CustomCmd(id: 2, code: 0x3D, eventLen: 0x4)