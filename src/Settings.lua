-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Settings.lua
-- -----------------------------------------------------------------------------

ETC.Settings = {}

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Every Third Cast",
    displayName = "Every Third Cast",
    author      = "g4rr3t",
    version     = ETC.version,
    registerForRefresh  = true,
}

-- -----------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------

-- Locked State
local function ToggleLocked(control)
    ETC.preferences.unlocked = not ETC.preferences.unlocked
    ETC.UI.Contexts['animation']:SetMovable(ETC.preferences.unlocked)
    if ETC.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Get/Set
local function GetSaved(element)
    local saved = ETC.preferences[element]
    if type(saved) == "table" then
        return saved.r,
            saved.g,
            saved.b,
            saved.a
    else
        return saved
    end
end

local function SetSaved(element, value)
    ETC.preferences[element] = value
end

-- Color Options
local function SetColor(element, r, g, b, a)
    local color = {
        r = r,
        g = g,
        b = b,
        a = a,
    }
    ETC.UI.UpdateColor(element, color)
    SetSaved(element, color)
end

-- Frame Options
local function SetShowFrame(value)
    local isHidden = not value
    ETC.UI.Contexts['frame']:SetHidden(isHidden)
end

-- -----------------------------------------------------------------------------
-- Create Settings
-- -----------------------------------------------------------------------------

local optionsTable = {
    {
        type = "button",
        name = function() if ETC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    {
        type = "header",
        name = "Display Options",
        width = "full",
    },
    {
        type = "colorpicker",
        name = "Number Color",
        tooltip = "",
        getFunc = function() return GetSaved('count') end,
        setFunc = function(r, g, b, a) SetColor('count', r, g, b, a) end,
    },
    {
        type = "colorpicker",
        name = "Animation Color",
        tooltip = "",
        getFunc = function() return GetSaved('animation') end,
        setFunc = function(r, g, b, a) SetColor('animation', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Show Frame",
        tooltip = "",
        getFunc = function() return GetSaved('showFrame') end,
        setFunc = function(value) SetSaved('showFrame', value) SetShowFrame(value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        name = "Frame Color",
        disabled = function() return not GetSaved('showFrame') end,
        tooltip = "",
        getFunc = function() return GetSaved('frame') end,
        setFunc = function(r, g, b, a) SetColor('frame', r, g, b, a) end,
    },
}

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function ETC.Settings.Init()
    LAM:RegisterAddonPanel(ETC.name, panelData)
    LAM:RegisterOptionControls(ETC.name, optionsTable)

    ETC:Trace(2, "Finished Settings Init()")
end

-- -----------------------------------------------------------------------------
-- Settings Upgrade Function
-- -----------------------------------------------------------------------------

function ETC.Settings.Upgrade()
    -- FPO
end

