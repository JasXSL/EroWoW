local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local UI, Timer, Event, Action, Underwear, Index, Tools, RPText, Condition, NPC;
local myGUID = UnitGUID("player")

-- Contains info about a character, 
local Character = {}
Character.__index = Character;

	-- Consts
	Character.EXCITEMENT_FADE_PER_SEC = 0.05;
	Character.EXCITEMENT_MAX = 1.25;				-- You can overshoot max excitement and have to wait longer
	Character.EXCITEMENT_FADE_IDLE = 0.001;
	



	-- Static
	function Character.ini()

		UI = require("UI");
		Timer = require("Timer");
		Event = require("Event");
		Action = require("Action");
		Underwear = require("Underwear");
		Index = require("Index");
		Tools = require("Tools");
		RPText = require("RPText");
		Condition = require("Condition");
		NPC = require("NPC");

		-- Main character timer, ticking once per second
		Timer.set(function()
			-- Owner meditation
			local me = ExiWoW.ME;
			local fade = 0;
			if me.meditating then
				fade = Character.EXCITEMENT_FADE_PER_SEC;
			elseif not UnitAffectingCombat("player") then
				fade = Character.EXCITEMENT_FADE_IDLE;
			end
			me:addExcitement(-fade);
		end, 1, math.huge)

	end

	-- Builds an NPC from a unit
	function Character.buildNPC(u, name)

		if not name then name = "???" end
		if not u then u = "none" end

		local npc = Character:new({}, name);

		npc.type = UnitCreatureType(u) or "???";
		npc.class = UnitClass(u) or "???";
		npc.sex = nil;

		-- See if this one lives in NPC DB
		local db = NPC.get(name);
		if db then
			-- Fetch some predefined info
			npc.tags = db.tags;
			npc.sex = db.gender;
		end

		if not npc.sex then
			local sex = UnitSex(u) or 0;
			if sex == 2 then npc.penis_size = 2
			elseif sex == 3 then 
				npc.breast_size = 2;
				npc.vagina_size = 0;
			end
		end
		return npc;
	end


	-- See RPText RTYPE_HAS_INVENTORY
	function Character:hasInventory(names)
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
	function Character:removeEquipped( slot )

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
	function Character.forage()
		
		if Character.rollLoot("_FORAGE_") then return true end

		PlaySound(1142, "Dialog")
		RPText.print("You found nothing");

		return false

	end

	function Character.rollLoot(npc)
		
		local topzone = GetRealZoneText()
		local subzone = GetSubZoneText()
	

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
				not Tools.multiSearch(topzone, item.zone) or
				not Tools.multiSearch(subzone, item.sub) or
				not Tools.multiSearch(npc, item.name)
			then add = false end

			if add and type(item.points) == "table" then
				add = isCloseToPoints(item.points);
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
				
				local quant = v.quant;
				if not quant or quant < 1 then quant = 1 end
				if type(v.quantRand) == "number" and v.quantRand > 0 then
					quant = quant+math.random(v.quantRand+1)-1;
				end
				local item = ExiWoW.ME:addItem(v.type, v.id, quant);
				if item then
					if v.text then 
						v.text.item = item.name;
						v.text:convertAndReceive(ExiWoW.ME, Character.buildNPC(u, npc), false, nil, function(text)
							
							text = string.gsub(text, "%%Qs", quant ~= 1 and "s" or "")
							text = string.gsub(text, "%%Q", quant)
							return text
						end);
					end
					if v.sound then PlaySound(v.sound, "Dialog") end
					return v;
				end

			end
		end

		return false

	end









		-- Class declaration --
	function Character:new(settings, name)
		local self = {}
		setmetatable(self, Character); 
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
		self.tags = {};						-- For now, only used by NPCs

		-- Importable properties
		-- Use Character:getnSize
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
		

		if settings.uw then self.underwear = Underwear.import(settings.uw) end

		
		

		-- Feature tests
		--self:addExcitement(1.1);

		return self
	end

	-- Exporting
	function Character:export(full)

		local underwear = Underwear.get(self.underwear_worn)
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

	function Character:getTags()
		-- Todo: Expand with future tags
		return self.tags;
	end

	-- Gets a clamped excitement value
	function Character:getExcitementPerc()
		return max(min(self.excitement,1),0);
	end

	-- Underwear --
	-- Returns an underwear object
	function Character:getUnderwear()
		-- Received from other players
		if self.underwear then return self.underwear end
		return Underwear.get(self.underwear_worn);
	end

	function Character:useUnderwear(id)
		local uw = Underwear.get(id)
		if self.underwear_worn == id then
			self.underwear_worn = false
			if uw then 
				PlaySound(uw.unequip_sound, "Dialog")
				RPText.print("You take off your "..uw.name)
				uw:onUnequip();
				Event.raise(ACTION_UNDERWEAR_UNEQUIP, {id=id})
			end
		elseif self:ownsUnderwear(id) and uw then
			local cur = Underwear.get(self.underwear_worn)
			if cur then cur:onUnequip(); end
			self.underwear_worn = id
			PlaySound(uw.equip_sound, "Dialog")
			uw:onEquip();
			RPText.print("You put on your "..uw.name)
			Event.raise(ACTION_UNDERWEAR_EQUIP, {id=id})
		else return false
		end
		UI.underwearPage.update();
		return true
	end

	function Character:ownsUnderwear(id)
		for _,u in pairs(self.underwear_ids) do
			if id == u.id then return true end
		end
		return false
	end

	function Character:removeUnderwear(id)
		for k,u in pairs(self.underwear_ids) do
			if id == u.id then 
				self.underwear_ids[k] = nil
				print("Underwear removed")
				return true
			end
		end
		return false
	end

	-- Items --
	-- /run UI.drawLoot("Test", "inv_pants_leather_04")
	function Character:addItem(type, name, quant)

		if not quant then quant = 1 end
		if type == "Underwear" then
			if self:ownsUnderwear(name) then return false end
			local exists = Underwear.get(name)
			if not exists then return false end
			table.insert(self.underwear_ids, {id=name, fav=false})
			UI.underwearPage.update();
			UI.drawLoot(exists.name, exists.icon, exists.rarity)
			Event.raise(Event.Types.INVADD, {type=type, name=name, quant=quant})
			return exists;
		elseif type == "Charges" then
			local action = Action.get(name)
			if not action then return false end
			if action.charges >= action.max_charges or action.charges == math.huge then return false end
			if not action:consumeCharges(-quant) then return false end
			Event.raise(Event.Types.INVADD, {type=type, name=name, quant=quant})
			UI.drawLoot(action.name, action.texture, action.rarity)
			return action
		end

	end

	-- Stats
	function Character:getStat(unit, stat)
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
	function Character:onCapChange()

		local maxed = self.excitement >= 1

		Timer.clear(self.capFlashTimer);
		local se = self
		if maxed then
			self.capFlashTimer = Timer.set(function()
				se.capFlashPow = se.capFlashPow+0.25;
				if se.capFlashPow >= 2 then se.capFlashPow = 0 end
				local green = -0.5 * (math.cos(math.pi * se.capFlashPow) - 1)
				UI.portrait.border:SetVertexColor(1,0.5+green*0.5,1);
			end, 0.05, math.huge);
		else
			UI.portrait.border:SetVertexColor(1,1,1);
		end

	end

	function Character:addExcitement(amount, set, multiplyMasochism)

		local pre = self.excitement >= 1

		if multiplyMasochism then amount = amount*self.masochism end
		
		if not set then
			self.excitement = self.excitement+tonumber(amount);
		else
			self.excitement = tonumber(amount);
		end

		Event.raise(Event.Types.EXADD, {amount=amount, set=set, multiplyMasochism=multiplyMasochism})

		self.excitement =max(min(self.excitement, Character.EXCITEMENT_MAX), 0);
		UI.portrait.updateExcitementDisplay();

		if (self.excitement >= 1) ~= pre then
			self:onCapChange()
		end

	end

	function Character:toggleResting(on)

		Timer.clear(self.restingTimer);
		local se = self
		if on then
			se.restingPow = 0
			self.restingTimer = Timer.set(function()
				se.restingPow = se.restingPow+0.1;
				local opacity = -0.5 * (math.cos(math.pi * se.restingPow) - 1)
				UI.portrait.resting:SetAlpha(0.5+opacity*0.5);
			end, 0.05, math.huge);
		else
			UI.portrait.resting:SetAlpha(0);
		end

	end

	function Character:isGenderless()
		if self.penis_size == false and self.vagina_size == false and self.type == "player" then
			return true
		end
		return false; 
	end

	function Character:getPenisSize()
		
		if self:isGenderless() then
			if UnitSex("player") == 2 
			then return 2
			else return false end
		end

		return self.penis_size

	end

	function Character:getBreastSize()
		
		if self:isGenderless() and not self.breast_size then
			if UnitSex("player") == 3
			then return 2
			else return false end
		end

		return self.breast_size

	end

	function Character:getVaginaSize()
		
		if self:isGenderless() then
			if UnitSex("player") == 3
			then return 0
			else return false end
		end

		return self.vagina_size

	end

	function Character:getButtSize()
		
		if type(self.butt_size) ~= "number" then
			return 2
		end

		return self.butt_size

	end

	-- Returns an Ambiguate name
	function Character:getName()
		if self.name == nil then
			return Ambiguate(UnitName("player"), "all") 
		end
		return Ambiguate(self.name, "all");
	end

	function Character:isMale()
		return self:getPenisSize() ~= false and self:getBreastSize() == false and self:getVaginaSize() == false
	end

	function Character:isFemale()
		return self:getPenisSize() == false and self:getBreastSize() ~= false and self:getVaginaSize() ~= false
	end

export(
	"Character", 
	Character,
	{
		
	},
	Character
)