-- Contains info about a character, 
ExiWoW.Character = {}
ExiWoW.Character.__index = ExiWoW.Character;
ExiWoW.Character.evtFrame = CreateFrame("Frame");
ExiWoW.Character.eventBindings = {};		-- {id:(int)id, evt:(str)evt, fn:(func)function, numTriggers:(int)numTriggers=inf}
ExiWoW.Character.eventBindingIndex = 0;	

ExiWoW.Character.takehitCD = nil			-- Cooldown for takehit texts


-- Consts
ExiWoW.Character.AROUSAL_FADE_PER_SEC = 0.05;
ExiWoW.Character.AROUSAL_MAX = 1.25;				-- You can overshoot max excitement and have to wait longer
ExiWoW.Character.AROUSAL_FADE_IDLE = 0.001;
ExiWoW.Character.AURAS = {}



-- Static
function ExiWoW.Character:ini()

	ExiWoW.Character.evtFrame:SetScript("OnEvent", ExiWoW.Character.onEvent)
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_STARTED_MOVING")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player");
	ExiWoW.Character.evtFrame:RegisterEvent("SOUNDKIT_FINISHED");
	ExiWoW.Character.evtFrame:RegisterEvent("COMBAT_LOG_EVENT")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_AURA", "player")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_DEAD");

	-- Main timer, ticking once per second
	ExiWoW.Timer:set(function()
		
		-- Owner meditation
		local me = ExiWoW.ME;
		local fade = 0;
		if me.meditating then
			fade = ExiWoW.Character.AROUSAL_FADE_PER_SEC;
		elseif not UnitAffectingCombat("player") then
			fade = ExiWoW.Character.AROUSAL_FADE_IDLE;
		end
		me:addExcitement(-fade);


	end, 1, math.huge)

end

function ExiWoW.Character:onEvent(event, ...)

	local arguments = {...}

	-- Builds data for a spell trigger
	local function buildSpellTrigger(spellId, name, harmful, unitCaster, count, crit)
		return { spellId = spellId, name=name, harmful=harmful, unitCaster=unitCaster, count=count, crit=crit}
	end


	for k,v in pairs(ExiWoW.Character.eventBindings) do

		if v.evt == event then

			local trigs = v.numTriggers -1;

			-- Remove if out of triggers
			if trigs < 1 then
				ExiWoW.Character.eventBindings[k] = nil;
			else
				ExiWoW.Character.eventBindings[k].numTriggers = trigs;
			end

			if type(v.fn) == "function" then
				v:fn(arguments);
			end

		end
	end

	if event == "PLAYER_TARGET_CHANGED" then
		ExiWoW.Frames.targetHasExiWoWFrame:Hide();
		if UnitExists("target") then
			-- Query for the addon
			ExiWoW.Action:useOnTarget("A", "target", true);
		end
	end

	if event == "PLAYER_DEAD" then
		ExiWoW.ME:addExcitement(0, true);
	end
	
	if event == "UNIT_AURA" then

		local unit = ...;
		if unit ~= "player" then return end
		local active = {} -- spellID = {name=name, count=count}

		local function auraExists(tb, aura)
			for i,a in pairs(tb) do
				if a.spellId == aura.spellId and a.unitCaster == aura.unitCaster and a.harmful == aura.harmful then
					return true;
				end
			end
			return false
		end
		
		local function addAura(spellId, name, harmful, unitCaster, count)

			local aura = buildSpellTrigger(spellId, name, harmful, unitCaster, count)
			table.insert(active, aura)
			if not auraExists(ExiWoW.Character.AURAS, aura) then
				local uc = unitCaster;
				if not uc then uc = "??" else uc = UnitName(unitCaster) end
				ExiWoW.SpellBinding:onAdd(ExiWoW.Character:buildNPC(unitCaster, uc), aura)
			end

		end

		

		-- Read all buffs
		for i=1,40 do 
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i)
			if name == nil then break end
			addAura(spellId, name, false, unitCaster, count)
		end
		-- Read all debuffs
		for i=1,40 do 
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HARMFUL")
			if name == nil then break end
			addAura(spellId, name, true, unitCaster, count)
		end

		-- See what auras were removed
		for i,a in pairs(ExiWoW.Character.AURAS) do
			if not auraExists(active, a) then
				local uc = unitCaster;
				if not uc then uc = "??" else uc = UnitName(unitCaster) end
				ExiWoW.SpellBinding:onRemove(ExiWoW.Character:buildNPC(a.unitCaster, uc), a)
			end
		end

		ExiWoW.Character.AURAS = active

	end

	-- Handle combat log
	if event == "COMBAT_LOG_EVENT" then
		local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags =  ...; -- Those arguments appear for all combat event variants.
		local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");

		-- See if a viable unit exists
		local u = false
		if sourceGUID == UnitGUID("target") then u = "target"
		elseif sourceGUID == UnitGUID("focus") then u = "focus"
		elseif sourceGUID == UnitGUID("mouseover") then u = "mouseover"
		elseif sourceGUID == UnitGUID("player") then u = "player"
		end

		-- These only work for healing or damage
		if not ExiWoW.Character.takehitCD and (eventPrefix == "SPELL" or eventPrefix == "SPELL_PERIODIC") and (eventSuffix == "DAMAGE" or eventSuffix=="HEAL") then

			local npc = ExiWoW.Character:new({}, sourceName);
			if u then npc = ExiWoW.Character:buildNPC(u, sourceName) end

			-- Todo: Add spell triggers
			damage = arguments[15]
			local harmful = true
			if eventSuffix ~= "DAMAGE" then harmful = false end

			local trig = buildSpellTrigger(
				arguments[12], -- Spell ID
				arguments[13], --Spell Name
				harmful, 
				sourceName, 
				1,
				arguments[21] -- Crit
			)
			ExiWoW.SpellBinding:onTick(npc, trig)

		elseif eventSuffix == "DAMAGE" and eventPrefix == "SWING" then

			local crit = ""
			if arguments[18] then crit = "_CRIT" end


			local damage = 0
			

			damage = arguments[12]

			
			local chance = ExiWoW.GS.swing_text_freq;
			if crit ~= "" then chance = chance*4 end -- Crits have 3x chance for swing text

			local rand = math.random()
			if not ExiWoW.Character.takehitCD and rand < chance and u and not UnitIsPlayer(u) then

				local npc = ExiWoW.Character:buildNPC(u, sourceName)
				local rp = ExiWoW.RPText:get(eventPrefix..crit, npc, ExiWoW.ME)
				if rp then
					ExiWoW.Character:setTakehitTimer();
					rp:convertAndReceive(npc, ExiWoW.ME)
				end

			end

			if damage <= 0 then return end
			local percentage = damage/UnitHealthMax("player");
			ExiWoW.ME:addExcitement(percentage*0.1, false, true);
			

	   end
	end
