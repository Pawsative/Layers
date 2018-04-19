--[[------------------------------------------------------------------------------------------------------------------
	Layer control
------------------------------------------------------------------------------------------------------------------]]
--
PANEL = {}

function PANEL:Init()
    self.OwnerButton = vgui.Create("DImageButton", self)
    self.OwnerButton:SetMaterial("icon16/user.png")
    self.InfoButton = vgui.Create("DImageButton", self)
    self.InfoButton:SetMaterial("icon16/car.png")

    self.InfoButton.Think = function()
        local count = 0

        for _, ent in ipairs(ents.GetAll()) do
            --print(ent)
            if not IsValid(ent) then continue end
            if ent:IsPlayer() then continue end

            if (ent:GetLayer() == self.Layer.ID and not ent:IsWeapon() and not ent:IsPlayer()) then
                count = count + 1
            end
        end

        self.InfoButton:SetTooltip("Amount of entities: " .. count)
    end

    self.PlayersButton = vgui.Create("DImageButton", self)
    self.PlayersButton:SetMaterial("icon16/group.png")

    self.PlayersButton.Think = function()
        local players = ""

        for _, ply in ipairs(player.GetAll()) do
            if (ply:GetLayer() == self.Layer.ID) then
                players = players .. ply:Nick() .. ", "
            end
        end

        if (#players == 0) then
            players = "None."
        else
            players = string.Left(players, #players - 2)
        end

        self.PlayersButton:SetTooltip("Players: " .. players)
    end

    self.Selected = false
end

function PANEL:OnMouseReleased(mc)
    for _, layer in ipairs(layerList.List:GetItems()) do
        layer.Selected = false
    end

    self.Selected = true
    layerList.SelectedLayer = self.Layer.ID
    RunConsoleCommand("layers_select", self.Layer.ID)
end

function PANEL:SetLayer(id, title, owner)
    self.Layer = {
        ID = id,
        Title = title,
        Owner = owner
    }

    if (owner) then
        self.OwnerButton:SetTooltip("Owner: " .. owner:Nick())
    else
        self.OwnerButton:SetTooltip("Owner: None.")
    end
end

function PANEL:PerformLayout()
    self.PlayersButton:SizeToContents()
    self.PlayersButton.y = 4
    self.PlayersButton:AlignRight(6)
    self.OwnerButton:SizeToContents()
    self.OwnerButton.x = self.PlayersButton.x - self.PlayersButton:GetWide() - 5
    self.OwnerButton.y = 4
    self.InfoButton:SizeToContents()
    self.InfoButton.x = self.OwnerButton.x - self.OwnerButton:GetWide() - 5
    self.InfoButton.y = 4
    self:SetTall(self.PlayersButton:GetTall() + 8)
end

function PANEL:Paint()
    if (self.Selected) then
        draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(48, 150, 253, 255))
    else
        draw.RoundedBox(2, 0, 0, self:GetWide(), self:GetTall(), Color(121, 121, 121, 150))
    end

    draw.SimpleText(self.Layer.Title, "Default", 6, 6, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    return false
end