-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Abilities.lua
-- -----------------------------------------------------------------------------

ETC.Abilities = {}

local RUINOUS_SCYTHE_ABILITY_ID = 125749
local RUINOUS_SCYTHE_SKILL_ID = 118226
local RICOCHET_SKULL_ABILITY_ID = 117638
--local RICOCHET_SKULL_SKILL_ID = 117637
local RICOCHET_SKULL_SKILL_ID = 123719

ETC.Abilities.List = {
    [RUINOUS_SCYTHE_SKILL_ID] = {
        abilityId = RUINOUS_SCYTHE_ABILITY_ID,
        enabled = false,
        isReady = false,
        slot = nil,
        animation = nil,
    },
    [RICOCHET_SKULL_SKILL_ID] = {
        abilityId = RICOCHET_SKULL_ABILITY_ID,
        enabled = false,
        isReady = false,
        slot = nil,
        animation = nil,
    },
}

ETC.Abilities.Reverse = {
    [RUINOUS_SCYTHE_ABILITY_ID] = RUINOUS_SCYTHE_SKILL_ID,
    [RICOCHET_SKULL_ABILITY_ID] = RICOCHET_SKULL_SKILL_ID,
}

