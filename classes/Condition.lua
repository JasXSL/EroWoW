local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action;

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
		RTYPE_EQUIPMENT = "equipment",				-- {slot=(int)equipmentSlot(http://wowwiki.wikia.com/wiki/InventorySlotId), type="Plate/Mail/Leather/Cloth"}
		RTYPE_EVENT = "event",							-- Event that raised this

		-- These are primarily used for whisper texts
		RTYPE_REQUIRE_MALE = "req_male",			-- Allow male must be checked in settings
		RTYPE_REQUIRE_FEMALE = "req_female",		-- Allow female must be checked in settings
		RTYPE_REQUIRE_OTHER = "req_other",			-- Allow other must be checked in settings

		RTYPE_SELF_ONLY = "self_only",					-- Requires player unit to be target unit.
		RTYPE_STEALTH = "stealth",						-- Requires player unit to be stealthed
		RTYPE_PARTY = "party",							-- Player has to be in a party (regardless of settings, use for actions relying on methods only accessible on party members)
		RTYPE_PARTY_RESTRICTED = "party_restricted",	-- Same as above, but can be turned off in settings
		RTYPE_COMBAT = "combat",						-- Require player unit in combat
		RTYPE_DISTANCE = "distance",					-- (obj)distance - Use a const from Character to define the distance
		RTYPE_STUNNED = "stunned",						-- Player unit must be stunned
		RTYPE_MOVING = "moving",						-- Target unit must be moving
		RTYPE_INSTANCE = "instance",					-- Player unit must be in an instance
		RTYPE_DEAD = "dead",							-- Target unit must be dead
		RTYPE_VEHICLE = "vehicle",						-- Target unit must be in a vehicle
	}

	-- Index 1 = noninverted, index 2 = inverted
	Condition.Errors = {
		[Condition.Types.RTYPE_HAS_PENIS] = {
			"Target has no penis.",
			"Target has a penis."
		},
		[Condition.Types.RTYPE_HAS_VAGINA] = {
			"Target has no vagina.",
			"Target has a vagina."
		},
		[Condition.Types.RTYPE_HAS_BREASTS] = {
			"Target has no breasts.",
			"Target has breasts."
		},
		[Condition.Types.RTYPE_PENIS_GREATER] = {
			"Target genitals too small.",
			"Target genitals too large."
		},
		[Condition.Types.RTYPE_BREASTS_GREATER] = {
			"Target breasts too small.",
			"Target breasts too large."
		},
		[Condition.Types.RTYPE_BUTT_GREATER] = {
			"Target butt too small.",
			"Target butt to small."
		},
		[Condition.Types.RTYPE_RACE] = {
			"Target is not the required race.",
			"Target race incompatible."
		},
		[Condition.Types.RTYPE_CLASS] = {
			"Target is not the required class.",
			"Target race invalid."
		},
		[Condition.Types.RTYPE_TYPE] = {
			"Target type invalid.",
			"Target type invalid."
		},
		[Condition.Types.RTYPE_RANDOM] = {
			"Random fail!",
			"Random fail!"
		},
		[Condition.Types.RTYPE_NAME] = {
			"Target name invalid.",
			"Target name invalid."
		},
		[Condition.Types.RTYPE_HAS_AURA] = {
			"Target is missing required aura.",
			"Target is protected."
		},
		[Condition.Types.RTYPE_HAS_INVENTORY] = {
			"Required inventory missing.",
			"Required inventory missing."
		},
		[Condition.Types.RTYPE_UNDIES] = {
			"Target not wearing underwear.",
			"Target is wearing underwear."
		},
		[Condition.Types.RTYPE_CRIT] = {
			"This was not a critical hit.",
			"This was a critical hit."
		},
		[Condition.Types.RTYPE_DETRIMENTAL] = {
			"Spell was not detrimental.",
			"Spell was detrimental."
		},
		[Condition.Types.RTYPE_EQUIPMENT] = {
			"Required equipment missing.",
			"Invalid equipment worn."
		},
		[Condition.Types.RTYPE_EVENT] = {
			"Event invalid.",
			"Event invalid."
		},
		[Condition.Types.RTYPE_REQUIRE_MALE] = {
			"Blocked by male preferences.",
			"Blocked by male preferences."
		},
		[Condition.Types.RTYPE_REQUIRE_FEMALE] = {
			"Blocked by female preferences.",
			"Blocked by female preferences."
		},
		[Condition.Types.RTYPE_REQUIRE_OTHER] = {
			"Blocked by other preferences.",
			"Blocked by other preferences."
		},
		[Condition.Types.RTYPE_SELF_ONLY] = {
			"Invalid target.",
			"Cannot do that to yourself."
		},
		[Condition.Types.RTYPE_STEALTH] = {
			"You are not stealthed.",
			"You are stealthed."
		},
		[Condition.Types.RTYPE_PARTY] = {
			"You are not in a party.",
			"You are in a party."
		},
		[Condition.Types.RTYPE_PARTY_RESTRICTED] = {
			"Blocked due to party restrictions.",
			"Blocked due to party restrictions."
		},
		[Condition.Types.RTYPE_COMBAT] = {
			"You are not in combat.",
			"You are in combat."
		},
		[Condition.Types.RTYPE_DISTANCE] = {
			"Too far away.",
			"Too close."
		},
		[Condition.Types.RTYPE_STUNNED] = {
			"You are not stunned.",
			"You are stunned."
		},
		[Condition.Types.RTYPE_MOVING] = {
			"You are not moving.",
			"You are moving."
		},
		[Condition.Types.RTYPE_INSTANCE] = {
			"You are not in an instance.",
			"You are in an instance."
		},
		[Condition.Types.RTYPE_DEAD] = {
			"You are alive.",
			"You are dead."
		},
		[Condition.Types.RTYPE_VEHICLE] = {
			"You are not in a vehicle.",
			"You are in a vehicle."
		},
		
	}

	function Condition.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
	end

	function Condition:new(data)
		local self = {}
		setmetatable(self, Condition);

		self.id = data.id;
		self.type = data.type or false;									-- RTYPE_*
		self.sender = data.sender or false;								-- Validate against sender							-- 
		self.data = type(data.data) == "table" and data.data or {};		-- See RTYPE_*
		self.inverse = data.inverse;											-- Returns false if it DOES validate

		if self.type == false then print("No type definition of condition", self.id) end

		return self
	end

	function Condition.get(id)
		return Database.getID("Condition", id);
	end

	function Condition:validate(senderUnit, receiverUnit, senderChar, receiverChar, spellData, event, action)

		-- Todo: Validate a requirement
		local t = self.type;
		local targ = receiverChar;
		local targUnit = receiverUnit;
		if self.sender then 
			targ = senderChar;
			targUnit = senderUnit;
		end
		local data = self.data;
		local inverse = self.inverse;
		local name = targ:getName();
		local ty = Condition.Types;
		local ch = ExiWoW.ME;

		local isSelf =
			(senderUnit == nil or receiverUnit == nil) or
			(senderUnit == "player" and UnitIsUnit(receiverUnit, "player")) or
			(receiverUnit == "player" and UnitIsUnit(senderUnit, "player"));
		local targIsMe = UnitIsUnit(targUnit, "player");
		local inParty = isSelf or UnitInRaid(unitCaster) or UnitInParty(unitCaster) or UnitInRaid(unitTarget) or UnitInRaid(unitTarget);
		local senderIsMe = UnitIsUnit(senderUnit, "player");

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
			out = Event.hasAura(data);
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
				(type(und) == "table" and data[und.id])
		elseif t == ty.RTYPE_SELF_ONLY then
			out = isSelf;
		elseif t == ty.RTYPE_STEALTH then
			out = IsStealthed() or not targIsMe;
		elseif t == ty.RTYPE_PARTY then
			out = inParty;
		elseif t == ty.RTYPE_PARTY_RESTRICTED then
			out = inParty or globalStorage.enable_public;
		elseif t == ty.RTYPE_COMBAT then
			out = UnitAffectingCombat(targUnit);
		elseif t == ty.RTYPE_DISTANCE then
			out = (Action.checkRange(senderUnit, data) or Action.checkRange(receiverUnit, data));
		elseif t == ty.RTYPE_STUNNED then
			out = not HasFullControl() or not targIsMe;		-- Target in condition is checked
		elseif t == ty.RTYPE_MOVING then
			out = GetUnitSpeed(targUnit) > 0;
		elseif t == ty.RTYPE_INSTANCE then	
			out = IsInInstance();
		elseif t == ty.RTYPE_DEAD then
			out = UnitIsDeadOrGhost(targUnit);
		elseif t == ty.RTYPE_VEHICLE then
			out = UnitInVehicle(targUnit);
		end

		if Condition.DEBUG and not out then print("Failed on", t, ExiWoW.json.encode(data)) end

		if inverse then out = not out end
		return out; 
	end

	function Condition:reportError(ignore)
		local error = Condition.Errors[self.type][1];
		if self.inverse then
			error = Condition.Errors[self.type][2];
		end
		return Tools.reportError(error, ignore);
	end

	-- Validate all conditions
	function Condition.all(conditions, ...)
		for _,cond in pairs(conditions) do
			
			if not cond:validate(...) then
				return false, cond;
			end
		end

		return true;
	end

export(
	"Condition", 
	Condition
)
