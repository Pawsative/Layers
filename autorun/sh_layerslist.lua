local meta = FindMetaTable("Entity")

--[[------------------------------------------------------------------------------------------------------------------
	Get layer function
------------------------------------------------------------------------------------------------------------------]]--

function meta:GetLayer()
	if !IsValid(self) then return end
	local val = self:GetDTInt( 3 ) or 1
	
	if CLIENT then
		if ( val == 0 and self != LocalPlayer() ) then val = LocalPlayer():GetLayer() end
	end
	
	return val
end

function meta:GetViewLayer()
	if !IsValid(self) then return end
	local val = self:GetDTInt( 2 ) or 1
	
	if CLIENT then 
		if ( val == 0 ) then val = LocalPlayer():GetLayer() end
	end
	
	return val
end
