local appName, internal = ...

-- Contains info about a character, 
ExiWoW.Character = {}
ExiWoW.Character.__index = ExiWoW.Character;
ExiWoW.Character.evtFrame = CreateFrame("Frame");
ExiWoW.Character.eventBindings = {};		-- {id:(int)id, evt:(str)evt, fn:(func)function, numTriggers:(int)numTriggers=inf}
ExiWoW.Character.eventBindingIndex = 0;	

ExiWoW.Character.takehitCD = nil			-- Cooldown for takehit texts

local myGUID = UnitGUID("player")

-- Consts
ExiWoW.Character.EXCITEMENT_FADE_PER_SEC = 0.05;
ExiWoW.Character.EXCITEMENT_MAX = 1.25;				-- You can overshoot max excitement and have to wait longer
ExiWoW.Character.EXCITEMENT_FADE_IDLE = 0.001;
ExiWoW.Character.AURAS = {}



-- Static
function ExiWoW.Character:ini()

	ExiWoW.Character.evtFrame:SetScript("OnEvent", ExiWoW.Character.onEvent)
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_STARTED_MOVING")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCESS", "player");
	
	ExiWoW.Character.evtFrame:RegisterEvent("SOUNDKIT_FINISHED");
	ExiWoW.Character.evtFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	ExiWoW.Character.evtFrame:RegisterUnitEvent("UNIT_AURA", "player")
	ExiWoW.Character.evtFrame:RegisterEvent("PLAYER_DEAD");

	-- Main timer, ticking once per second
	ExiWoW.Timer:set(function()
		
		-- Owner meditation
		local me = ExiWoW.ME;
		local fade = 0;
		if me.meditating then
			fade = ExiWoW.Character.EXCITEMENT_FADE_PER_SEC;
		elseif not UnitAffectingCombat("player") then
			fade = ExiWoW.Character.EXCITEMENT_FADE_IDLE;
		end
		me:addExcitement(-fade);


	end, 1, math.huge)

end

function ExiWoW.Character:onEvent(event, ...)

	local arguments = {...}

	local function buildSpellTrigger(spellId, name, harmful, unitCaster, count, crit, char)
		return { spellId = spellId, name=name, harmful=harmful, unitCaster=unitCaster, count=count, crit=crit, char=char}
	end


	-- Handle combat log
	-- This needs to go first as it should only handle event bindings on the player
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then

		local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags =  ...; -- Those arguments appear for all combat event variants.
		local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");

		-- See if a viable unit exists
		local u = false
		if sourceGUID == UnitGUID("target") then u = "target"
		elseif sourceGUID == UnitGUID("focus") then u = "focus"
		elseif sourceGUID == UnitGUID("mouseover") then u = "mouseover"
		elseif sourceGUID == UnitGUID("player") then u = "player"
		end

		if combatEvent == "UNIT_DIED" then
			if 
				bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0 and
				bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0
			then
				ExiWoW.Character:rollLoot(destName);
			end
		end

		-- Only player themselves after this point
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then return end 

		
		-- These only work for healing or damage
		if not ExiWoW.Character.takehitCD and (eventPrefix == "SPELL" or eventPrefix == "SPELL_PERIODIC") and (eventSuffix == "DAMAGE" or eventSuffix=="HEAL") then
			
			local npc = ExiWoW.Character:new({}, sourceName);
			if u then npc = ExiWoW.Character:buildNPC(u, sourceName) end

			local crit = arguments[21]
			if ExiWoWLocalStorage.tank_mode then crit = math.random() < ExiWoW.TANK_MODE_PERC end

			-- Todo: Add spell triggers
			damage = arguments[15]
			local harmful = true
			if eventSuffix ~= "DAMAGE" then harmful = false end

			--spellId, name, harmful, unitCaster, count, crit, char
			local trig = buildSpellTrigger(
				arguments[12], -- Spell ID
				arguments[13], --Spell Name
				harmful, 
				sourceName, 
				1,
				crit, -- Crit
				npc
			)
			ExiWoW.SpellBinding:onTick(npc, trig)

		elseif eventSuffix == "DAMAGE" and eventPrefix == "SWING" then

			local crit = ""
			if arguments[18] or (ExiWoWLocalStorage.tank_mode and math.random() < ExiWoW.TANK_MODE_PERC) then crit = "_CRIT" end

			local damage = 0
			

			damage = arguments[12]

			
			local chance = ExiWoWGlobalStorage.swing_text_freq;
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

			local uc = unitCaster;
			if not uc then uc = "??" else uc = UnitName(unitCaster) end

			local char = ExiWoW.Character:buildNPC(unitCaster, uc)
			--spellId, name, harmful, unitCaster, count, crit, char
			local aura = buildSpellTrigger(spellId, name, harmful, unitCaster, count, false, char)
			table.insert(active, aura)
			if not auraExists(ExiWoW.Character.AURAS, aura) then
				ExiWoW.SpellBinding:onAdd(char, aura)
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
				ExiWoW.SpellBinding:onRemove(a.char, a)
			end
		end

		ExiWoW.Character.AURAS = active

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
	local rate = ExiWoWGlobalStorage.takehit_rp_rate;
	ExiWoW.Timer:clear(ExiWoW.Character.takehitCD);
	ExiWoW.Character.takehitCD = ExiWoW.Timer:set(function()
		ExiWoW.Character.takehitCD = nil;
	end, rate)
