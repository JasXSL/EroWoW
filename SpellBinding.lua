-- SpellBindings are spells that trigger RPTexts when received or ticking
-- Spellbindings will search for RPTexts with the spell name prefixed with SPELL_
-- They will also enable spell specific conditions
-- For now, the sender of this action will be templated as an NPC. Do not rely on the sender for spell based RPTexts!

EroWoW.SpellBinding = {}
EroWoW.SpellBinding.Lib = {}
EroWoW.SpellBinding.__index = EroWoW.SpellBinding;

function EroWoW.SpellBinding:new(data)
	local self = {}
	setmetatable(self, EroWoW.SpellBinding);

	self.name = data.name;
	-- These functions are run with self = spellbinding, rptext = rptext or nil if not found, data = spelldata
	self.fnOnAdd = data.onAdd
	self.fnOnRemove = data.onRemove
	self.fnOnTick = data.onTick
	self.procChance = data.procChance or 0.5
	
	self.detrimental_only = data.detrimental_only
	self.beneficial_only = data.beneficial_only

	return self;
end

-- Runs (and returns if found) an RP text bound to a this spellbinding
function EroWoW.SpellBinding:runRpText(sender, data)
	self:getRpText(sender, data, EroWoW.RPText.Req.Types.RTYPE_SPELL_ADD)
	if rpText then
		rpText:convertAndReceive(sender, EroWoW.ME)
		return rpText
	end
end

-- Returns an RP text object
function EroWoW.SpellBinding:getRpText(sender, data, type)
	return EroWoW.RPText:get("SPELL_"..self.name, sender, EroWoW.ME, data, type)
end

function EroWoW.SpellBinding:rollProc()
	return math.random() < self.procChance*EroWoW.GS.spell_text_freq;
end

	-- Static --
-- Runs code on all spell bindings that match the name --
function EroWoW.SpellBinding:runOnThese(name, callback)
	for k,v in pairs(EroWoW.SpellBinding.Lib) do
		if v.name == name then
			callback(v);
		end
	end
end


	-- Events --



function EroWoW.SpellBinding:onAdd(sender, data)
	EroWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data);
		if self.fnOnAdd then
			self:fnOnAdd(rpText, data);
		end
	end);
end

function EroWoW.SpellBinding:onTick(sender, data)
	EroWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data);
		if self.fnOnTick then
			self:fnOnTick(rpText, data);
		end
	end);
end

function EroWoW.SpellBinding:onRemove(sender, data)
	EroWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data);
		if self.fnOnRemove then
			self:fnOnRemove(rpText, data);
		end
	end);
end
