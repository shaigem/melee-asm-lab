void func_8000D2EC(Vec current, Vec target, Vec *currentVelocity, float smoothTime, float maxSpeed)
{
}
    float omega = 2.0F / smoothTime;
    float deltaTime = 1.0;
    float x = omega * deltaTime;
    float exp = 1.0F / (1.0F + x + 0.48F * x * x + 0.235F * x * x * x);
    float change_x = current.x - target.x;
    float change_y = current.y - target.y;
    Vec originalTo = target;

    float temp_x;
    float temp_y;
    float output_x;
    float output_y;
    float origMinusCurrent_x;
    float origMinusCurrent_y;
    float outMinusOrig_x;
    float outMinusOrig_y;
    // Clamp maximum speed
    float maxChange = maxSpeed * smoothTime;

    float maxChangeSq = maxChange * maxChange;
    float sqDist = change_x * change_x + change_y * change_y;
    if (sqDist > maxChangeSq)
    {
        float mag = sqrtf(sqDist);
        change_x = change_x / mag * maxChange;
        change_y = change_y / mag * maxChange;
    }

    target.x = current.x - change_x;
    target.y = current.y - change_y;

    temp_x = (currentVelocity->x + omega * change_x) * deltaTime;
    temp_y = (currentVelocity->y + omega * change_y) * deltaTime;

    currentVelocity->x = (currentVelocity->x - omega * temp_x) * exp;
    currentVelocity->y = (currentVelocity->y - omega * temp_y) * exp;

    output_x = target.x + (change_x + temp_x) * exp;
    output_y = target.y + (change_y + temp_y) * exp;

    // Prevent overshooting
    origMinusCurrent_x = originalTo.x - current.x;
    origMinusCurrent_y = originalTo.y - current.y;
    outMinusOrig_x = output_x - originalTo.x;
    outMinusOrig_y = output_y - originalTo.y;

    if (origMinusCurrent_x * outMinusOrig_x + origMinusCurrent_y * outMinusOrig_y > 0)
    {
        output_x = originalTo.x;
        output_y = originalTo.y;

        currentVelocity->x = (output_x - originalTo.x) / deltaTime;
        currentVelocity->y = (output_y - originalTo.y) / deltaTime;
    } 
  
  
   0:    mflr    r0 
   4:    stw     r0,4(r1) 
 s 8:    stwu    r1,-0x88(r1) 
 > c:    stfd    f31,0x80(r1) 
 > 10:    stfd    f30,0x78(r1) 
 > 14:    stfd    f29,0x70(r1) 
 > 18:    stfd    f28,0x68(r1) 
 > 1c:    stfd    f27,0x60(r1) 
 > 20:    fmuls   f27,f2,f1 # maxChange
 s 24:    stw     r31,0x5c(r1) 
 r 28:    mr      r31,r5 
 > 2c:    stw     r30,0x58(r1) 
 | 30:    addi    r30,r4,0 
 | 34:    stw     r29,0x54(r1) 
 r 38:    addi    r29,r3,0 
 > 3c:    lfs     f0,@10(0) 
 > 40:    lfs     f8,@11(0) 
 > 44:    fdivs   f31,f0,f1 
 > 48:    lfs     f3,@13(0) 
 > 4c:    lfs     f5,@12(0) 
 > 50:    lfs     f2,4(r3) 
 > 54:    lfs     f1,4(r4) 
 > 58:    fmuls   f9,f31,f8 
 > 5c:    lfs     f4,0(r3) 
 > 60:    fsubs   f28,f2,f1 
 i 64:    lwz     r3,0(r4) 
 > 68:    lwz     r0,4(r4) 
 > 6c:    fmuls   f7,f3,f9 
 > 70:    lfs     f3,0(r4) 
 > 74:    fmuls   f6,f5,f9 
 > 78:    fadds   f5,f8,f9 
 r 7c:    stw     r3,0x38(r1) 
 > 80:    fmuls   f7,f7,f9 
 > 84:    stw     r0,0x3c(r1) 
 > 88:    fmadds  f5,f6,f9,f5 
 > 8c:    lwz     r0,8(r4) 
 > 90:    fsubs   f29,f4,f3 
 > 94:    fmadds  f2,f9,f7,f5 
 > 98:    stw     r0,0x40(r1) 
 > 9c:    fmuls   f1,f28,f28 
 > a0:    fmuls   f0,f27,f27 
 > a4:    fdivs   f30,f8,f2 
 > a8:    fmadds  f1,f29,f29,f1 
 > ac:    fcmpo   cr0,f1,f0 
 > b0:    ble     e4 ~> 
 > b4:    bl      sqrtf 
 > b8:    xoris   r0,r3,0x8000 
 > bc:    lfd     f1,@16(0) 
 > c0:    stw     r0,0x4c(r1) 
 > c4:    lis     r0,0x4330 
 > c8:    stw     r0,0x48(r1) 
 > cc:    lfd     f0,0x48(r1) 
 > d0:    fsubs   f0,f0,f1 
 > d4:    fdivs   f1,f29,f0 
 > d8:    fdivs   f0,f28,f0 
 > dc:    fmuls   f29,f27,f1 
 > e0:    fmuls   f28,f27,f0 
 r e4: ~> lfs     f0,0(r29) 
 > e8:    fsubs   f0,f0,f29 
 > ec:    stfs    f0,0(r30) 
 r f0:    lfs     f0,4(r29) 
 | f4:    fsubs   f0,f0,f28 
 r f8:    stfs    f0,4(r30) 
 r fc:    lfs     f2,0(r31) 
 r 100:    lfs     f0,4(r31) 
 > 104:    fmadds  f1,f31,f29,f2 
 > 108:    lfs     f6,@11(0) 
 > 10c:    fmadds  f0,f31,f28,f0 
 > 110:    fmuls   f3,f6,f1 
 > 114:    fmuls   f4,f6,f0 
 > 118:    fnmsubs f0,f31,f3,f2 
 | 11c:    fadds   f1,f28,f4 
 | 120:    fadds   f3,f29,f3 
 | 124:    fmuls   f0,f30,f0 
 r 128:    stfs    f0,0(r31) 
 r 12c:    lfs     f0,4(r31) 
 > 130:    fnmsubs f0,f31,f4,f0 
 > 134:    fmuls   f0,f30,f0 
 | 138:    stfs    f0,4(r31) 
 r 13c:    lfs     f0,4(r30) 
 > 140:    lfs     f2,0(r30) 
 > 144:    fmadds  f0,f30,f1,f0 
 > 148:    lfs     f7,0x3c(r1) 
 > 14c:    lfs     f1,4(r29) 
 > 150:    fmadds  f3,f30,f3,f2 
 > 154:    lfs     f5,0x38(r1) 
 > 158:    lfs     f4,0(r29) 
 > 15c:    fsubs   f2,f7,f1 
 > 160:    fsubs   f1,f0,f7 
 > 164:    lfs     f0,@14(0) 
 > 168:    fsubs   f4,f5,f4 
 > 16c:    fsubs   f3,f3,f5 
 > 170:    fmuls   f1,f2,f1 
 > 174:    fmadds  f1,f4,f3,f1 
 > 178:    fcmpo   cr0,f1,f0 
 > 17c:    ble     198 ~> 
 > 180:    fsubs   f1,f5,f5 
 > 184:    fsubs   f0,f7,f7 
 > 188:    fdivs   f1,f1,f6 
 > 18c:    fdivs   f0,f0,f6 
 > 190:    stfs    f1,0(r31) 
 > 194:    stfs    f0,4(r31) 
 | 198: ~> lwz     r0,0x8c(r1) 
 | 19c:    lfd     f31,0x80(r1) 
 | 1a0:    lfd     f30,0x78(r1) 
 | 1a4:    lfd     f29,0x70(r1) 
 | 1a8:    lfd     f28,0x68(r1) 
 | 1ac:    lfd     f27,0x60(r1) 
 | 1b0:    lwz     r31,0x5c(r1) 
 r 1b4:    lwz     r30,0x58(r1) 
 r 1b8:    lwz     r29,0x54(r1) 
 i 1bc:    addi    r1,r1,0x88 
   1c0:    mtlr    r0 
   1c4:    blr 