end

function ExiWoW.Character:hasAura(names)
	if type(names) ~= "table" then print("Invalid name var for aura check, type was", type(names)); return false end 
	for k,v in pairs(names) do
		if type(v) ~= "table" then
			print("Error in hasAura, value is not a table")
		else
			local name = v.name;
			local caster = v.caster;
			for _,aura in pairs(ExiWoW.Character.AURAS) do
				if (aura.name == name or name == nil) and (aura.cname == caster or caster == nil) then
					return true
				end
			end
		end
		
	end
	return false;
end

-- See RPText RTYPE_HAS_INVENTORY
function ExiWoW.Character:hasInventory(names)
	if type(names) ~= "table" then print("Invalid name var for inventory check, type was", type(names)); return false end 

	for i=0,4 do
		local slots = GetContainerNumSlots(i);
		for slot=1,slots do
			local id = GetContainerItemID(i, slot)
			if id then
				local quant = GetItemCount(id, false);
				local name = GetItemInfo(id);
				for _,cond in pairs(names) do
					if (cond.name == name or cond.name == nil) and (cond.quant == quant or cond.quant == nil) then
						return name
					end
				end
			end
		end
	end
	return false;
end



-- Removes an equipped item and puts it into inventory if possible
function ExiWoW.Character:removeEquipped( slot )

	for i=0,4 do
		local free = GetContainerNumFreeSlots(i);
		if free > 0 then
			PickupInventoryItem(slot)
			if i == 0 then 
				PutItemInBackpack() 
			else
				PutItemInBag(19+i)	
			end
			break
		end
	end

end




-- Forage
function ExiWoW.Character:forage()
	
	if ExiWoW.Character:rollLoot("_FORAGE_") then return true end

	PlaySound(1142, "Dialog")
	ExiWoW.RPText:print("You found nothing");

	return false

end

function ExiWoW.Character:rollLoot(npc)
	
	local topzone = GetRealZoneText()
	local subzone = GetSubZoneText()
	local f = ExiWoW.LibAssets.foraging

	

	local function isCloseToPoints(points)
		SetMapToCurrentZone()
		local px,py = GetPlayerMapPosition("player")
		px = px*100
		py = py*100
		for _,v in pairs(points) do
			local x = v.x
			local y = v.y
			local radius = v.rad
			local dist = math.sqrt((px-x)*(px-x)+(py-y)*(py-y))
			if dist <= radius then return true end
		end
		return false
	end

	local available = {}
	for _,item in pairs(ExiWoW.LibAssets.loot) do
		
		local add = true
		if 
			not ExiWoW:multiSearch(topzone, item.zone) or
			not ExiWoW:multiSearch(subzone, item.sub) or
			not ExiWoW:multiSearch(npc, item.name)
		then add = false end

		if add and type(item.points) == "table" then
			add = isCloseToPoints(item.points)
		end

		if add then
			for _,it in pairs(item.items) do
				table.insert(available, it)
			end
		end

	end

	local size = #available
	for i = size, 1, -1 do
		local rand = math.random(size)
		available[i], available[rand] = available[rand], available[i]
	end

	for _,v in ipairs(available) do

		local chance = 1
		if v.chance then chance = v.chance end

		if math.random() < v.chance then 
			
			local item = ExiWoW.ME:addItem(v.type, v.id, v.quant);
			if item then
				if v.text then 
					v.text.item = item.name;
					v.text:convertAndReceive(ExiWoW.ME, ExiWoW.Character:buildNPC(u, npc));
				end
				if v.sound then PlaySound(v.sound, "Dialog") end
				return v;
			end

		end
	end

	return false

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
	self.excitement = settings.ex or 0;
	self.hasControl = true;
	self.meditating = false;			-- Losing excitement 
	self.masochism = 0.25;
	
	-- Inventory
	self.underwear_ids = {{id="DEFAULT",fav=false}};			-- Unlocked underwear
	self.underwear_worn = "DEFAULT";
	
	-- These are automatically set on export if full is set.
	-- They still need to be fetched from settings though when received by a unit for an RP text
	self.class = settings.cl or UnitClass("player");
	self.race = settings.ra or UnitRace("player");
	
	-- These are not sent on export, but can be used locally for NPC events
	self.type = "player";				-- Can be overridden like humanoid etc. 
	
	-- 

	-- Importable properties
	-- Use ExiWoW.Character:getnSize
	-- If all these are false, size will be set to 2 for penis/breasts, 0 for vagina. Base on character sex in WoW 
	self.penis_size = getVar(settings.ps, false);				-- False or range between 0 and 4
	self.vagina_size = getVar(settings.vs, false);				-- False or 0
	self.breast_size = getVar(settings.ts, false);				-- False or range between 0 and 4
	self.butt_size = getVar(settings.bs, 2);						-- Always a number
	self.underwear = false										-- This is a cache of underwear only set when received from another player via an action

	self.intelligence = getVar(settings.int, 5);
	self.muscle_tone = getVar(settings.str, 5);
	self.fat = getVar(settings.fat, 5);
	self.wisdom = getVar(settings.wis, 5);
	

	if settings.uw then self.underwear = ExiWoW.Underwear:import(settings.uw) end


	-- Feature tests
	--self:addExcitement(1.1);

	return self
