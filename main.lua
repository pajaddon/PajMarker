local addonName, addon = ...

addon.db = {
    enabled = false,
}

local frame, events = CreateFrame("FRAME"), {};

local addonPrefix = "pm_";

local currentList = "";

local session = {};

-- TODO: Save last "currentList" value

local triggers = {};

for listName in pairs(lists) do
    for mobName in pairs(lists[listName]) do
        triggers[mobName] = listName;
    end
end

function HandleAddonMessage(message, sender)
    if session["usedMarks"] == nil then
        session["usedMarks"] = {};
    end

    session["usedMarks"][message] = true;

    -- print(prefix)
    print(message)
    -- print(distribution)
    -- print(sender)
end

-- function events:CHAT_MSG_ADDON(prefix, message, distribution, sender)
--     if prefix ~= addonPrefix then
--         return
--     end
-- 
--     if distribution ~= "RAID" then
--         return
--     end
-- 
--     HandleAddonMessage(message, sender)
-- end

function events:ADDON_LOADED(arg1)
    if arg1 ~= addonName then
        return
    end

    addon.db.enabled = Enabled
end

function events:PLAYER_LOGOUT()
    Enabled = addon.db.enabled
end

function NotifyRaid(marker)
    -- ChatThrottleLib:SendAddonMessage("ALERT", addonPrefix, tostring(marker), "raid")
end

function TryMarkUnit(unit)
    local unitGuid, unitName = UnitGUID(unit), GetUnitName(unit);
    if unitName == nil or unitGuid == nil then
        -- Removed target
        return
    end

    local list = lists[currentList];

    if list == nil then
        -- No list has been chosen
        -- List can be chosen with /pm list NAME
        return
    end

    local currentTarget = GetRaidTargetIndex(unit)

    -- Have we already marked this unit in this session?
    if session[unitGuid] ~= nil then
        -- print("Already marked guid")
        return
    end

    -- Does this unit have a desired marker?
    if list[unitName] == nil then
        return
    end

    if session["usedMarks"] == nil then
        session["usedMarks"] = {};
    end

    local markerIndex = session[unitName] or 1;
    local marker = nil
    while markerIndex ~= nil do
        marker = list[unitName][markerIndex]
        if (marker ~= nil or markerIndex > 8) and session["usedMarks"][marker] ~= true then
            -- We've run out potential markers, or hit a marker
            break
        end

        markerIndex = markerIndex + 1
    end

    if marker == nil then
        -- print("No marker for unit found")
        return
    end

    if session["usedMarks"][marker] == true then
        -- We (or someone else) has already used this mark
        -- print("Already used mark " .. marker)
        return
    end

    session["usedMarks"][marker] = true;

    local currentMarker = GetRaidTargetIndex(unit)
    if currentMarker ~= marker then
        SetRaidTarget(unit, marker)
        session["mark"..marker] = true

        NotifyRaid(marker)
        -- print("Set raid marker to " .. unitName .. " - Marking it with " .. marker)
    end

    session[unitName] = markerIndex + 1
    session[unitGuid] = true
end

local function TrySwitchList(unitName)
    local trigger = triggers[unitName];

    if trigger ~= nil and trigger ~= currentList then
        print("Switching to list " .. trigger)
        currentList = trigger
    end
end

function events:PLAYER_TARGET_CHANGED()
    local unitName = GetUnitName("target");
    if unitName == nil then
        return
    end

    if UnitIsDead("target") then
        return
    end

    TrySwitchList(unitName)

    TryMarkUnit("target")
end

function events:UPDATE_MOUSEOVER_UNIT()
    if UnitIsDead("mouseover") then
        return
    end

    TryMarkUnit("mouseover")
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...);
end);
for k, v in pairs(events) do
    frame:RegisterEvent(k);
end

frame.name = addonName
addon.frame = frame

local function ResetUsage()
    print(' /pm reset - reset the current session')
end

local function Usage()
    print('PajMarker usage:')
    print(' /pm help - show this help message')
    ResetUsage()
end

local function ResetSession()
    session = {};
    print("Session has been reset");
end

local function PMReset(commands, command_i)
    ResetSession()
end

local function PMClear(commands, command_i)
    SetRaidTarget("player", 1)
    SetRaidTarget("player", 2)
    SetRaidTarget("player", 3)
    SetRaidTarget("player", 4)
    SetRaidTarget("player", 5)
    SetRaidTarget("player", 6)
    SetRaidTarget("player", 7)
    SetRaidTarget("player", 8)
    SetRaidTarget("player", 0)
end

local function PMList(commands, command_i)
    currentList = commands[command_i] or ""
    print("Current list changed to " .. currentList)
    ResetSession()
end

local function PMDebug(commands, command_i)
    --
end

local function PM(msg, editbox)
    commands = split(msg, " ")
    command_i = 1

    if commands[command_i] == "reset" then
        PMReset(commands, command_i + 1)
        return
    end

    if commands[command_i] == "clear" then
        PMClear(commands, command_i + 1)
        return
    end

    if commands[command_i] == "list" then
        PMList(commands, command_i + 1)
        return
    end

    if commands[command_i] == "debug" then
        PMDebug(commands, command_i + 1)
        return
    end

    Usage()
end

SLASH_PM1 = '/pm'

SlashCmdList["PM"] = PM

-- C_ChatInfo.RegisterAddonMessagePrefix(addonPrefix);
