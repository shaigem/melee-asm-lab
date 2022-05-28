import melee

const
    OSLinkAddr = 0x803d70c0
    OSUnlinkAddr = 0x803d70c4

    RelModules* =
        createCode "Enable REL Support v1.0.0":
            description: ""
            authors: ["sushie"]
            code:
                gecko {OSLinkAddr}
                # custom function - OSLink
                OSLink:
                    mflr r0
                    li r5, 0
                    stw r0, 4(r1)
                    stwu r1, -8(r1)
                    bl Link
                    lwz r0, 0xc(r1)
                    addi r1, r1, 8
                    mtlr r0
                    blr 

                Link:
                    mflr r0
                    stw r0, 4(r1)
                    li r0, 0
                    stwu r1, -0x28(r1)
                    stw r31, 0x24(r1)
                    addi r31, r3, 0
                    stw r30, 0x20(r1)
                    addi r30, r5, 0
                    stw r29, 0x1c(r1)
                    addi r29, r4, 0
                    stw r28, 0x18(r1)
                    stb r0, 0x33(r3)
                    lwz r0, 0x1c(r3)
                    cmplwi r0, 3
                    bgt lbl_8029487C
                    cmplwi r0, 2
                    blt lbl_80294884
                    lwz r3, 0x40(r31)
                    cmplwi r3, 0
                    beq lbl_80294860
                    divwu r0, r31, r3
                    mullw r0, r0, r3
                    "subf." r0, r0, r31
                    bne lbl_8029487C
                lbl_80294860:
                    lwz r3, 0x44(r31)
                    cmplwi r3, 0
                    beq lbl_80294884
                    divwu r0, r29, r3
                    mullw r0, r0, r3
                    "subf." r0, r0, r29
                    beq lbl_80294884
                lbl_8029487C:
                    li r3, 0
                    b lbl_80294AC0
                lbl_80294884:
                    lis r3, 0x800030C8 @ha
                    addi r4, r3, 0x800030C8 @l
                    lwzu r5, 4(r4)
                    cmplwi r5, 0
                    bne lbl_802948A0
                    stw r31, 0x30c8(r3)
                    b lbl_802948A4
                lbl_802948A0:
                    stw r31, 4(r5)
                lbl_802948A4:
                    stw r5, 8(r31)
                    li r0, 0
                    stw r0, 4(r31)
                    stw r31, 0(r4)
                    lwz r0, 0x10(r31)
                    add r0, r0, r31
                    stw r0, 0x10(r31)
                    lwz r0, 0x24(r31)
                    add r0, r0, r31
                    stw r0, 0x24(r31)
                    lwz r0, 0x28(r31)
                    add r0, r0, r31
                    stw r0, 0x28(r31)
                    lwz r0, 0x1c(r31)
                    cmplwi r0, 3
                    blt lbl_802948F0
                    lwz r0, 0x48(r31)
                    add r0, r0, r31
                    stw r0, 0x48(r31)
                lbl_802948F0:
                    li r5, 1
                    li r3, 8
                    b lbl_80294938
                lbl_802948FC:
                    lwz r0, 0x10(r31)
                    add r4, r0, r3
                    lwz r0, 0(r4)
                    cmplwi r0, 0
                    beq lbl_8029491C
                    add r0, r0, r31
                    stw r0, 0(r4)
                    b lbl_80294930
                lbl_8029491C:
                    lwz r0, 4(r4)
                    cmplwi r0, 0
                    beq lbl_80294930
                    stb r5, 0x33(r31)
                    stw r29, 0(r4)
                lbl_80294930:
                    addi r3, r3, 8
                    addi r5, r5, 1
                lbl_80294938:
                    lwz r0, 0xc(r31)
                    cmplw r5, r0
                    blt lbl_802948FC
                    lwz r4, 0x28(r31)
                    b lbl_8029495C
                lbl_8029494C:
                    lwz r0, 4(r4)
                    add r0, r0, r31
                    stw r0, 4(r4)
                    addi r4, r4, 8
                lbl_8029495C:
                    lwz r3, 0x28(r31)
                    lwz r0, 0x2c(r31)
                    add r0, r3, r0
                    cmplw r4, r0
                    blt lbl_8029494C
                    lbz r0, 0x30(r31)
                    cmplwi r0, 0
                    beq lbl_80294998
                    lwz r3, 0x10(r31)
                    slwi r0, r0, 3
                    lwz r4, 0x34(r31)
                    lwzx r0, r3, r0
                    rlwinm r0, r0, 0, 0, 0x1e
                    add r0, r4, r0
                    stw r0, 0x34(r31)
                lbl_80294998:
                    lbz r0, 0x31(r31)
                    cmplwi r0, 0
                    beq lbl_802949C0
                    lwz r3, 0x10(r31)
                    slwi r0, r0, 3
                    lwz r4, 0x38(r31)
                    lwzx r0, r3, r0
                    rlwinm r0, r0, 0, 0, 0x1e
                    add r0, r4, r0
                    stw r0, 0x38(r31)
                lbl_802949C0:
                    lbz r0, 0x32(r31)
                    cmplwi r0, 0
                    beq lbl_802949E8
                    lwz r3, 0x10(r31)
                    slwi r0, r0, 3
                    lwz r4, 0x3c(r31)
                    lwzx r0, r3, r0
                    rlwinm r0, r0, 0, 0, 0x1e
                    add r0, r4, r0
                    stw r0, 0x3c(r31)
                lbl_802949E8:
                    lis r3, 0x800030D0 @ha
                    lwz r3, 0x800030D0 @l(r3)
                    cmplwi r3, 0
                    beq lbl_80294A04
                    lwz r0, 0x14(r31)
                    add r0, r0, r3
                    stw r0, 0x14(r31)
                lbl_80294A04:
                    li r3, 0
                    addi r4, r31, 0
                    bl Relocate
                    lis r3, 0x800030C8 @ha
                    lwz r28, 0x800030C8 @l(r3)
                    b lbl_80294A40
                lbl_80294A1C:
                    addi r3, r31, 0
                    addi r4, r28, 0
                    bl Relocate
                    cmplw r28, r31
                    beq lbl_80294A3C
                    addi r3, r28, 0
                    addi r4, r31, 0
                    bl Relocate
                lbl_80294A3C:
                    lwz r28, 4(r28)
                lbl_80294A40:
                    cmplwi r28, 0
                    bne lbl_80294A1C
                    cmpwi r30, 0
                    beq lbl_80294AA4
                    lwz r4, 0x28(r31)
                    lwz r0, 0x2c(r31)
                    addi r5, r4, 0
                    add r3, r4, r0
                    addi r0, r3, 7
                    subf r0, r5, r0
                    srwi r0, r0, 3
                    cmplw r5, r3
                    mtctr r0
                    bge lbl_80294AA4
                lbl_80294A78:
                    lwz r3, 0(r5)
                    cmplwi r3, 0
                    beq lbl_80294A90
                    lwz r0, 0(r31)
                    cmplw r3, r0
                    bne lbl_80294A9C
                lbl_80294A90:
                    subf r0, r4, r5
                    stw r0, 0x2c(r31)
                    b lbl_80294AA4
                lbl_80294A9C:
                    addi r5, r5, 8
                    bdnz lbl_80294A78
                lbl_80294AA4:
                    lwz r5, 0x20(r31)
                    addi r3, r29, 0
                    li r4, 0
                    bla r12, {Memset}
                    mr r3, r31
                    bl func_8029453C
                    li r3, 1
                lbl_80294AC0:
                    lwz r0, 0x2c(r1)
                    lwz r31, 0x24(r1)
                    lwz r30, 0x20(r1)
                    lwz r29, 0x1c(r1)
                    lwz r28, 0x18(r1)
                    addi r1, r1, 0x28
                    mtlr r0
                    blr 

                Relocate:
                    mflr r0
                    stw r0, 4(r1)
                    stwu r1, -0x40(r1)
                    stmw r23, 0x1c(r1)
                    "or." r26, r3, r3
                    addi r27, r4, 0
                    beq lbl_80294568
                    lwz r31, 0(r26)
                    b lbl_8029456C
                lbl_80294568:
                    li r31, 0
                lbl_8029456C:
                    lwz r3, 0x28(r27)
                    lwz r0, 0x2c(r27)
                    addi r4, r3, 0
                    add r3, r3, r0
                    addi r0, r3, 7
                    subf r0, r4, r0
                    srwi r0, r0, 3
                    cmplw r4, r3
                    mtctr r0
                    bge lbl_802945A8
                lbl_80294594:
                    lwz r0, 0(r4)
                    cmplw r0, r31
                    beq lbl_802945B0
                    addi r4, r4, 8
                    bdnz lbl_80294594
                lbl_802945A8:
                    li r3, 0
                    b lbl_802947EC
                lbl_802945B0:
                    bl lbl_803F2290
                    mflr r25
                    #lis r3, lbl_803BEF68 @ha
                    lwz r30, 4(r4)
                    #addi r25, r3, lbl_803BEF68 @l
                    li r29, 0
                    b lbl_802947B4
                lbl_802945C4:
                    lhz r0, 0(r30)
                    cmplwi r31, 0
                    add r28, r28, r0
                    beq lbl_802945EC
                    lbz r0, 3(r30)
                    lwz r3, 0x10(r26)
                    slwi r0, r0, 3
                    lwzx r0, r3, r0
                    rlwinm r5, r0, 0, 0, 0x1e
                    b lbl_802945F0
                lbl_802945EC:
                    li r5, 0
                lbl_802945F0:
                    cmpwi r4, 6
                    beq lbl_802946B8
                    bge lbl_80294628
                    cmpwi r4, 2
                    beq lbl_80294668
                    bge lbl_80294618
                    cmpwi r4, 0
                    beq lbl_802947B0
                    bge lbl_80294658
                    b lbl_802947A4
                lbl_80294618:
                    cmpwi r4, 4
                    beq lbl_80294694
                    bge lbl_802946A4
                    b lbl_80294684
                lbl_80294628:
                    cmpwi r4, 0xc9
                    beq lbl_802947B0
                    bge lbl_8029464C
                    cmpwi r4, 0xa
                    beq lbl_80294700
                    blt lbl_802946E4
                    cmpwi r4, 0xe
                    bge lbl_802947A4
                    b lbl_80294720
                lbl_8029464C:
                    cmpwi r4, 0xcb
                    bge lbl_802947A4
                    b lbl_80294740
                lbl_80294658:
                    lwz r0, 4(r30)
                    add r0, r5, r0
                    stw r0, 0(r28)
                    b lbl_802947B0
                lbl_80294668:
                    lwz r0, 4(r30)
                    lwz r3, 0(r28)
                    add r0, r5, r0
                    rlwinm r3, r3, 0, 0x1e, 5
                    rlwimi r3, r0, 0, 6, 0x1d
                    stw r3, 0(r28)
                    b lbl_802947B0
                lbl_80294684:
                    lwz r0, 4(r30)
                    add r0, r5, r0
                    sth r0, 0(r28)
                    b lbl_802947B0
                lbl_80294694:
                    lwz r0, 4(r30)
                    add r0, r5, r0
                    sth r0, 0(r28)
                    b lbl_802947B0
                lbl_802946A4:
                    lwz r0, 4(r30)
                    add r0, r5, r0
                    srwi r0, r0, 0x10
                    sth r0, 0(r28)
                    b lbl_802947B0
                lbl_802946B8:
                    lwz r0, 4(r30)
                    add r4, r5, r0
                    "rlwinm." r0, r4, 0, 0x10, 0x10
                    beq lbl_802946D0
                    li r3, 1
                    b lbl_802946D4
                lbl_802946D0:
                    li r3, 0
                lbl_802946D4:
                    srwi r0, r4, 0x10
                    add r0, r0, r3
                    sth r0, 0(r28)
                    b lbl_802947B0
                lbl_802946E4:
                    lwz r0, 4(r30)
                    lwz r3, 0(r28)
                    add r0, r5, r0
                    rlwinm r3, r3, 0, 0x1e, 0xf
                    rlwimi r3, r0, 0, 0x10, 0x1d
                    stw r3, 0(r28)
                    b lbl_802947B0
                lbl_80294700:
                    lwz r0, 4(r30)
                    lwz r3, 0(r28)
                    add r0, r5, r0
                    subf r0, r28, r0
                    rlwinm r3, r3, 0, 0x1e, 5
                    rlwimi r3, r0, 0, 6, 0x1d
                    stw r3, 0(r28)
                    b lbl_802947B0
                lbl_80294720:
                    lwz r0, 4(r30)
                    lwz r3, 0(r28)
                    add r0, r5, r0
                    subf r0, r28, r0
                    rlwinm r3, r3, 0, 0x1e, 0xf
                    rlwimi r3, r0, 0, 0x10, 0x1d
                    stw r3, 0(r28)
                    b lbl_802947B0
                lbl_80294740:
                    lbz r0, 3(r30)
                    cmplwi r29, 0
                    lwz r3, 0x10(r27)
                    slwi r0, r0, 3
                    add r3, r3, r0
                    lwz r0, 0(r3)
                    addi r23, r3, 0
                    rlwinm r28, r0, 0, 0, 0x1e
                    beq lbl_80294784
                    lwz r0, 0(r29)
                    lwz r4, 4(r29)
                    rlwinm r24, r0, 0, 0, 0x1e
                    addi r3, r24, 0
                    bla r12, {DCFlushRange}
                    mr r3, r24
                    lwz r4, 4(r29)
                    bla r12, {ICInvalidateRange}
                lbl_80294784:
                    lwz r0, 0(r23)
                    "clrlwi." r0, r0, 0x1f
                    beq lbl_80294798
                    mr r0, r23
                    b lbl_8029479C
                lbl_80294798:
                    li r0, 0
                lbl_8029479C:
                    mr r29, r0
                    b lbl_802947B0
                lbl_802947A4:
                    addi r3, r25, 0
                    crclr 6
                    bla r12, {OSReport}
                lbl_802947B0:
                    addi r30, r30, 8
                lbl_802947B4:
                    lbz r4, 2(r30)
                    cmplwi r4, 0xcb
                    bne lbl_802945C4
                    cmplwi r29, 0
                    beq lbl_802947E8
                    lwz r0, 0(r29)
                    lwz r4, 4(r29)
                    rlwinm r25, r0, 0, 0, 0x1e
                    addi r3, r25, 0
                    bla r12, {DCFlushRange}
                    mr r3, r25
                    lwz r4, 4(r29)
                    bla r12, {ICInvalidateRange}
                lbl_802947E8:
                    li r3, 1
                lbl_802947EC:
                    lmw r23, 0x1c(r1)
                    lwz r0, 0x44(r1)
                    addi r1, r1, 0x40
                    mtlr r0
                    blr

                func_8029453C:
                    OSNotifyLink:
                        blr 
                
                lbl_803F2290:
                    blrl
                    ".asciz" "OSLink: unknown relocation type %3d\n"
                    align 4

                gecko {OSUnlinkAddr}
                # Custom Function - OSUnlink
                OSUnlink:
                    mflr r0
                    stw r0, 4(r1)
                    stwu r1, -0x18(r1)
                    stw r31, 0x14(r1)
                    mr r31, r3
                    stw r30, 0x10(r1)
                    lwz r4, 4(r3)
                    lwz r5, 8(r3)
                    cmplwi r4, 0
                    bne lbl_80294D70
                    lis r3, 0x800030CC @ha
                    stw r5, 0x800030CC @l(r3)
                    b lbl_80294D74
                lbl_80294D70:
                    stw r5, 8(r4)
                lbl_80294D74:
                    cmplwi r5, 0
                    bne lbl_80294D88
                    lis r3, 0x800030C8 @ha
                    stw r4, 0x800030C8 @l(r3)
                    b lbl_80294D8C
                lbl_80294D88:
                    stw r4, 4(r5)
                lbl_80294D8C:
                    lis r3, 0x800030C8 @ha
                    lwz r30, 0x800030C8 @l(r3)
                    b lbl_80294DA8
                lbl_80294D98:
                    addi r3, r31, 0
                    addi r4, r30, 0
                    bl Undo
                    lwz r30, 4(r30)
                lbl_80294DA8:
                    cmplwi r30, 0
                    bne lbl_80294D98
                    mr r3, r31
                    bl func_80294540
                    lis r3, 0x800030D0 @ha
                    lwz r3, 0x800030D0 @l(r3)
                    cmplwi r3, 0
                    beq lbl_80294DD4
                    lwz r0, 0x14(r31)
                    subf r0, r3, r0
                    stw r0, 0x14(r31)
                lbl_80294DD4:
                    lbz r0, 0x30(r31)
                    cmplwi r0, 0
                    beq lbl_80294DFC
                    lwz r4, 0x10(r31)
                    slwi r3, r0, 3
                    lwz r0, 0x34(r31)
                    lwzx r3, r4, r3
                    rlwinm r3, r3, 0, 0, 0x1e
                    subf r0, r3, r0
                    stw r0, 0x34(r31)
                lbl_80294DFC:
                    lbz r0, 0x31(r31)
                    cmplwi r0, 0
                    beq lbl_80294E24
                    lwz r4, 0x10(r31)
                    slwi r3, r0, 3
                    lwz r0, 0x38(r31)
                    lwzx r3, r4, r3
                    rlwinm r3, r3, 0, 0, 0x1e
                    subf r0, r3, r0
                    stw r0, 0x38(r31)
                lbl_80294E24:
                    lbz r0, 0x32(r31)
                    cmplwi r0, 0
                    beq lbl_80294E4C
                    lwz r4, 0x10(r31)
                    slwi r3, r0, 3
                    lwz r0, 0x3c(r31)
                    lwzx r3, r4, r3
                    rlwinm r3, r3, 0, 0, 0x1e
                    subf r0, r3, r0
                    stw r0, 0x3c(r31)
                lbl_80294E4C:
                    lwz r4, 0x28(r31)
                    b lbl_80294E64
                lbl_80294E54:
                    lwz r0, 4(r4)
                    subf r0, r31, r0
                    stw r0, 4(r4)
                    addi r4, r4, 8
                lbl_80294E64:
                    lwz r3, 0x28(r31)
                    lwz r0, 0x2c(r31)
                    add r0, r3, r0
                    cmplw r4, r0
                    blt lbl_80294E54
                    li r6, 1
                    li r5, 8
                    li r3, 0
                    b lbl_80294EC4
                lbl_80294E88:
                    lbz r0, 0x33(r31)
                    lwz r4, 0x10(r31)
                    cmplw r6, r0
                    add r4, r4, r5
                    bne lbl_80294EA8
                    stb r3, 0x33(r31)
                    stw r3, 0(r4)
                    b lbl_80294EBC
                lbl_80294EA8:
                    lwz r0, 0(r4)
                    cmplwi r0, 0
                    beq lbl_80294EBC
                    subf r0, r31, r0
                    stw r0, 0(r4)
                lbl_80294EBC:
                    addi r5, r5, 8
                    addi r6, r6, 1
                lbl_80294EC4:
                    lwz r0, 0xc(r31)
                    cmplw r6, r0
                    blt lbl_80294E88
                    lwz r0, 0x24(r31)
                    li r3, 1
                    subf r0, r31, r0
                    stw r0, 0x24(r31)
                    lwz r0, 0x28(r31)
                    subf r0, r31, r0
                    stw r0, 0x28(r31)
                    lwz r0, 0x10(r31)
                    subf r0, r31, r0
                    stw r0, 0x10(r31)
                    lwz r0, 0x1c(r1)
                    lwz r31, 0x14(r1)
                    lwz r30, 0x10(r1)
                    addi r1, r1, 0x18
                    mtlr r0
                    blr                
                
                Undo:
                    mflr r0
                    stw r0, 4(r1)
                    stwu r1, -0x38(r1)
                    stmw r25, 0x1c(r1)
                    mr r28, r4
                    lwz r4, 0(r3)
                    lwz r3, 0x28(r28)
                    lwz r0, 0x2c(r28)
                    addi r5, r3, 0
                    add r3, r3, r0
                    addi r0, r3, 7
                    subf r0, r5, r0
                    srwi r0, r0, 3
                    cmplw r5, r3
                    mtctr r0
                    bge lbl_80294B58
                lbl_80294B44:
                    lwz r0, 0(r5)
                    cmplw r0, r4
                    beq lbl_80294B60
                    addi r5, r5, 8
                    bdnz lbl_80294B44
                lbl_80294B58:
                    li r3, 0
                    b lbl_80294D28
                lbl_80294B60:
                    bl lbl_803F22B8
                    mflr r27
                    #lis r3, lbl_803BEF90 @ha
                    lwz r31, 4(r5)
                    #addi r27, r3, lbl_803BEF90 @l
                    li r30, 0
                    b lbl_80294CF0
                lbl_80294B74:
                    lhz r0, 0(r31)
                    cmpwi r4, 6
                    li r3, 0
                    add r29, r29, r0
                    beq lbl_80294C28
                    bge lbl_80294BB8
                    cmpwi r4, 2
                    beq lbl_80294BF4
                    bge lbl_80294BA8
                    cmpwi r4, 0
                    beq lbl_80294CEC
                    bge lbl_80294BE8
                    b lbl_80294CE0
                lbl_80294BA8:
                    cmpwi r4, 4
                    beq lbl_80294C10
                    bge lbl_80294C1C
                    b lbl_80294C04
                lbl_80294BB8:
                    cmpwi r4, 0xc9
                    beq lbl_80294CEC
                    bge lbl_80294BDC
                    cmpwi r4, 0xa
                    beq lbl_80294C44
                    blt lbl_80294C34
                    cmpwi r4, 0xe
                    bge lbl_80294CE0
                    b lbl_80294C6C
                lbl_80294BDC:
                    cmpwi r4, 0xcb
                    bge lbl_80294CE0
                    b lbl_80294C7C
                lbl_80294BE8:
                    li r0, 0
                    stw r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294BF4:
                    lwz r0, 0(r29)
                    rlwinm r0, r0, 0, 0x1e, 5
                    stw r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C04:
                    li r0, 0
                    sth r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C10:
                    li r0, 0
                    sth r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C1C:
                    li r0, 0
                    sth r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C28:
                    li r0, 0
                    sth r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C34:
                    lwz r0, 0(r29)
                    rlwinm r0, r0, 0, 0x1e, 0xf
                    stw r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C44:
                    lbz r0, 0x32(r28)
                    cmplwi r0, 0
                    beq lbl_80294C58
                    lwz r0, 0x3c(r28)
                    subf r3, r29, r0
                lbl_80294C58:
                    lwz r0, 0(r29)
                    rlwinm r0, r0, 0, 0x1e, 5
                    rlwimi r0, r3, 0, 6, 0x1d
                    stw r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C6C:
                    lwz r0, 0(r29)
                    rlwinm r0, r0, 0, 0x1e, 0xf
                    stw r0, 0(r29)
                    b lbl_80294CEC
                lbl_80294C7C:
                    lbz r0, 3(r31)
                    cmplwi r30, 0
                    lwz r3, 0x10(r28)
                    slwi r0, r0, 3
                    add r3, r3, r0
                    lwz r0, 0(r3)
                    addi r26, r3, 0
                    rlwinm r29, r0, 0, 0, 0x1e
                    beq lbl_80294CC0
                    lwz r0, 0(r30)
                    lwz r4, 4(r30)
                    rlwinm r25, r0, 0, 0, 0x1e
                    addi r3, r25, 0
                    bla r12, {DCFlushRange}
                    mr r3, r25
                    lwz r4, 4(r30)
                    bla r12, {ICInvalidateRange}
                lbl_80294CC0:
                    lwz r0, 0(r26)
                    "clrlwi." r0, r0, 0x1f
                    beq lbl_80294CD4
                    mr r0, r26
                    b lbl_80294CD8
                lbl_80294CD4:
                    li r0, 0
                lbl_80294CD8:
                    mr r30, r0
                    b lbl_80294CEC
                lbl_80294CE0:
                    addi r3, r27, 0
                    crclr 6
                    bla r12, {OSReport}
                lbl_80294CEC:
                    addi r31, r31, 8
                lbl_80294CF0:
                    lbz r4, 2(r31)
                    cmplwi r4, 0xcb
                    bne lbl_80294B74
                    cmplwi r30, 0
                    beq lbl_80294D24
                    lwz r0, 0(r30)
                    lwz r4, 4(r30)
                    rlwinm r27, r0, 0, 0, 0x1e
                    addi r3, r27, 0
                    bla r12, {DCFlushRange}
                    mr r3, r27
                    lwz r4, 4(r30)
                    bla r12, {ICInvalidateRange}
                lbl_80294D24:
                    li r3, 1
                lbl_80294D28:
                    lmw r25, 0x1c(r1)
                    lwz r0, 0x3c(r1)
                    addi r1, r1, 0x38
                    mtlr r0
                    blr 

                lbl_803F22B8:
                    blrl
                    ".asciz" "OSUnlink: unknown relocation type %3d\n"
                    align 4

                func_80294540:
                    OSNotifyUnlink:
                        blr 

                gecko 0x801a4510 # Scene_Main
                bl "_start"
                
                Const:
                    blrl
                    ".asciz" "mod.bin"
                    align 2

                "_start:"
                # TODO cleanup the loading of the main.rel...
                
                prolog r31, r30, rBuffer, rModPath, xTemp, (0x8)
                bl Const
                mflr rModPath

                # # get file size
                # mr r3, rModPath # file name
                # bla r12, 0x800163d8 # size_t File_GetLength(const char *path);

                # # allocate buffer for file
                # bla r12, 0x8037f1e4 # void *HSD_MemAlloc(u32 size);
                
                load r3, 0x81700000

                mr rBuffer, r3 # save allocated buffer


                # load the file to buffer
                mr r3, rModPath # file name/path
                mr r4, rBuffer # buffer
                addi r5, sp, sp.xTemp # returns read size
                bla r12, 0x8001668C # void File_Read(const char *path, void *buffer, size_t *size);

                # alloc bss
                #li r3, 0
                #lwz r4, 0x20(rBuffer)
                #bla r12, 0x80343ef0
                # has to be in multiples of 0x200
                lwz r3, sp.xTemp(sp)
                addi r3, r3, 511
                rlwinm r3, r3, 0, 0, 22
                add r4, r3, rBuffer # rBuffer + read file size is our BSS

                # link functions in the REL
                # r3 = rel buffer
                # r4 = BSS?
#                mr r4, r3
                mr r3, rBuffer
                bla r12, {OSLinkAddr}
                
                # mr r3, rBuffer
                # lwz r4, sp.xTemp(sp)
                # bla r12, 0x80344840 # DCStoreRange

                # mr r3, rBuffer
                # lwz r4, sp.xTemp(sp)
                # bla r12, 0x803448d4 # ICInvalidateRange

                # mtctr rBuffer
                # bctrl

                # run rel prolog
                lwz r0, 0x34 (rBuffer)
                mtlr r0
                blrl


                exit_Scene_Main:
#                    # free the read file buffers
                    #mr r3, rBuffer
                    #bla r12, 0x8037f1b0 # void HSD_Free(void *ptr);
                    epilog

                orig_Scene_Main:
                    mflr r0
                gecko.end

when isMainModule:
    generate "./generated/general/rel.asm", RelModules