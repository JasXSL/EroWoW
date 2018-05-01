local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local evtFrame = CreateFrame("Frame");

local RPText, Character, Index, Action;

local Event = {}
	Event.index = 0
	Event.bindings = {}		-- {id={event:(str)event, callback:(str)callback}...}
	Event.AURAS = {}
	Event.lootContainer = nil					-- Loot container name when looting a container through the "Open" spell
	Event.lootSpell = nil

	-- Custom events
	-- Keep in mind events bound in Event.TYPES will also be raised
	Event.Types = {
		LOADED = "LOADED",									-- ExiWoW loaded
		EXADD = "EXADD",									-- {amount=amount, set=set, multiplyMasochism=multiplyMasochism} Excitement has been added or subtracted
		EXADD_DEFAULT = "EXADD_DEFAULT",					-- {vh=triggerVhProgram} Excitement add default
		EXADD_CRIT = "EXADD_CRIT",							-- {vh=triggerVhProgram} Excitement add crit
		EXADD_M_DEFAULT = "EXADD_M_DEFAULT",				-- {vh=triggerVhProgram} Excitement add masochistic default
		EXADD_M_CRIT = "EXADD_M_CRIT",						-- {vh=triggerVhProgram} Excitement add masochistic crit
		
		INVADD = "INVADD",									-- {type=type, name=name, quant=quant} - Inventory has been added
		
		ACTION_USED = "ACTION_USED",						-- {id=actionID, target=target, args=args, success=success} -- Target responded
		ACTION_INTERRUPTED = "ACTION_INTERRUPTED",			-- {id=actionID, target=target}
		ACTION_SENT = "ACTION_SENT",						-- {id=id, target=target} - Action sent to target

		ACTION_UNDERWEAR_EQUIP = "ACTION_UNDERWEAR_EQUIP",			-- {id=id}
		ACTION_UNDERWEAR_UNEQUIP = "ACTION_UNDERWEAR_UNEQUIP",		-- {id=id}
		ACTION_SETTING_CHANGE = "ACTION_SETTING_CHANGE",			-- void

		SWING = "SWING",											-- Melee swing {unit=unit, name=senderName}
		SPELL_ADD = "SPELL_ADD",									-- Spell added {aura=see buildSpellTrigger, unit=unit, name=NPCName}
		SPELL_REM = "SPELL_REM",									-- Spell removed --||--
		SPELL_TICK = "SPELL_TICK",									-- Spell ticked --||--
		SWING_CRIT = "SWING_CRIT",									-- Same as swing
		MONSTER_KILL = "MONSTER_KILL",								-- {name=deadNPCName}
		FORAGE = "FORAGE",											-- void

		CONTAINER_OPENED = "CONTAINER_OPENED",						-- {autoloot:1/0, action:"Herb Gathering"/"Open" etc, container:"Starlight Rose" etc} World container opened			
	}

	function Event.ini()
		RPText = require("RPText");
		Character = require("Character");
		Index = require("Index");
		Action = require("Action");
		

		evtFrame:SetScript("OnEvent", Event.onEvent)
		evtFrame:RegisterEvent("PLAYER_STARTED_MOVING")
		evtFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
		evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
		evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCESS", "player");
		
		evtFrame:RegisterEvent("SOUNDKIT_FINISHED");
		evtFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		evtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		evtFrame:RegisterUnitEvent("UNIT_AURA", "player")
		evtFrame:RegisterEvent("UNIT_AURA", "player")
		evtFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
		evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
		evtFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED_QUIET", "player")

		evtFrame:RegisterEvent("LOOT_OPENED");
		evtFrame:RegisterEvent("LOOT_SLOT_CLEARED");
		evtFrame:RegisterEvent("LOOT_CLOSED");
	end


	function Event.onEvent(self, event, ...)

		local arguments = {...}

		-- Local functions
		local function buildSpellTrigger(spellId, name, harmful, unitCaster, count, crit, char)
			return { spellId = spellId, name=name, harmful=harmful, unitCaster=unitCaster, count=count, crit=crit, char=char}
		end

		local function triggerWhisper(senderUnit, sender, spelldata, spellType)
			if math.random() > globalStorage.taunt_freq then return end 
			if RPText.whisperCD then return end

			if RPText.trigger("_WHISPER_", senderUnit, "player", sender, ExiWoW.ME, spelldata, spellType) then
				if globalStorage.taunt_rp_rate > 0 then
					RPText.whisperCD = Timer.set(function()
						RPText.whisperCD = nil
					end, globalStorage.taunt_rp_rate);
				end
			end
			
		end

		-- Handle combat log
		-- This needs to go first as it should only handle event bindings on the player
		if event == "COMBAT_LOG_EVENT_UNFILTERED" and Index.checkHardLimits("player", "player", true) then

			local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags =  ...; -- Those arguments appear for all combat event variants.
			local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");

			-- See if a viable unit exists
			local u = "none"
			if sourceGUID == UnitGUID("target") then u = "target"
			elseif sourceGUID == UnitGUID("focus") then u = "focus"
			elseif sourceGUID == UnitGUID("mouseover") then u = "mouseover"
			elseif sourceGUID == UnitGUID("player") then u = "player"
			end

			if combatEvent == "PARTY_KILL" then
				if 
					bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0
				then
					Event.raise(Event.Types.MONSTER_KILL, {name=destName});
				end
			end

			

			-- Only player themselves after this point
			if destGUID ~= UnitGUID("player") then return end 

			
			-- These only work for healing or damage
			if (eventPrefix == "SPELL" or eventPrefix == "SPELL_PERIODIC") and (eventSuffix == "DAMAGE" or eventSuffix=="HEAL") then
				
				local npc = Character:new({}, sourceName);
				if u then npc = Character.buildNPC(u, sourceName) end

				local crit = arguments[21]
				if localStorage.tank_mode then crit = math.random() < globalStorage.tank_mode_perc end

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
				--SpellBinding.onTick(u, npc, trig)
				Event.raise(Event.Types.SPELL_TICK, {
					aura = trig,
					unit = u,
					name = sourceName
				});

				if harmful and eventPrefix ~= "SPELL_PERIODIC" then
					triggerWhisper(u, npc, trig, Condition.Types.RTYPE_SPELL_TICK)
				end

			elseif eventSuffix == "DAMAGE" and eventPrefix == "SWING" then

				local crit = ""
				if arguments[18] or (localStorage.tank_mode and math.random() < globalStorage.tank_mode_perc) then crit = "_CRIT" end

				local damage = 0	
				damage = arguments[12]

				Event.raise(Event.Types.SWING..crit, {
					unit = u,
					name = sourceName
				});

				--print("Todo, whispers")
				--[[
				triggerWhisper(
					u,
					npc, 
					buildSpellTrigger("ATTACK", "ATTACK", true, sourceName, 1, crit, npc), 
					Condition.Types.RTYPE_MELEE
				)
				]]

			end
		end

		Event.raise(event, arguments);

		if event == "UNIT_SPELLCAST_SENT" then
			
			Event.lootContainer = nil;
			Event.lootSpell = nil;
			local lootableSpells = {
				Fishing = true,
				Mining = true,
				Opening = true,
				["Herb Gathering"] = true,
				Archaeology = true,
				Skinning = true,
				Mining = true,
				Disenchanting = true,
			}
			--print(arguments[2], lootableSpells[arguments[2]], arguments[3], arguments[4]);
			if lootableSpells[arguments[2]] then
				Event.lootSpell = arguments[2];
				Event.lootContainer = arguments[4];
			end
			--print(event, ...)
		end


		if event == "PLAYER_TARGET_CHANGED" then
			UI.portrait.targetHasExiWoWFrame:Hide();
			if UnitExists("target") then
				-- Query for the addon
				Action.useOnTarget("A", "target", true);
			end
		end

		if event == "PLAYER_DEAD" then
			ExiWoW.ME:addExcitement(0, true);
		end
		
		if event == "LOOT_OPENED" then
			if Event.lootContainer then
				Event.raise(Event.Types.CONTAINER_OPENED, {
					autoloot = arguments[1],
					container = Event.lootContainer,
					action = Event.lootSpell,
				});
			end
			Event.lootContainer = nil
		end
		if event == "LOOT_CLOSED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" then
			if event ~= "LOOT_CLOSED" and arguments[2] ~= Event.lootSpell then
				return;
			end
			Event.lootContainer = nil
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

				local char = Character.buildNPC(unitCaster, uc)
				--spellId, name, harmful, unitCaster, count, crit, char
				local aura = buildSpellTrigger(spellId, name, harmful, unitCaster, count, false, char)
				table.insert(active, aura)
				if not auraExists(Event.AURAS, aura) then
					Event.raise(Event.Types.SPELL_ADD, {
						aura = aura,
						unit = unit,
						name = uc
					});
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
			for i,a in pairs(Event.AURAS) do
				if not auraExists(active, a) then
					Event.raise(Event.Types.SPELL_REM, {
						aura = a,
						unit = "none",
						name = a.char.name
					});
				end
			end

			Event.AURAS = active

		end

	end


	function Event.on(event, callback)
		if type(callback) ~= "function" then 
			print("Callback in event binding is not a function, got", type(callback));
			print(debugstack());
			return false;
		end
		if type(event) ~= "string" then
			print("Invalid event binding passed to Event.on, got ", event);
			print(debugstack())
		end
		Event.index = Event.index + 1;
		Event.bindings[Event.index] = {event=event, callback=callback}
		return Event.index
	end

	function Event.off(id)
		if id == nil then return end
		Event.bindings[id] = nil
	end

	function Event.raise(evt, data)
		if not evt then
			print("Invalid event raised")
			print(debugstack())
		end
		-- Prevents recursion
		local splice = {}
		for _,v in pairs(Event.bindings) do
			table.insert(splice, v);
		end
		for _,v in pairs(splice) do
			if v.event == evt then
				v.callback(data, evt)
			end
		end
	end

	function Event.hasAura(names)
		if type(names) ~= "table" then print("Invalid name var for aura check, type was", type(names)); return false end 
		for k,v in pairs(names) do
			if type(v) ~= "table" then
				print("Error in hasAura, value is not a table")
			else
				local name = v.name;
				local caster = v.caster;
				for _,aura in pairs(Event.AURAS) do
					if (aura.name == name or name == nil) and (aura.cname == caster or caster == nil) then
						return true
					end
				end
			end
			
		end
		return false;
	end

export(
	"Event", 
	Event,
	{
		on = Event.on,
		off = Event.off,
		Types = Event.Types,
		hasAura = Event.hasAura
	},
	{
		raise = Event.raise
	}
)
