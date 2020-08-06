-- Keep a list of events we are interested in so we can easily register and unregister all of them
local events = {"UPDATE_MOUSEOVER_UNIT", "PLAYER_TARGET_CHANGED"}

function PajMarker:InitializeEvents()
end

function PajMarker:RegisterEvents()
    for i, eventName in ipairs(events) do
        self:RegisterEvent(eventName)
    end
end

function PajMarker:UnregisterEvents()
    for i, eventName in ipairs(events) do
        self:UnregisterEvent(eventName)
    end
end

-- Handle the event that is triggered when the user hovers over a unit
function PajMarker:UPDATE_MOUSEOVER_UNIT()
    if UnitIsDead("mouseover") then
        return
    end

    self:TryMarkUnit("mouseover")
end

function PajMarker:PLAYER_TARGET_CHANGED()
    local unitName = GetUnitName("target")
    if unitName == nil then
        return
    end

    if UnitIsDead("target") then
        return
    end

    self:TrySwitchList(unitName)

    self:TryMarkUnit("target")
end
