--[[------------------------------------------------------------------------------------------------------------------
	Serverside layers core
------------------------------------------------------------------------------------------------------------------]]
--
--require( "guardian" )
AddCSLuaFile("vgui/layerlist.lua")
AddCSLuaFile("vgui/layerlist_layer.lua")
AddCSLuaFile("client/cl_layerscore.lua")
Layers = {}

--[[------------------------------------------------------------------------------------------------------------------
	Layer management
------------------------------------------------------------------------------------------------------------------]]
--
Layers.Layers = {
    {
        Owner = NULL,
        Title = "Default"
    }
}

function Layers:CreateLayer(ply, title)
    if (not ply.OwnedLayer) then
        table.insert(Layers.Layers, {
            Owner = ply,
            Title = title
        })

        umsg.Start("layer_created")
        umsg.Short(#Layers.Layers)
        umsg.String(title)
        umsg.Entity(ply)
        umsg.End()
        ply.OwnedLayer = #Layers.Layers
    end
end

function Layers:DestroyLayer(ply)
    if (ply.OwnedLayer) then
        umsg.Start("layer_destroyed")
        umsg.Short(ply.OwnedLayer)
        umsg.End()

        for _, ent in ipairs(ents.GetAll()) do
            if (ent:GetLayer() == ply.OwnedLayer) then
                if (not ent:IsPlayer() and not ent:GetOwner():IsValid()) then
                    ent:Remove()
                else
                    ent:SetLayer(1)
                end
            end
        end

        Layers.Layers[ply.OwnedLayer] = nil
        ply.OwnedLayer = nil
    end
end

timer.Create("CleanupLayers", 1, 0, function()
    for i = 2, #Layers.Layers do
        if (not Layers.Layers[i].Owner:IsValid()) then
            table.remove(Layers.Layers, i)
        end
    end
end)

concommand.Add("layers_create", function(ply)
    if (ply:IsValid()) then
        Layers:CreateLayer(ply, ply:Nick() .. "'s layer")
    end
end)

concommand.Add("layers_destroy", function(ply)
    if (ply:IsValid()) then
        Layers:DestroyLayer(ply)
    end
end)

concommand.Add("layers_select", function(ply, com, args)
    if (ply:IsValid() and Layers.Layers[tonumber(args[1])]) then
        ply.SelectedLayer = tonumber(args[1])
    end
end)

concommand.Add("layers_sync", function(ply)
    for id, layer in ipairs(Layers.Layers) do
        umsg.Start("layer_created", ply)
        umsg.Short(id)
        umsg.String(layer.Title)
        umsg.Entity(layer.Owner)
        umsg.End()
    end
end)

--[[------------------------------------------------------------------------------------------------------------------
	Basic set and get layer functions
------------------------------------------------------------------------------------------------------------------]]
--
local meta = FindMetaTable("Entity")

function meta:SetLayer(layer)
    self:SetDTInt(3, layer)

    if (not self.UsingCamera) then
        self:SetViewLayer(layer)
    end
end

function meta:SetViewLayer(layer)
    self:SetDTInt(2, layer)
end

function meta:GetLayer(default)
    return self:GetDTInt(3)
end

--[[------------------------------------------------------------------------------------------------------------------
	Collision handling
------------------------------------------------------------------------------------------------------------------]]
--
local function CollisionChecker(ent)
    timer.Simple(0.1, function()
        if not IsValid(ent) then return end
        ent:SetCustomCollisionCheck(true)
    end)
end

hook.Add("OnEntityCreated", "DisableCollisonChecker", CollisionChecker)

function Layers:ShouldCollide(ent1, ent2)
    --print("should collide was called!")
    return ent1:GetLayer() == ent2:GetLayer() or ent1:IsWorld() or ent2:IsWorld()
end

function ShouldEntitiesCollide(ent1, ent2)
    if IsValid(ent1) and IsValid(ent2) and ent1:GetLayer() ~= ent2:GetLayer() then return false end
end

hook.Add("ShouldCollide", "DisableCollisionsLayer", ShouldEntitiesCollide)
--[[------------------------------------------------------------------------------------------------------------------
	Trace modification
------------------------------------------------------------------------------------------------------------------]]
--
Layers.OriginalPlayerTrace = util.GetPlayerTrace

function util.GetPlayerTrace(ply, dir)
    local originalResult = Layers.OriginalPlayerTrace(ply, dir)
    originalResult.filter = {ply}

    for _, ent in ipairs(ents.GetAll()) do
        if (ent:GetLayer() ~= ply:GetLayer()) then
            table.insert(originalResult.filter, ent)
        end
    end

    return originalResult
end

--[[------------------------------------------------------------------------------------------------------------------
	Constraint handling
------------------------------------------------------------------------------------------------------------------]]
--
Layers.OldKeyframeRope = constraint.CreateKeyframeRope

function constraint.CreateKeyframeRope(pos, width, material, constr, ent1, lpos1, bone1, ent2, lpos2, bone2, kv)
    local rope = Layers.OldKeyframeRope(pos, width, material, constr, ent1, lpos1, bone1, ent2, lpos2, bone2, kv)

    if (rope) then
        if (ent1:IsWorld() and not ent2:IsWorld()) then
            rope:SetNWEntity("CEnt", ent2)
        elseif (not ent1:IsWorld() and ent2:IsWorld()) then
            rope:SetNWEntity("CEnt", ent1)
        else
            -- For a pulley, the two specified entities are both the world for the middle rope, so we just remember the entity from the first rope
            rope:SetNWEntity("CEnt", Layers.KeyframeEntityCache)
        end
    end

    Layers.KeyframeEntityCache = ent1

    return rope
end

--[[------------------------------------------------------------------------------------------------------------------
	Camera handling
------------------------------------------------------------------------------------------------------------------]]
--
local pl = FindMetaTable("Player")
Layers.OldSetViewEntity = pl.SetViewEntity

function pl:SetViewEntity(ent)
    self:SetViewLayer(ent:GetLayer())

    return Layers.OldSetViewEntity(self, ent)
end

--[[------------------------------------------------------------------------------------------------------------------
	Set the layer of spawned entities
------------------------------------------------------------------------------------------------------------------]]
--
function Layers.EntitySpawnLayer(ply, ent)
    ent:SetLayer(ply:GetLayer())
end

function Layers.EntitySpawnLayerProxy(ply, mdl, ent)
    Layers.EntitySpawnLayer(ply, ent)
end

Layers.OriginalAddCount = pl.AddCount

function pl:AddCount(type, ent)
    ent:SetLayer(self:GetLayer())

    return Layers.OriginalAddCount(self, type, ent)
end

Layers.OriginalCleanup = cleanup.Add

function cleanup.Add(ply, type, ent)
    if (ent) then
        ent:SetLayer(ply:GetLayer())
    end

    return Layers.OriginalCleanup(ply, type, ent)
end

function Layers.InitializePlayerLayer(ply)
    ply:SetLayer(1)
end

hook.Add("PlayerSpawnedSENT", "LayerEntityInitialization", Layers.EntitySpawnLayer)
hook.Add("PlayerSpawnedNPC", "LayerEntityInitialization", Layers.EntitySpawnLayer)
hook.Add("PlayerSpawnedVehicle", "LayerEntityInitialization", Layers.EntitySpawnLayer)
hook.Add("PlayerSpawnedProp", "LayerEntityInitialization", Layers.EntitySpawnLayerProxy)
hook.Add("PlayerSpawnedEffect", "LayerEntityInitialization", Layers.EntitySpawnLayerProxy)
hook.Add("PlayerSpawnedRagdoll", "LayerEntityInitialization", Layers.EntitySpawnLayerProxy)
hook.Add("PlayerInitialSpawn", "LayerPlayerInitialization", Layers.InitializePlayerLayer)