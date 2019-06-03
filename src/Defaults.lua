-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

ETC.Defaults = {}

local defaults = {
    debugMode = 0,
    positionLeft = 400,
    positionTop = 400,
    unlocked = true,
}

function ETC.Defaults.Get()
    return defaults
end