end

function ExiWoW.Character:bind(evt, fn, numTriggers)

	ExiWoW.Character.eventBindingIndex = ExiWoW.Character.eventBindingIndex+1;
	table.insert(ExiWoW.Character.eventBindings, {
		id = ExiWoW.Character.eventBindingIndex,
		evt = evt,
		fn = fn,
		numTriggers = numTriggers or math.huge
	});

	return ExiWoW.Character.eventBindingIndex;

end

function ExiWoW.Character:unbind(id)

	for k,v in pairs(ExiWoW.Character.eventBindings) do
		if v.id == id then
			ExiWoW.Character.eventBindings[k] = nil;
			return
		end
	end

end

-- Builds an NPC from a unit
function ExiWoW.Character:buildNPC(u, name)

	if not name then name = "???" end
	local npc = ExiWoW.Character:new({}, name);
	if not u then u = "???" end
	npc.type = UnitCreatureType(u) or "???";
	--npc.race = UnitRace(u);
	npc.class = UnitClass(u) or "???";

	local sex = UnitSex(u) or 0;
	if sex == 2 then npc.penis_size = 2
	elseif sex == 3 then 
		npc.breast_size = 2;
		npc.vagina_size = 0;
	end
	return npc;
end


function ExiWoW.Character:setTakehitTimer()
	local rate = ExiWoW.GS.takehit_rp_rate;
	ExiWoW.Timer:clear(ExiWoW.Character.takehitCD);
	ExiWoW.Character.takehitCD = ExiWoW.Timer:set(function()
		ExiWoW.Character.takehitCD = nil;
	end, rate)
end





	-- Class declaration --
function ExiWoW.Character:new(settings, name)
	local self = {}
	setmetatable(self, ExiWoW.Character); 
	if type(settings) ~= "table" then
		settings = {}
	end
	
	local getVar = function(v, def)
		if v == nil then return def end
		return v
	end

	-- Visuals
	self.capFlashTimer = 0			-- Timer event of excitement cap
	self.capFlashPow = 0
	self.portraitBorder = false;
	self.portraitResting = false;
	self.restingTimer = 0;
	self.restingPow = 0;

	-- Stats & Conf
	self.name = name;					-- Nil for player self
	self.excitement = 0;
	self.hasControl = true;
	self.meditating = false;			-- Losing excitement 
	self.masochism = 0.25;
	
	-- These are automatically set on export if full is set.
	-- They still need to be fetched from settings though when received by a unit for an RP text
	self.class = settings.class or UnitClass("player");
	self.race = settings.race or UnitRace("player");

	-- These are not sent on export, but can be used locally for NPC events
	self.type = "player";				-- Can be overridden like humanoid etc. 
	
	-- 

	-- Importable properties
	-- Use ExiWoW.Character:getnSize
	-- If all these are false, size will be set to 2 for penis/breasts, 0 for vagina. Base on character sex in WoW 
	self.penis_size = getVar(settings.penis_size, false);				-- False or range between 0 and 4
	self.vagina_size = getVar(settings.vagina_size, false);				-- False or 0
	self.breast_size = getVar(settings.breast_size, false);				-- False or range between 0 and 4
	self.butt_size = getVar(settings.butt_size, 2);						-- Always a number
	
	-- Feature tests
	--self:addExcitement(1.1);

	return self
