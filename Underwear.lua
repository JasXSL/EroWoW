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
	self.rarity = type(data.rarity) == "number" and data.rarity or 2
	if self.rarity < 1 then self.rarity = 1
	elseif self.rarity > 7 then self.rarity = 7
	end

	self.description = data.description or "???"
	self.tags = data.tags or {}
	self.color = data.color or false
	self.equip_sound = data.equip_sound or 1202
	self.unequip_sound = data.equip_sound or 1185
	self.flavor = data.flavor or false

	-- Allows you to tie passive effects to underwear
	-- Contains effect IDs
	self.effects = type(data.effects) == "table" and data.effects or {}

	return self
end

function ExiWoW.Underwear:onEquip()
	for _,v in pairs(self.effects) do
		local effect = ExiWoW.Effect:get(v)
		if effect then
			effect:add(1)
		end
	end
end

function ExiWoW.Underwear:onUnequip()
	for _,v in pairs(self.effects) do
		ExiWoW.Effect:remByID(v)
	end
end

	-- TOOLTIP HANDLING --
function ExiWoW.Underwear:onTooltip(frame)

	if frame then

		local v = self
		local color = ITEM_QUALITY_COLORS[self.rarity]

		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.name, color.r, color.g, color.b)
		GameTooltip:AddLine(self.description, 0.9, 0.9, 0.9, true)
		if self.flavor then
			GameTooltip:AddLine("\""..self.flavor.."\"", 1, 0.82, 0.043, true)
		end
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

