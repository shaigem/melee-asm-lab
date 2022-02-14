import ../melee

proc patchMain(): string =
    result = ppc:
        # TODO fastforward, fastforward2
        # Custom Fighter Subaction Event
        gecko 0x80073318
        # use 0xF1 as code, make sure r28 == 0x3c
        # r27 = item/fighter gobj
        # r29 = script struct ptr
        # r30 = item/fighter data

        cmpwi r28, 0x3C
        beq- CustomCmdName_80073318
        cmpwi r28, 0x3C
        beq- CustomCmdName_80073318
        b OriginalExit_80073318


        CustomCmdName_80073318:
            nop

        CustomCmdName_80073318:
            nop
        
        CustomCmdName_80073318:
            nop

        OriginalExit_80073318:
            lwz r12, 0(r3)

        # Custom Item Subaction Event
        gecko 0x80279abc
        # use 0xF1 as code, make sure r28 == 0x3c
        # r27 = item/fighter gobj
        # r29 = script struct ptr
        # r30 = item/fighter data
        
        OriginalExit_80279abc:
            lwz r12, 0(r3)        
        gecko.end

proc main() =
    echo "hi"
    #generate "./generated/hitboxext.asm", HitboxExt

when isMainModule:
    main()