end

-- Exporting
function ExiWoW.Character:export(full)

	local underwear = ExiWoW.Underwear:get(self.underwear_worn)
	if underwear then underwear = underwear:export() end
	local out = {
		ex = self.excitement,
		ps = self.penis_size,
		vs = self.vagina_size,
		ts = self.breast_size,
		bs = self.butt_size,
		uw = underwear,
		fat = self.fat,
		int = self.intelligence,
		str = self.muscle_tone,
		wis = self.wisdom
	};
	-- Should only be used for "player"
	if full then
		out.cl = UnitClass("player");
		out.ra = UnitRace("player");
	end
	return out;
end


-- Gets a clamped excitement value
function ExiWoW.Character:getExcitementPerc()
	return max(min(self.excitement,1),0);
end

-- Underwear --
-- Returns an underwear object
function ExiWoW.Character:getUnderwear()
	-- Received from other players
	if self.underwear then return self.underwear end
	return ExiWoW.Underwear:get(self.underwear_worn);
end
function ExiWoW.Character:useUnderwear(id)
	local uw = ExiWoW.Underwear:get(id)
	if self.underwear_worn == id then
		self.underwear_worn = false
		if uw then 
			PlaySound(uw.unequip_sound, "Dialog")
			ExiWoW.RPText:print("You take off your "..uw.name)
		end
	elseif self:ownsUnderwear(id) and uw then
		self.underwear_worn = id
		PlaySound(uw.equip_sound, "Dialog")
		ExiWoW.RPText:print("You put on your "..uw.name)
	else return false
	end
	ExiWoW.Menu:refreshUnderwearPage();
	return true
end

function ExiWoW.Character:ownsUnderwear(id)
	for _,u in pairs(self.underwear_ids) do
		if id == u.id then return true end
	end
	return false
end

-- Items --
function ExiWoW.Character:addItem(type, name, quant)

	if not quant then quant = 1 end
	if type == "Underwear" then
		if self:ownsUnderwear(name) then return false end
		local exists = ExiWoW.Underwear:get(name)
		if not exists then return false end
		table.insert(self.underwear_ids, {id=name, fav=false})
		ExiWoW.Menu:refreshUnderwearPage()
		ExiWoW.Menu:drawLoot(exists.name, exists.icon)
		return exists;
	elseif type == "Charges" then
		local action = ExiWoW.Action:get(name)
		if not action then return false end
		if action.charges >= action.max_charges or action.charges == math.huge then return false end
		if not action:consumeCharges(-quant) then return false end
		ExiWoW.Menu:drawLoot(action.name, action.texture)
		return action
	end

end

-- Stats
function ExiWoW.Character:getStat(unit, stat)
	local statlist = {Strength=1, Agility=2, Stamina=3, Intellect=4}
	if not UnitExists(unit) then return 0 end
	if not statlist[stat] then return 0 end

	local am = 0.5;
	if self.fat > 5 then
		am = 0.5-(self.fat-5)/10;
	end
	local multipliers = {
		Strength=(self.muscle_tone/10)+0.5, 
		Intelligence=(self.intelligence/10)+0.5, 
		Agility=am+0.5, 
	}
	local multi = 1;
	if multipliers[stat] then multi = multipliers[stat] end
	local base, stat, posBuff, negBuff = UnitStat(unit, statlist[stat]);
	local out = math.floor((base-posBuff)*multi);

	print("Base", out)

end

-- Raised when you max or drop off max excitement --
function ExiWoW.Character:onCapChange()

	local maxed = self.excitement >= 1

	ExiWoW.Timer:clear(self.capFlashTimer);
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

	local pre = self.excitement >= 1

	if multiplyMasochism then amount = amount*self.masochism end
	
	if not set then
		self.excitement = self.excitement+tonumber(amount);
	else
		self.excitement = tonumber(amount);
	end

	self.excitement =max(min(self.excitement, ExiWoW.Character.EXCITEMENT_MAX), 0);
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

