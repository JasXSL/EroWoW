local appName, internal = ...;

ExiWoW.Underwear = {}
ExiWoW.Underwear.__index = ExiWoW.Underwear;
ExiWoW.Underwear.Lib = {}

-- RPText CLASS
function ExiWoW.Underwear:new(data)
	local self = {}
	setmetatable(self, ExiWoW.Underwear);
	
	self.id = data.id or "";							--
	self.name = data.name or "???"
	self.icon = data.icon or "Inv_misc_questionmark"
	self.description = data.description or "???"
	self.tags = data.tags or {}
	self.color = data.color or false
	self.equip_sound = data.equip_sound or 1202
	self.unequip_sound = data.equip_sound or 1185

	return self
end

	-- TOOLTIP HANDLING --
function ExiWoW.Underwear:onTooltip(frame)

	if frame then

		local v = self
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.name, 1, 1, 1)
		GameTooltip:AddLine(self.description, nil, nil, nil, true)
		GameTooltip:Show()

	else

		GameTooltip:Hide();

	end


end

function ExiWoW.Underwear:import(data)
	return ExiWoW.Underwear:new({
		name = data.na,
		color = data.co
	});
end

function ExiWoW.Underwear:export()
	return {
		na = self.name,
		co = self.color
	}
end

-- Static
function ExiWoW.Underwear:get(id)
	for _,uw in pairs(ExiWoW.Underwear.Lib) do
		if uw.id == id then return uw end
	end
	return false
end

