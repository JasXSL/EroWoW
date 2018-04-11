local appName, internal = ...
-- SpellBindings are spells that trigger RPTexts when received or ticking
-- Spellbindings will search for RPTexts with the spell name prefixed with SPELL_
-- They will also enable spell specific conditions
-- For now, the sender of this action will be templated as an NPC. Do not rely on the sender for spell based RPTexts!

ExiWoW.SpellBinding = {}
ExiWoW.SpellBinding.Lib = {}
ExiWoW.SpellBinding.__index = ExiWoW.SpellBinding;

function ExiWoW.SpellBinding:new(data)
	local self = {}
	setmetatable(self, ExiWoW.SpellBinding);

	self.name = data.name;	-- Converted into a table, you can use {name=true} with multiple spell names
	-- These functions are run with self = spellbinding, rptext = rptext or nil if not found, data = spelldata
	self.fnOnAdd = data.onAdd
	self.fnOnRemove = data.onRemove
	self.fnOnTick = data.onTick
	self.procChance = data.procChance or 0.5
	self.alias = data.alias							-- Lets you convert a spell into another
	self.allow_in_vehicle = data.allow_in_vehicle
	self.always_run = data.always_run or false		-- This is always run when it matches
	self.custom = data.custom or {}					-- Put custom parameters in here
	self.detrimental_only = data.detrimental_only
	self.beneficial_only = data.beneficial_only

	if type(self.name) ~= "table" and self.name ~= "" then
		local name = {};
		name[self.name] = true;
		self.name = name;
	end

	return self;
end

-- Runs (and returns if found) an RP text bound to a this spellbinding
function ExiWoW.SpellBinding:runRpText(sender, data, t)
	if not self:rollProc() then return end

	local name = data.name;
	if self.alias then name = self.alias end
	local rpText = ExiWoW.SpellBinding:getRpText(sender, data, t, name)
	if rpText then
		rpText:convertAndReceive(sender, ExiWoW.ME, false, data)
		ExiWoW.Character:setTakehitTimer();
		return rpText
	end
end


function ExiWoW.SpellBinding:rollProc()
	return math.random() < self.procChance*ExiWoWGlobalStorage.spell_text_freq;
end

	-- Static --
-- Runs code on all spell bindings that match the name --
function ExiWoW.SpellBinding:runOnThese(name, callback, always_run)
	if not internal.checkHardlimits(nil,nil,true) then return end

	for k,v in pairs(ExiWoW.SpellBinding.Lib) do
		if 
			ExiWoW:multiSearch(name, v.name) and 
			(self.allow_in_vehicle or not UnitInVehicle("player")) and
			(not ExiWoW.Character.takehitCD or always_run) and
			(not v.always_run == not always_run) -- Boolean compare
		then
			if callback(v) == false then 
				return
			end
		end
	end
end

-- Runs the always_run enabled procs
function ExiWoW.SpellBinding:alwaysRun(fnName, data)
	local name = data.name;
	ExiWoW.SpellBinding:runOnThese(name, function(self)
		if self[fnName] then
			self[fnName](self, data);
		end
		return true;
	end, true)
end


	-- Events --



function ExiWoW.SpellBinding:onAdd(sender, data)
	ExiWoW.SpellBinding:alwaysRun("fnOnAdd", data);
	ExiWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data, ExiWoW.RPText.Req.Types.RTYPE_SPELL_ADD);
		if self.fnOnAdd then
			self:fnOnAdd(rpText, data);
		end
		if rpText then 
			return false 
		end
	end);
end

function ExiWoW.SpellBinding:onTick(sender, data)
	ExiWoW.SpellBinding:alwaysRun("fnOnTick", data);
	ExiWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data, ExiWoW.RPText.Req.Types.RTYPE_SPELL_TICK);
		if self.fnOnTick then
			self:fnOnTick(rpText, data);
		end
		if rpText then 
			return false 
		end
	end);
end

function ExiWoW.SpellBinding:onRemove(sender, data)

	ExiWoW.SpellBinding:alwaysRun("fnOnRemove", data);
	ExiWoW.SpellBinding:runOnThese(data.name, function(self)
		local rpText = self:runRpText(sender, data, ExiWoW.RPText.Req.Types.RTYPE_SPELL_REM);
		if self.fnOnRemove then
			self:fnOnRemove(rpText, data);
		end
		if rpText then return false end
	end);
end

-- Returns an RP text object
function ExiWoW.SpellBinding:getRpText(sender, data, type, name)
	return ExiWoW.RPText:get(name, sender, ExiWoW.ME, data, type)
end

