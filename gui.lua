local addonName, addonTable = ...

function PajMarker:ShowExportWindow()
    if self.exportWindow ~= nil then
        self:Print("Expoort window is already open")
        return
    end

    local AceGUI = self.libs.AceGUI

    self.exportWindow = AceGUI:Create("Window")
    self.exportWindow:SetLayout("List")
    self.exportWindow:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        self.exportWindow = nil
    end)

    local label = AceGUI:Create("Label")
    label:SetText("Copy the below text to whomever you want to share your lists with")
    self.exportWindow:AddChild(label)

    local sg = AceGUI:Create("SimpleGroup")
    sg:SetLayout("Fill")
    sg:SetFullWidth(true)
    sg:SetFullHeight(true)

    local editbox = AceGUI:Create("MultiLineEditBox")
    local exportString = self.libs.AceSerializer:Serialize(self.lists)
    editbox:SetText(exportString)
    editbox:SetFocus()
    editbox:HighlightText()
    editbox:SetFullWidth(true)
    editbox:SetFullHeight(true)
    editbox:DisableButton()

    sg:AddChild(editbox)

    self.exportWindow:AddChild(sg)
end

function PajMarker:ShowImportWindow()
    if self.importWindow ~= nil then
        self:Print("Expoort window is already open")
        return
    end

    local AceGUI = self.libs.AceGUI

    self.importWindow = AceGUI:Create("Window")
    self.importWindow:SetLayout("List")
    self.importWindow:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        self.importWindow = nil
    end)

    local label = AceGUI:Create("Label")
    label:SetText("Paste the export string below and press the button - do note that any current lists will be overridden")
    self.importWindow:AddChild(label)

    local sg = AceGUI:Create("SimpleGroup")
    sg:SetLayout("Fill")
    sg:SetFullWidth(true)
    sg:SetFullHeight(true)

    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetFocus()
    editbox:SetFullWidth(true)
    editbox:SetFullHeight(true)
    editbox:SetCallback("OnEnterPressed", function(_, _, importString)
        -- Try to deserialize the string
        local success, _ = self.libs.AceSerializer:Deserialize(importString)
        if not success then
            self:Print("Error deserializing import string :( - make sure it's not malformed")
            return
        end

        self:Print("Successfully imported the lists!")
        self.db.profile.lists = importString

        self:RefreshConfig()

        self.importWindow:Release()
    end)

    sg:AddChild(editbox)

    self.importWindow:AddChild(sg)
end

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

    local add_new_list = "___add-new-list-xd-dont-name-a-list-this-secret-code"

    local localLists = deepCopy(self.lists)

    local originalList = deepCopy(localLists)

    local tabs = {};

    local first = true;

    local firstKey = "";

    local function updateTabs()
        first = true
        firstKey = add_new_list
        tabs = {}
        local numTabs = 0
        for listKey, listValue in orderedpairs(localLists) do
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

                local calculatedIcons = deepCopy(addonTable.AVAILABLE_MARKS)

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
            end)
            g:AddChild(newMonster)

            local renameList = AceGUI:Create("EditBox")
            renameList:SetLabel("Rename list")
            -- By default, this should be the old group name
            renameList:SetText(group)
            renameList:SetCallback("OnEnterPressed", function(widget, _, newName)
                local oldName = group
                if newName == oldName then
                    -- Nothing changed, do nothing
                    return
                end

                self:Print("Renaming list to " .. newName)
                localLists[newName] = localLists[oldName]
                localLists[oldName] = nil
                updateTabs()
                tabGroup:SelectTab(newName)
            end)
            g:AddChild(renameList)

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
