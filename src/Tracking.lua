-- -----------------------------------------------------------------------------
-- Every Third Cast
-- Author:  g4rr3t
-- Created: June 2, 2019
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

ETC.Tracking = {}

local T = ETC.Tracking
local Abilities = ETC.Abilities

local EM = EVENT_MANAGER

local function GetSlottedPosition(abilityId)
    for x = 3, 7 do
        local slotPrimary = GetSlotBoundId(x, HOTBAR_CATEGORY_PRIMARY)
        if slotPrimary == abilityId then
            return HOTBAR_CATEGORY_PRIMARY, x
        end

        local slotBackup = GetSlotBoundId(x, HOTBAR_CATEGORY_BACKUP)
        if slotBackup == abilityId then
            return HOTBAR_CATEGORY_BACKUP, x
        end
    end

    -- No skill matching ID slotted
    return nil
end

function T.RegisterEventForId(abilityId)
    ETC:Trace(1, "Registering event for <<1>>", GetAbilityName(abilityId))
    EM:RegisterForEvent(ETC.name .. abilityId, EVENT_EFFECT_CHANGED, T.OnEffectChanged)
    EM:AddFilterForEvent(ETC.name .. abilityId, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, abilityId,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function T.UnregisterEventForId(abilityId)
    ETC:Trace(1, "Unregistering event for <<1>>", GetAbilityName(abilityId))
    EM:UnregisterForEvent(ETC.name .. abilityId, EVENT_EFFECT_CHANGED)
end

function T.OnSlotUpdated(eventCode, slotNum, allUpdated)

    -- Reset slots in list
    for skillId, properties in pairs(Abilities.List) do
        properties.slot = nil
        ETC.UI.Stop(skillId)
    end

    local boundId = GetSlotBoundId(slotNum)
    local ability = Abilities.List[boundId]

    -- If it's a tracked ability
    if ability ~= nil then
        ability.slot = slotNum

        -- Enable tracking if it isn't already
        if not ability.enabled then
            ability.enabled = true
            T.RegisterEventForId(ability.abilityId)
        end

        if ability.isReady then
            PlaySound(SOUNDS["DEATH_RECAP_KILLING_BLOW_SHOWN"])
            PlaySound(SOUNDS["DEATH_RECAP_KILLING_BLOW_SHOWN"])
            ETC.UI.Animate(boundId)
        end
    end

end

function T.OnHotbarsUpdated(eventCode, didBarSwap)
    for i = 3, 7 do
        T.OnSlotUpdated(eventCode, i, true)
    end
end

function T.GetBuffs()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        -- Check for a buff we care about
        for skillId, properties in pairs(Abilities.List) do
            if abilityId == properties.abilityId then
                -- Send update
                T.OnEffectChanged(0, EFFECT_RESULT_UPDATED, buffSlot, buffName, unitTag, timeStarted, timeEnding, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, 0, abilityId, castByPlayer)
            end
        end

    end
end

function T.RegisterHotbarEvents()
    EM:RegisterForEvent(ETC.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, T.OnHotbarsUpdated)
    EM:RegisterForEvent(ETC.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, T.OnHotbarsUpdated)
    EM:RegisterForEvent(ETC.name, EVENT_ACTION_SLOT_UPDATED, T.OnSlotUpdated)
end

function T.RegisterEventsForEnabled()
    ETC:Trace(2, "Registering events")

    for skillId, properties in pairs(Abilities.List) do
        if properties.enabled then
            T.RegisterEventForId(properties.abilityId)
        else
            ETC:Trace(1, "Skipping register for <<1>>", GetAbilityName(properties.abilityId))
        end
    end

end

function T.UnregisterEventsForEnabled()
    ETC:Trace(2, "Unregistering events")

    for abilityId, properties in pairs(Abilities.List) do
        if not properties.enabled then
            T.UnregisterEventForId(abilityId)
        else
            ETC:Trace(1, "Skipping unregister for <<1>>", GetAbilityName(abilityId))
        end
    end
end


function T.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    ETC:Trace(3, "<<1>> (<<2>>)", effectName, effectAbilityId)

    -- Ignore non-stacks
    if not stackCount then return end

    -- Ignore third stack
    if stackCount == 3 and changeType == EFFECT_RESULT_UPDATED then return end

    ETC:Trace(2, "Stack for Ability ID: <<1>>", effectAbilityId)

    if changeType == EFFECT_RESULT_FADED then
        ETC:Trace(2, "Faded on stack #<<1>>", stackCount)
        -- Override stacks to zero on use
        ETC.UI.UpdateStacks(effectAbilityId, 0, false)
    elseif changeType == EFFECT_RESULT_UPDATED and stackCount == 2 then
        ETC:Trace(2, "Ready on stack #<<1>>", stackCount)
        ETC.UI.UpdateStacks(effectAbilityId, stackCount, true)
    else
        ETC:Trace(2, "Gained Stack #<<1>>", stackCount)
        ETC.UI.UpdateStacks(effectAbilityId, stackCount, false)
    end

end