end

-- Exporting
function ExiWoW.Character:export(full)
	local out = {
		excitement = self.excitement,
		penis_size = self.penis_size,
		vagina_size = self.vagina_size,
		breast_size = self.breast_size,
		butt_size = self.butt_size,
	};
	-- Should only be used for "player"
	if full then
		out.class = UnitClass("player");
		out.race = UnitRace("player");
	end
	return out;
end

-- Gets a clamped excitement value
function ExiWoW.Character:getExcitementPerc()
	return max(min(self.excitement,1),0);
end

-- Raised when you max or drop off max excitement --
function ExiWoW.Character:onCapChange()
	local maxed = self.excitement >= 1

	ExiWoW.Timer:clear(ExiWoW.capFlashTimer);
	local se = self
	if maxed then
		self.capFlashTimer = ExiWoW.Timer:set(function()
			se.capFlashPow = se.capFlashPow+0.25;
			if se.capFlashPow >= 2 then se.capFlashPow = 0 end
			local green = -0.5 * (math.cos(math.pi * se.capFlashPow) - 1)
			ExiWoW.portraitBorder:SetVertexColor(1,0.5+green*0.5,1);
		end, 0.05, math.huge);
	else
		ExiWoW.portraitBorder:SetVertexColor(1,1,1);
	end

end

function ExiWoW.Character:addExcitement(amount, set, multiplyMasochism)

	if multiplyMasochism then amount = amount*self.masochism end
	local pre = self.excitement >= 1
	if not set then
		self.excitement = self.excitement+tonumber(amount);
	else
		self.excitement = tonumber(amount);
	end

	self.excitement =max(min(self.excitement, ExiWoW.Character.AROUSAL_MAX), 0);
	self:updateExcitementDisplay();

	if (self.excitement >= 1) ~= pre then
		self:onCapChange()
	end

end

function ExiWoW.Character:toggleResting(on)

	ExiWoW.Timer:clear(self.restingTimer);
	local se = self
	if on then
		se.restingPow = 0
		self.restingTimer = ExiWoW.Timer:set(function()
			se.restingPow = se.restingPow+0.1;
			local opacity = -0.5 * (math.cos(math.pi * se.restingPow) - 1)
			ExiWoW.portraitResting:SetAlpha(0.5+opacity*0.5);
		end, 0.05, math.huge);
	else
		ExiWoW.portraitResting:SetAlpha(0);
	end

end

function ExiWoW.Character:updateExcitementDisplay()

	ExiWoW.Frames.portraitExcitementBar:SetHeight(ExiWoW.Frames.PORTRAIT_FRAME_HEIGHT*max(self:getExcitementPerc(), 0.00001));

end



function ExiWoW.Character:isGenderless()
	if self.penis_size == false and self.vagina_size == false and self.type == "player" then
		return true
	end
	return false; 
end

function ExiWoW.Character:getPenisSize()
	
	if self:isGenderless() then
		if UnitSex("player") == 2 
		then return 2
		else return false end
	end

	return self.penis_size

end

function ExiWoW.Character:getBreastSize()
	
	if self:isGenderless() and not self.breast_size then
		if UnitSex("player") == 3
		then return 2
		else return false end
	end

	return self.breast_size

end

function ExiWoW.Character:getVaginaSize()
	
	if self:isGenderless() then
		if UnitSex("player") == 3
		then return 0
		else return false end
	end

	return self.vagina_size

end

function ExiWoW.Character:getButtSize()
	
	if type(self.butt_size) ~= "number" then
		return 2
	end

	return self.butt_size

end

-- Returns an Ambiguate name
function ExiWoW.Character:getName()
	if self.name == nil then
		return Ambiguate(UnitName("player"), "all") 
	end
	return Ambiguate(self.name, "all");
end

function ExiWoW.Character:isMale()
	return self:getPenisSize() ~= false and self:getBreastSize() == false and self:getVaginaSize() == false
end

function ExiWoW.Character:isFemale()
	return self:getPenisSize() == false and self:getBreastSize() ~= false and self:getVaginaSize() ~= false
end

