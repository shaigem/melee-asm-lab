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

task hitboxext, "Build the hitbox extension code":
    exec "nim r ./" & srcDir & "/hitbox/hitboxext"