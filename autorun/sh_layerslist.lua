local meta = FindMetaTable("Entity")

--[[------------------------------------------------------------------------------------------------------------------
	Get layer function
------------------------------------------------------------------------------------------------------------------]]--

function meta:GetLayer()
	local val = self:GetDTInt( 3 )
	
	if CLIENT then
		if ( val == 0 and self != LocalPlayer() ) then val = LocalPlayer():GetLayer() end
	end
	
	return val
end

function meta:GetViewLayer()
	local val = self:GetDTInt( 2 )
	
	if CLIENT then 
		if ( val == 0 ) then val = LocalPlayer():GetLayer() end
	end
	
	return val
end
