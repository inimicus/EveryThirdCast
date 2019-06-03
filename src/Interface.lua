-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Interface.lua
-- -----------------------------------------------------------------------------

ETC.UI = {}

local U = ETC.UI
local Abilities = ETC.Abilities

local WM = WINDOW_MANAGER
local AM = ANIMATION_MANAGER

local slotAnimations = {}

-- -----------------------------------------------------------------------------
-- UI Functions
-- -----------------------------------------------------------------------------

local function LoadColorPrefs()
    for element, _ in pairs(ETC.UI.Contexts) do
        ETC.UI.UpdateColor(element, ETC.preferences[element])
    end
end

local function LoadShowFrame()
    ETC.UI.Contexts["frame"]:SetHidden(not ETC.preferences.showFrame)
end

local function LoadLockedState()
    ETC.UI.Contexts["animation"]:SetMovable(ETC.preferences.unlocked)
end

local function LoadPosition()
    local left = ETC.preferences.positionLeft
    local top = ETC.preferences.positionTop
    local context = ETC.UI.Contexts["animation"]

    ETC:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)

    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition()
    local container = ETC.UI.Contexts.animation
    local top   = container:GetTop()
    local left  = container:GetLeft()

    ETC:Trace(2, "Saving position - Left: " .. left .. " Top: " .. top)

    ETC.preferences.positionLeft = left
    ETC.preferences.positionTop  = top
end


local function DrawDisplayForID(ability)

    local set = Cool.Data.Sets[key];
    local container = WM:GetControlByName(key .. "_Container")

    -- Enable display
    if set.enabled then

        local saved = Cool.preferences.sets[key]

        -- Draw UI and create context if it doesn't exist
        if container == nil then
            Cool:Trace(2, "Drawing: <<1>>", key)

            local c = WM:CreateTopLevelWindow(key .. "_Container")
            c:SetClampedToScreen(true)
            c:SetDimensions(scaleBase, scaleBase)
            c:ClearAnchors()
            c:SetMouseEnabled(true)
            c:SetAlpha(1)
            c:SetMovable(Cool.preferences.unlocked)
            if Cool.HUDHidden then
                c:SetHidden(true)
            else
                c:SetHidden(false)
            end
            c:SetScale(saved.size / scaleBase)
            c:SetHandler("OnMoveStop", function(...) SavePosition(key) end)

            local r = WM:CreateControl(key .. "_Texture", c, CT_TEXTURE)
            r:SetTexture(set.texture)
            r:SetDimensions(scaleBase, scaleBase)
            r:SetAnchor(CENTER, c, CENTER, 0, 0)

            if set.showFrame then
                local f = WM:CreateControl(key .. "_Frame", c, CT_TEXTURE)
                if set.procType == "passive" then
                    -- Gamepad frame is pretty, but looks bad scaled up
                    --f:SetTexture("/esoui/art/miscellaneous/gamepad/gp_passiveframe_128.dds")
                    f:SetTexture("/esoui/art/actionbar/passiveabilityframe_round_up.dds")

                    -- Add 5 to make the frame sit where it should.
                    f:SetDimensions(scaleBase + 5, scaleBase + 5)
                else
                    f:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
                    f:SetDimensions(scaleBase, scaleBase)
                end
                f:SetAnchor(CENTER, c, CENTER, 0, 0)
            end

            local l = WM:CreateControl(key .. "_Label", c, CT_LABEL)
            l:SetAnchor(CENTER, c, CENTER, 0, 0)
            l:SetColor(1, 1, 1, 1)
            l:SetFont("$(MEDIUM_FONT)|36|soft-shadow-thick")
            l:SetVerticalAlignment(TOP)
            l:SetHorizontalAlignment(RIGHT)
            l:SetPixelRoundingEnabled(true)

            SetPosition(key, saved.x, saved.y)

        -- Reuse context
        else
            if not Cool.HUDHidden then
                container:SetHidden(false)
            end
        end

    -- Disable display
    else
        if container ~= nil then
            container:SetHidden(true)
        end
    end

    Cool:Trace(2, "Finished DrawUI()")
end

function ETC.UI.Setup()
    ETC:Trace(2, "Finished UI Setup")
end

function ETC.UI.UpdateColor(element, color)

    ETC:Trace(2, "<<1>>: R <<2>> G <<3>> B <<4>> A <<5>>", element, color.r, color.g, color.b, color.a)

    if element == "animation" then
        ETC.UI.Contexts[element]:SetFillColor(color.r, color.g, color.b, color.a)
    else
        ETC.UI.Contexts[element]:SetColor(color.r, color.g, color.b, color.a)
    end

end

function ETC.UI.OnMoveStop()
    ETC:Trace(1, "Moved")
    SavePosition()
end

function ETC.UI.UpdateStacks(abilityId, stackCount, isReady)
    ETC:Trace(1, "<<1>>: Stack #<<2>> Ready <<3>>", GetAbilityName(abilityId), stackCount, tostring(isReady))

    local skillId = Abilities.Reverse[abilityId]
    local list = Abilities.List

    list[skillId].isReady = isReady

    if isReady then

        -- Check that the proc bar is the active bar before animating
        if list[skillId].slot ~= nil then
            PlaySound(SOUNDS["DEATH_RECAP_KILLING_BLOW_SHOWN"])
            PlaySound(SOUNDS["DEATH_RECAP_KILLING_BLOW_SHOWN"])
            --LUIE.CombatInfo.PlayProcAnimations(list[skillId].slot)
            ETC.UI.Animate(skillId)
        else
            --d("Slot: " .. list[skillId].slot)
        end
    else 
        ETC.UI.Stop(skillId)
    end

end

-- Shamelessly stolen from LUIE
function ETC.UI.Animate(skillId)
    local list = Abilities.List[skillId]
    if not list.animation then
        local actionButton = ZO_ActionBar_GetButton(list.slot)
        local procLoopTexture = WM:CreateControl("$(parent)Loop_LUIE", actionButton.slot, CT_TEXTURE)
        procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetTexture("/esoui/art/actionbar/abilityhighlight_mage_med.dds")
        procLoopTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
        procLoopTexture:SetDrawLevel(2)
        procLoopTexture:SetHidden(true)

        local procLoopTimeline = AM:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
        procLoopTimeline.procLoopTexture = procLoopTexture

        procLoopTimeline.onPlay = function(self) self.procLoopTexture:SetHidden(false) end
        procLoopTimeline.onStop = function(self) self.procLoopTexture:SetHidden(true) end

        procLoopTimeline:SetHandler("OnPlay", procLoopTimeline.onPlay)
        procLoopTimeline:SetHandler("OnStop", procLoopTimeline.onStop)

        list.animation = procLoopTimeline
    else
        if not list.animation:IsPlaying() then
            list.animation:PlayFromStart()
        end
    end
end

function ETC.UI.Stop(skillId)
    local list = Abilities.List[skillId]
    if list.animation and list.animation:IsPlaying() then
        list.animation:Stop()
    end
end

function ETC.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(ETC.prefix .. "Setting debug level to 0 (Off)")
        ETC.debugMode = 0
        ETC.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(ETC.prefix .. "Setting debug level to 1 (Low)")
        ETC.debugMode = 1
        ETC.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(ETC.prefix .. "Setting debug level to 2 (Medium)")
        ETC.debugMode = 2
        ETC.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(ETC.prefix .. "Setting debug level to 3 (High)")
        ETC.debugMode = 3
        ETC.preferences.debugMode = 3

    -- Default ----------------------------------------------------------------
    else
        d(ETC.prefix .. "Command not recognized!")
    end
end

