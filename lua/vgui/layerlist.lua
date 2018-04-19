--[[------------------------------------------------------------------------------------------------------------------
	Layer list control
------------------------------------------------------------------------------------------------------------------]]
--
PANEL = {}
local layerButtonControl = vgui.RegisterFile("vgui/layerlist_layer.lua")

function PANEL:Init()
    self.CreateButton = vgui.Create("DButton", self)
    self.CreateButton:SetKeyboardInputEnabled(true)
    self.CreateButton:SetEnabled(true)
    self.CreateButton:SetText("Create new layer")

    self.CreateButton.DoClick = function()
        if (self.HasLayer) then
            RunConsoleCommand("layers_destroy")
        else
            RunConsoleCommand("layers_create")
        end
    end

    self.List = vgui.Create("DPanelList", self)
    self.List:SetSpacing(2)
    self.List:SetPadding(2)
    self.SelectedLayer = 1
    RunConsoleCommand("layers_sync")
end

function PANEL:PerformLayout()
    self:SetTall(400)
    self.CreateButton:StretchToParent(0, self:GetTall() - 25, 0, 0)
    self.CreateButton:AlignLeft()
    self.CreateButton:AlignBottom()
    self.List:StretchToParent(0, 0, 0, 0)
    self.List:StretchBottomTo(self.CreateButton, 10)
end

function PANEL:AddLayer(id, title, owner)
    local layerButton = vgui.CreateFromTable(layerButtonControl, self.List)
    layerButton:SetLayer(id, title, owner)
    self.List:AddItem(layerButton)
end