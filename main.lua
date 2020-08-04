addonName = "PajMarker"
PajMarker = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

local version = GetAddOnMetadata(addonName, "Version") or 9999;

function PajMarker:OnInitialize()
    self.libs = {
        AceGUI = LibStub("AceGUI-3.0"),
        AceSerializer = LibStub("AceSerializer-3.0"),
    }

    self:InitializeChatCommands()

    self:InitializeEvents()

    self.triggers = {}
    self.list = {}
    self.window = nil
    self.session = {}

    self.currentList = ""

    local defaults = {
        profile = {
            enabled = true,
            resetOnListChange = false,
        }
    }
    self.db = LibStub("AceDB-3.0"):New("DB", defaults)

    local options = {
        name = addonName,
        handler = self,
        type = 'group',
        args = {
            general = {
                name = "General",
                type = 'group',
                args = {
                    __description = {
                        type = 'description',
                        name = 'This addon aims to make life easier for raid leaders or whoever is responsible for marking targets in a raid. It gives a way for the user to keep lists of targets and their desired marks, and automatically assign those marks when the user hovers over one of those targets.',
                        order = 1,
                    },
                    enabled = {
                        type = 'toggle',
                        name = 'Enabled',
                        desc = 'Enables the marking of units',
                        set = function(info, val) PajMarker.db.profile.enabled = val; PajMarker:RefreshConfig() end,
                        get = function(info) return PajMarker.db.profile.enabled end,
                        width = "full",
                        order = 10,
                    },
                    resetOnListChange = {
                        type = 'toggle',
                        name = 'Reset session on list change',
                        desc = 'Reset the session automatically whenever the list is changed',
                        set = function(info, val) PajMarker.db.profile.resetOnListChange = val end,
                        get = function(info) return PajMarker.db.profile.resetOnListChange end,
                        width = "full",
                        order = 20,
                    },
                    configureLists = {
                        type = 'execute',
                        name = 'Configure lists',
                        func = "ConfigureLists",
                        order = 30,
                    }
                }
            },
            lists = {
                name = "Lists",
                type = "input",
                hidden = true,
            }
        }
    }

    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options, nil)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName, nil, "general")
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "Profile", addonName, "profile")

    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.db.RegisterCallback(self, "OnDatabaseReset", "RefreshConfig")
end

function PajMarker:OnEnable()
    self:RefreshConfig()
end

function PajMarker:RefreshConfig()
    if self.db.profile.enabled then
        self:RegisterEvents()
    else
        self:UnregisterEvents()
    end

    if self.db.profile.lists then
        success, self.lists = self.libs.AceSerializer:Deserialize(self.db.profile.lists)
    else
        self.lists = {}
    end

    self.triggers = {}

    for listName, list in pairs(self.lists) do
        for mobName in pairs(list) do
            self.triggers[mobName] = listName
        end
    end
end

function PajMarker:ConfigureLists()
    self:ShowGUI()
end

function PajMarker:TryMarkUnit(unit)
    local unitGuid, unitName = UnitGUID(unit), GetUnitName(unit)
    if unitName == nil or unitGuid == nil then
        -- Removed target
        return
    end

    local list = self.lists[self.currentList]

    if list == nil then
        -- No list has been chosen
        -- List can be chosen with /pm list NAME
        return
    end

    local currentTarget = GetRaidTargetIndex(unit)

    -- Have we already marked this unit in this session?
    if self.session[unitGuid] ~= nil then
        -- self:Print("Already marked guid")
        return
    end

    -- Does this unit have a desired marker?
    if list[unitName] == nil then
        return
    end

    if self.session["usedMarks"] == nil then
        self.session["usedMarks"] = {}
    end

    local markerIndex = self.session[unitName] or 1
    local marker = nil
    while markerIndex ~= nil do
        marker = list[unitName][markerIndex]
        if (marker ~= nil or markerIndex > 8) and self.session["usedMarks"][marker] ~= true then
            -- We've run out potential markers, or hit a marker
            break
        end

        markerIndex = markerIndex + 1
    end

    if marker == nil then
        -- self:Print("No marker for unit found")
        return
    end

    if self.session["usedMarks"][marker] == true then
        -- We (or someone else) has already used this mark
        -- self:Print("Already used mark " .. marker)
        return
    end

    self.session["usedMarks"][marker] = true

    local currentMarker = GetRaidTargetIndex(unit)
    if currentMarker ~= marker then
        SetRaidTarget(unit, marker)
        self.session["mark"..marker] = true
    end

    self.session[unitName] = markerIndex + 1
    self.session[unitGuid] = true
end

-- Try to switch to the list containing the given unit
-- UNDEFINED BEHAVIOUR: If a unit is contained within multiple lists, the list that will be chosen is ??
function PajMarker:TrySwitchList(unitName)
    local trigger = self.triggers[unitName]

    if trigger ~= nil and trigger ~= self.currentList then
        self:Print("Switching to list " .. trigger)
        self.currentList = trigger

        if self.db.profile.resetOnListChange then
            self:ResetSession()
        end
    end
end

function PajMarker:ResetSession()
    self.session = {}
    self:Print("Session has been reset")
end
