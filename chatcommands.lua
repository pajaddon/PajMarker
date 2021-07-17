local addonName = ...

local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end
    return Table
end

function PajMarker:InitializeChatCommands()
    -- Register /pm to call HandlePM using AceConsole-3.0
    self:RegisterChatCommand("pm", "HandlePM")

    -- Register chat handlers for each "sub command"
    self.chatHandlers = {
        config = {
            func = "PMHandleConfig",
            usage = "Open the addon config dialog",
        },
        lists = {
            func = "PMHandleLists",
            usage = "Configure lists",
        },
        list = {
            func = "PMHandleList",
            usage = "Change list (e.g. /pm list bwl technician trash)",
        },
        reset = {
            func = "PMHandleReset",
            usage = "Reset the current session",
        },
        clear = {
            func = "PMHandleClear",
            usage = "Clear all raid markers currently assigned to units",
        },
        usage = {
            func = "PMHandleUsage",
            usage = "Shows this help text",
        },
        help = {
            func = "PMHandleUsage",
            hidden = true,
        },
        export = {
            func = "ExportLists",
            usage = "Export lists to a string",
        },
        import = {
            func = "ImportLists",
            usage = "Import lists from a string",
        },
    }
end

function PajMarker:PMHandleUsage(subCommandName)
    if subCommandName ~= nil and type(subCommandName) == "string" then
        self:Print("Error: No sub command with the key '" .. subCommandName .. "' exists")
    end
    self:Print('PajMarker usage:')
    for key, value in pairs(self.chatHandlers) do
        if not value.hidden then
            self:Print(' /pm ' .. key .. ' - ' .. value.usage)
        end
    end
end

function PajMarker:PMReset()
    self:ResetSession()
end

-- Clear raid targets by setting all targets on yourself
function PajMarker:PMHandleClear()
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

function PajMarker:PMHandleConfig()
    InterfaceOptionsFrame_OpenToCategory(addonName)
    InterfaceOptionsFrame_OpenToCategory(addonName) -- need a second time cuz this is bugged KKona
end

function PajMarker:PMHandleLists()
    self:ConfigureLists()
end

function PajMarker:PMHandleList(commands, command_i)
    local listName = commands[command_i]
    command_i = command_i + 1
    local ll

    repeat
        ll = commands[command_i]
        if ll ~= nil then
            listName = listName .. " " .. ll
        end
        command_i = command_i + 1
    until (ll == nil)

    if listName == nil then
        self:PMHandleUsage()
        return
    end
    if not self:SwitchList(listName) then
        self:Print("No list named " .. listName .. " exists")
    end
end

function PajMarker:PMHandleReset()
    self:ResetSession()
end

function PajMarker:HandlePM(msg, editbox)
    local commands = split(msg, " ")
    local command_i = 1
    local subCommandName = commands[command_i]

    if subCommandName == nil then
        return self:PMHandleUsage(nil)
    end

    local subCommand = self.chatHandlers[subCommandName]
    if subCommand ~= nil then
        self[subCommand.func](self, commands, command_i + 1)
        return
    end

    self:PMHandleUsage(subCommandName)
end
