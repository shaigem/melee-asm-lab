type CustomCmd* = object
    id*: int
    code*: int
    eventLen*: int

const 
    HitboxExtensionCmd* = CustomCmd(id: 0, code: 0x3C, eventLen: 0x8)
    SpecialFlagsCmd* = CustomCmd(id: 1, code: 0x3D, eventLen: 0x4)