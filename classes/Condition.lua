local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools;

local Condition = {};
Condition.__index = Condition;


-- Req CLASS --
	-- Ranges are usually 0 = tiny, 1 = small, 2 = average, 3 = large, 4 = huge
	Condition.Types = {
		RTYPE_HAS_PENIS = "has_penis",				-- These explain themselves
		RTYPE_HAS_VAGINA = "has_vagina",
		RTYPE_HAS_BREASTS = "has_breasts",
		RTYPE_PENIS_GREATER = "penis_greater",		-- (int)size :: Penis greater than size.
		RTYPE_BREASTS_GREATER = "breasts_greater",	-- (int)size :: Breasts greater than size.
		RTYPE_BUTT_GREATER = "butt_greater",			-- (int)size :: Butt greater than size.
		RTYPE_RACE = "race",							-- {raceEN=true, raceEn=true...} Table of races that are accepted. Example: {Gnome=true, HighmountainTauren=true}
		RTYPE_CLASS = "class",							-- {englishClass=true, englishClass=true...} Table of classes that are accepted. Example: {DEATHKNIGHT=true, MONK=true}
		RTYPE_TYPE = "type",							-- {typeOne=true, typeTwo=true...} For players this is always "player", otherwise refer to the type of NPC, such as "Humanoid"
		RTYPE_NAME = "name",							-- {nameOne=true, nameTwo=true...} Primairly useful for NPCs
		RTYPE_RANDOM = "rand",							-- {chance=0-1} 1 = 100%
		RTYPE_HAS_AURA = "aura",						-- {{name=name, caster=casterName}...} Player has one or more of these auras
		RTYPE_HAS_INVENTORY = "inv",					-- {{name=name, quant=min_quant}}
		RTYPE_UNDIES = "undies",						-- false = none, true = req, {name=true, name2=true...} = limit by name
		-- The following will only validate from spells received --
		RTYPE_CRIT = "crit",						-- Spell was a critical hit
		RTYPE_DETRIMENTAL = "detrimental",			-- Spell was detrimental
		RTYPE_SPELL_ADD = "spell_add",				-- Spell was just added
		RTYPE_SPELL_REM = "spell_rem",				-- Spell was just removed
		RTYPE_SPELL_TICK = "spell_tick",			-- Spell was ticking
		RTYPE_EQUIPMENT = "equipment",				-- {slot=(int)equipmentSlot(http://wowwiki.wikia.com/wiki/InventorySlotId), type="Plate/Mail/Leather/Cloth"}
		RTYPE_MELEE = "swing",						-- "Spell" was a melee swing

		-- These are primarily used for whisper texts
		RTYPE_REQUIRE_MALE = "req_male",			-- Allow male must be checked in settings
		RTYPE_REQUIRE_FEMALE = "req_female",		-- Allow female must be checked in settings
		RTYPE_REQUIRE_OTHER = "req_other"			-- Allow other must be checked in settings
	}

	function Condition.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
	end

	function Condition:new(data)
		local self = {}
		setmetatable(self, Condition);

		self.type = data.type or false;									-- RTYPE_*
		self.sender = data.sender or false;								-- Validate against sender							-- 
		self.data = type(data.data) == "table" and data.data or {};		-- See RTYPE_*
		self.inverse = false;											-- Returns false if it DOES validate

		return self
	end

	function Condition:validate(sender, receiver, spelldata, spelltype)
		
		
		-- Todo: Validate a requirement
		local t = self.type;
		local targ = receiver;
		if self.sender then targ = sender end
		local data = self.data;
		local inverse = self.inverse;
		local name = targ:getName();
		local ty = Condition.Types;
		local ch = ExiWoW.ME;

		-- Try to find errors
		local out = false
		if t == ty.RTYPE_HAS_PENIS then
			out = targ:getPenisSize() ~= false;
		elseif t == ty.RTYPE_HAS_VAGINA then 
			out = targ:getVaginaSize() ~= false;
		elseif t == ty.RTYPE_HAS_BREASTS then 
			out = targ:getBreastSize() ~= false;
		elseif t == ty.RTYPE_NAME then
			out = Tools.multiSearch(name, data)
		elseif t == ty.RTYPE_PENIS_GREATER then 
			out = targ:getPenisSize() ~= false and targ:getPenisSize() > data[1];
		elseif t == ty.RTYPE_BREASTS_GREATER then 
			out = targ:getBreastSize() ~= false and targ:getBreastSize() > data[1];
		elseif t == ty.RTYPE_BUTT_GREATER then 
			out = targ:getButtSize() > data[1];
		elseif t == ty.RTYPE_RACE then 
			out = Tools.multiSearch(targ.race, data)
		elseif t == ty.RTYPE_CLASS then 
			out = Tools.multiSearch(targ.class, data)
		elseif t == ty.RTYPE_TYPE then 
			out = Tools.multiSearch(targ.type, data)
		elseif t == ty.RTYPE_CRIT then
			out = type(spelldata) == "table" and spelldata.crit;
		elseif t == ty.RTYPE_DETRIMENTAL then
			out = type(spelldata) == "table" and spelldata.harmful;
		elseif t == ty.RTYPE_MELEE then
			out = spelltype == ty.RTYPE_MELEE
		elseif t == ty.RTYPE_SPELL_ADD then
			out = spelltype == ty.RTYPE_SPELL_ADD;
		elseif t == ty.RTYPE_SPELL_REM then
			out = spelltype == ty.RTYPE_SPELL_REM;
		elseif t == ty.RTYPE_SPELL_TICK then
			out = spelltype == ty.RTYPE_SPELL_TICK;
		elseif t == ty.RTYPE_RANDOM then
			out = math.random() < data.chance;
		elseif t == ty.RTYPE_HAS_AURA then
			out = Character:hasAura(data);
		elseif t == ty.RTYPE_HAS_INVENTORY then
			out = Character:hasInventory(data);
		elseif t == ty.RTYPE_REQUIRE_MALE then
			out = globalStorage.taunt_male == true
		elseif t == ty.RTYPE_REQUIRE_FEMALE then
			out = globalStorage.taunt_female == true
		elseif t == ty.RTYPE_REQUIRE_OTHER then
			out = globalStorage.taunt_other == true
		elseif t == ty.RTYPE_EQUIPMENT then
			local unit = false
			if targ == ExiWoW.ME then unit = "player" 
			elseif targ == ExiWoW.TARGET then unit = "target"
			end
			-- /dump GetItemInfo(GetInventoryItemID("player", 7))
			if unit then 
				local id = GetInventoryItemID(unit, data.slot)
				if not id then 
					out = false
				else
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
						GetItemInfo(id)
					out = itemType == "Armor" and (data.type ~= nil and data.type == itemSubType)
				end
				out = Character:hasInventory(data);
			end
		elseif t == ty.RTYPE_UNDIES then
			local und = targ:getUnderwear();
			out = 
				(data[1] == false and und == false) or
				(data[1] == true and und ~= false) or
				data[und.id]
		else print("Unknown validation type", t)
		end

		if Condition.DEBUG and not out then print("Failed on", t, ExiWoW.json.encode(data)) end

		if inverse then out = not out end
		return out; 
		

	end

export(
	"Condition", 
	Condition
)
