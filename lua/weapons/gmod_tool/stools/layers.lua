--[[------------------------------------------------------------------------------------------------------------------
	Layers STOOL
		Description: Put entities in different layers.
		Usage: Left click to set the layer of an entity and right click to set the layer you're in yourself.
------------------------------------------------------------------------------------------------------------------]]--

TOOL.Category = "Construction"
TOOL.Name = "#Tool.layers.name"
TOOL.Command = nil
TOOL.ConfigName = nil

TOOL.ClientConVar[ "layer" ] = 1

if ( CLIENT ) then

	language.Add( "Tool.layers.name",	"Layers" )
	language.Add( "Tool.layers.desc", "Construct in multiple layers." )
	language.Add( "Tool.layers.0",		"Primary: sets the layer of an entity you are looking at to the layer you selected in the panel, Secondary: sets the layer of yourself to the selected layer." )
	language.Add( "Tool.layers.1",		"Primary: update layer, Secondary: join layer" )
end

--[[------------------------------------------------------------------------------------------------------------------
	Left click to set the layer of an entity.
------------------------------------------------------------------------------------------------------------------]]--

function TOOL:LeftClick( tr )
	if ( !IsValid( tr.Entity ) ) then return false end
	if ( CLIENT ) then return true end
	if ( !Layers.Layers[ self:GetOwner().SelectedLayer ] ) then return false end
	
	local entities = constraint.GetAllConstrainedEntities( tr.Entity )
	
	for _, ent in pairs( entities ) do
		ent:SetLayer( self:GetOwner().SelectedLayer )
	end
	
	return true
end

--[[------------------------------------------------------------------------------------------------------------------
	Right click to set the layer you're in yourself.
------------------------------------------------------------------------------------------------------------------]]--

function TOOL:RightClick( tr )
	if ( !IsValid( self:GetOwner() ) ) then return false end
	if ( CLIENT ) then return false end
	if ( !Layers.Layers[ self:GetOwner().SelectedLayer ] ) then return false end
	
	self:GetOwner():SetLayer( self:GetOwner().SelectedLayer )
	
	return false
end

if ( CLIENT ) then
	local layerListControl = vgui.RegisterFile( "vgui/layerlist.lua" )

	function TOOL.BuildCPanel( pnl )	
		layerList = vgui.CreateFromTable( layerListControl )
		pnl:AddPanel( layerList )
	end
	
	usermessage.Hook( "layer_created", function( um )
		local id, title, owner = um:ReadShort(), um:ReadString(), um:ReadEntity()
		
		if ( owner == LocalPlayer() ) then
			layerList.HasLayer = true
			layerList.CreateButton:SetText( "Remove your layer" )
		end
		
		layerList:AddLayer( id, title, owner )
	end )
	
	usermessage.Hook( "layer_destroyed", function( um )
		local layerId = um:ReadShort()
		
		for _, layer in ipairs( layerList.List:GetItems() ) do
			if ( layer.Layer.ID == layerId ) then
				if ( layer.Layer.Owner == LocalPlayer() ) then
					layerList.HasLayer = false
					layerList.CreateButton:SetText( "Create new layer" )
				end
				
				layerList.List:RemoveItem( layer )
				
				break
			end
		end
	end )
end