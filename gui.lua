function PajMarker:ShowGUI()
    if self.window ~= nil then
        self:Print("GUI already open :)")
        return
    end

    local AceGUI = self.libs.AceGUI

    self.window = AceGUI:Create("Window")
    self.window:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        self.window = nil
    end)
    self.window:SetTitle(addonName .. "List Config")
    self.window:SetFullHeight(true)
    self.window:SetStatusText("XDDDDDDDDDd")
    self.window:SetLayout("Flow")

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetTitle("Lists")
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetLayout("Flow")

    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")

    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:SetFullHeight(true)
    -- scrollFrame:SetLayout("Flow")

    scrollContainer:AddChild(scrollFrame)

    tabGroup:AddChild(scrollContainer)

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetFullHeight(false)
    buttonGroup:SetFullWidth(true)
    buttonGroup:SetHeight(60)
    buttonGroup:SetLayout("Flow")
    -- buttonGroup:SetFullWidth(true)

    local undoChangesButton = AceGUI:Create("Button")
    undoChangesButton:SetText("Undo all changes")

    local saveChangesButton = AceGUI:Create("Button")
    saveChangesButton:SetText("Save changes and close")

    buttonGroup:AddChild(saveChangesButton)
    buttonGroup:AddChild(undoChangesButton)


    self.window:AddChild(buttonGroup)

    self.window:AddChild(tabGroup)

    local NONE = 0
    local STAR = 1
    local CIRCLE = 2
    local DIAMOND = 3
    local TRIANGLE = 4
    local MOON = 5
    local SQUARE = 6
    local CROSS = 7
    local SKULL = 8

    local add_new_list = "___add-new-list-xd-dont-name-a-list-this-secret-code"

    -- local testList = {};
    -- testList["Death Talon Wyrmkin"] = {DIAMOND, STAR}; -- Sleep targets
    -- testList["Death Talon Captain"] = {TRIANGLE}; -- Kite target
    -- testList["Death Talon Flamescale"] = {CROSS, SQUARE, CIRCLE}; -- DPS target
    -- testList["Death Talon Seether"] = {SKULL, CROSS, SQUARE, CIRCLE}; -- DPS target

    -- local testList2 = {};
    -- testList2["Blackwing Warlock"] = {SKULL, CROSS} -- Melee Focus
    -- testList2["Death Talon Overseer"] = {SQUARE, CIRCLE, CROSS} -- Dragon guy
    -- testList2["Blackwing Spellbinder"] = {STAR,DIAMOND} -- Kite Target
    -- testList2["Blackwing Technician"] = {} -- Kite Target
    -- testList2["Death Talon Wyrmguard"] = {SKULL , CROSS, SQUARE} --Big boys

    -- local testList3 = {};

    local localLists = deepCopy(self.lists)

    -- lists["vael"] = testList;
    -- lists["zg"] = testList3;
    -- lists["labs"] = testList2;

    local originalList = deepCopy(localLists)

    local tabs = {};

    local first = true;

    local firstKey = "";

    local function updateTabs()
        first = true
        firstKey = add_new_list
        tabs = {}
        local numTabs = 0
        for listKey, listValue in pairs(localLists) do
            if first then
                first = false
                firstKey = listKey
            end
            tabs[#tabs+1] = {value=listKey, text=listKey}
            numTabs = numTabs + 1
        end
        tabs[#tabs+1] = {value=add_new_list, text="New..."}

        tabGroup:SetTabs(tabs)
    end

    undoChangesButton:SetCallback("OnClick", function()
        for listKey, listValue in pairs(originalList) do
            self:Print(listKey)
        end
        localLists = deepCopy(originalList)
        updateTabs()
        updateGroup()
    end)

    updateTabs()

    local currentGroup = firstKey

    function refreshGroup()
        local scrollFrameStatus = scrollFrame.status or scrollFrame.localstatus
        local oldScrollValue = scrollFrameStatus.scrollvalue
        scrollFrame:PauseLayout()
        updateGroup()
        scrollFrame:SetScroll(oldScrollValue)
        scrollFrame:ResumeLayout()
        scrollFrame:DoLayout()
    end

    function updateGroup()
        local group = currentGroup
        scrollFrame:ReleaseChildren()
        if group == add_new_list then
            local g = AceGUI:Create("InlineGroup")
            g:SetLayout("Flow")
            g:SetFullWidth(true)
            g:SetFullHeight(true)

            local createNewList = AceGUI:Create("EditBox")
            createNewList:SetLabel("Create new list")
            createNewList:SetCallback("OnEnterPressed", function(_, event, text)
                localLists[text] = {}
                updateTabs()
                tabGroup:SelectTab(text)
            end)
            g:AddChild(createNewList)

            scrollFrame:AddChild(g)
        else
            sort(localLists[group], function(a, b)
                return a > b
            end)
            for mobName, markerList in orderedpairs(localLists[group]) do
                local g = AceGUI:Create("InlineGroup")
                g:SetLayout("Flow")
                g:SetFullWidth(true)
                g:SetTitle(mobName)

                local gEnabled = AceGUI:Create("InlineGroup")
                gEnabled:SetLayout("Flow")
                gEnabled:SetTitle("Enabled (Priority order Left to Right)")
                gEnabled:SetFullWidth(false)

                local dummy = AceGUI:Create("Label")
                dummy:SetWidth(0)

                gEnabled:AddChild(dummy)

                local gDisabled = AceGUI:Create("InlineGroup")
                gDisabled:SetLayout("Flow")
                gDisabled:SetTitle("Disabled")
                gDisabled:SetFullWidth(false)

                local dummy2 = AceGUI:Create("Label")
                dummy2:SetWidth(0)

                gDisabled:AddChild(dummy2)

                local first = true

                local calculatedIcons = deepCopy(AVAILABLE_MARKS)

                for markName, mark in pairs(calculatedIcons) do
                    local score = -1

                    for i, a in ipairs(markerList) do
                        if a == mark.ID then
                            score = i
                            break
                        end
                    end

                    if score == -1 then
                        score = mark.ID * 10
                    end

                    mark.score = score
                end

                sort(calculatedIcons, function(a, b)
                    return a.score < b.score
                end)

                for i, mark in pairs(calculatedIcons) do
                    local icon = AceGUI:Create("Icon")
                    icon:SetImage(mark.Texture)
                    icon:SetImageSize(18, 18)
                    icon:SetWidth(24)

                    -- if score == 10 then
                    --     icon:SetLabel("0")
                    -- else
                    --     icon:SetLabel(score)
                    -- end

                    icon:SetCallback("OnClick", function()
                        local newMarkerList = markerList
                        if mark.score >= 9 then
                            tinsert(newMarkerList, mark.ID)
                        else
                            if mark.score == 1 then
                                tremove(newMarkerList, i)
                            else
                                tremove(newMarkerList, i)
                                tinsert(newMarkerList, i-1, mark.ID)
                            end
                        end

                        localLists[group][mobName] = newMarkerList

                        mark.score = mark.score - 1
                        local scrollFrameStatus = scrollFrame.status or scrollFrame.localstatus
                        local oldScrollValue = scrollFrameStatus.scrollvalue
                        scrollFrame:PauseLayout()
                        updateGroup()
                        scrollFrame:SetScroll(oldScrollValue)
                        scrollFrame:ResumeLayout()
                        scrollFrame:DoLayout()
                    end)

                    if mark.score < 9 then
                        icon:SetLabel(mark.score)
                        gEnabled:AddChild(icon)
                    else
                        gDisabled:AddChild(icon)
                    end
                end

                g:AddChild(gEnabled)
                g:AddChild(gDisabled)

                local deleteMonsterButton = AceGUI:Create("Button")
                deleteMonsterButton:SetText("Delete monster")
                deleteMonsterButton:SetCallback("OnClick", function()
                    localLists[group][mobName] = nil
                        local scrollFrameStatus = scrollFrame.status or scrollFrame.localstatus
                        local oldScrollValue = scrollFrameStatus.scrollvalue
                        self:Print(oldScrollValue)
                        scrollFrame:PauseLayout()
                        updateGroup()
                        scrollFrame:SetScroll(oldScrollValue)
                        scrollFrame:ResumeLayout()
                        scrollFrame:DoLayout()
                end)
                g:AddChild(deleteMonsterButton)
                scrollFrame:AddChild(g)
            end

            local g = AceGUI:Create("InlineGroup")
            g:SetLayout("Flow")
            g:SetFullWidth(true)

            local newMonster = AceGUI:Create("EditBox")
            newMonster:SetLabel("Add new monster")
            newMonster:SetCallback("OnEnterPressed", function(widget, _, mobName)
                localLists[group][mobName] = {}
                widget:SetText("")
                refreshGroup()
                -- self:Print("Add monster :)" .. text)
            end)
            g:AddChild(newMonster)

            local deleteList = AceGUI:Create("Button")
            deleteList:SetText("Delete list")
            deleteList:SetCallback("OnClick", function()
                localLists[group] = nil
                updateTabs()
                tabGroup:SelectTab(firstKey)
            end)
            g:AddChild(deleteList)

            scrollFrame:AddChild(g)
        end
    end

    tabGroup:SetCallback("OnGroupSelected", function(_, event, group)
        currentGroup = group
        updateGroup()
    end)

    saveChangesButton:SetCallback("OnClick", function()
        self:Print("Saving lists")
        self.db.profile.lists = self.libs.AceSerializer:Serialize(localLists)
        self:RefreshConfig()
        self:CloseGUI()
    end)

    if firstKey ~= "" then
        tabGroup:SelectTab(firstKey)
    end
end

function PajMarker:CloseGUI()
    if self.window == nil then
        self:Print("GUI is already closed")
    end

    self.window:Release()
end
