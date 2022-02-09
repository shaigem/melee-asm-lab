# Package

version       = "0.1.0"
author        = "Ronnie Tran"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["scripts"]


# Dependencies

requires "nim >= 1.6.0"
requires "geckon >= 0.1.0"

task generate, "generate all of the codes":
    exec "nim r ./" & srcDir & "/fighters/boss/vibrateonhit"
    exec "nim r ./" & srcDir & "/fighters/boss/controlallports"
    exec "nim r ./" & srcDir & "/fighters/boss/improvementmod/handsimprovement"
    exec "nim r ./" & srcDir & "/hitbox/hitboxext"
    exec "nim r ./" & srcDir & "/hitbox/autolink367"
    exec "nim r ./" & srcDir & "/hitbox/eight/eighthitbox"
    exec "nim r ./" & srcDir & "/common/dataexpansion"