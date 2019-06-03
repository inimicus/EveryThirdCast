-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Main.lua
-- -----------------------------------------------------------------------------
ETC             = {}
ETC.name        = "EveryThirdCast"
ETC.version     = "0.0.4"
ETC.dbVersion   = 1
ETC.slash       = "/etc"
ETC.prefix      = "[ETC] "

local EM = EVENT_MANAGER
local SC = SLASH_COMMANDS

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
ETC.debugMode = 0
-- -----------------------------------------------------------------------------

function ETC:Trace(debugLevel, ...)
    if debugLevel <= ETC.debugMode then
        local message = zo_strformat(...)
        d(ETC.prefix .. message)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function ETC.Initialize(event, addonName)
    if addonName ~= ETC.name then return end

    if GetUnitClassId("player") ~= 5 then
        ETC:Trace(1, "Non-Necromancer class detected, aborting addon initialization.")
        EM:UnregisterForEvent(ETC.name, EVENT_ADD_ON_LOADED)
        return
    end

    ETC:Trace(1, "ETC Loaded")
    EM:UnregisterForEvent(ETC.name, EVENT_ADD_ON_LOADED)

    ETC.preferences = ZO_SavedVars:NewAccountWide("EveryThirdCastVariables", ETC.dbVersion, nil, ETC.Defaults.Get())

    -- Use saved debugMode value if the above value has not been changed
    if ETC.debugMode == 0 then
        ETC.debugMode = ETC.preferences.debugMode
        ETC:Trace(1, "Setting debug value to saved: <<1>>", ETC.preferences.debugMode)
    end

    SC[ETC.slash] = ETC.UI.SlashCommand

    ETC.Settings.Init()
    ETC.Tracking.OnHotbarsUpdated(nil, false)
    ETC.Tracking.GetBuffs()
    ETC.Tracking.RegisterHotbarEvents()
    ETC.UI.Setup()

    ETC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(ETC.name, EVENT_ADD_ON_LOADED, ETC.Initialize)

