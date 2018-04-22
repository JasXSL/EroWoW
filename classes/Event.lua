local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local evtFrame = CreateFrame("Frame");

local RPText, Character, SpellBinding, Index, Action;

local Event = {}
	Event.index = 0
	Event.bindings = {}		-- {id={event:(str)event, callback:(str)callback}...}
	Event.AURAS = {}
	Event.lootContainer = nil					-- Loot container name when looting a container through the "Open" spell

	-- Custom events
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
	}


	function Event.ini()
		RPText = require("RPText");
		Character = require("Character");
		SpellBinding = require("SpellBinding");
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

			if combatEvent == "UNIT_DIED" then
				if 
					bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0 and
					bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0
				then
					Character.rollLoot(destName);
				end
			end

			-- Only player themselves after this point
			if bit.band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0 then return end 

			
			-- These only work for healing or damage
			if not RPText.takehitCD and (eventPrefix == "SPELL" or eventPrefix == "SPELL_PERIODIC") and (eventSuffix == "DAMAGE" or eventSuffix=="HEAL") then
				
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
				SpellBinding.onTick(u, npc, trig)
				if harmful and eventPrefix ~= "SPELL_PERIODIC" then
					triggerWhisper(u, npc, trig, Condition.Types.RTYPE_SPELL_TICK)
				end

			elseif eventSuffix == "DAMAGE" and eventPrefix == "SWING" then

				local crit = ""
				if arguments[18] or (localStorage.tank_mode and math.random() < globalStorage.tank_mode_perc) then crit = "_CRIT" end

				local damage = 0	
				damage = arguments[12]

				
				local chance = globalStorage.swing_text_freq;
				if crit ~= "" then chance = chance*4 end -- Crits have 3x chance for swing text

				local npc = Character.buildNPC(u, sourceName)
				local rand = math.random()
				if not RPText.takehitCD and rand < chance and u and not UnitIsPlayer(u) then

					-- id, senderUnit, receiverUnit, senderChar, receiverChar, spellData, event, action
					local rp = RPText.get(eventPrefix..crit, u, "player", npc, ExiWoW.ME);
					if rp then
						RPText.setTakehitTimer();
						rp:convertAndReceive(npc, ExiWoW.ME)
					end

				end

				if damage <= 0 then return end
				local percentage = damage/UnitHealthMax("player");
				ExiWoW.ME:addExcitement(percentage*0.1, false, true);

				triggerWhisper(
					u,
					npc, 
					buildSpellTrigger("ATTACK", "ATTACK", true, sourceName, 1, crit, npc), 
					Condition.Types.RTYPE_MELEE
				)
				

			end
		end

		Event.raise(event, arguments);

		if event == "UNIT_SPELLCAST_SENT" then
			
			local lootableSpells = {
				Fishing = true,
				Mining = true,
				Opening = true,
				["Herb Gathering"] = true,
				Archaeology = true,
				Skinning = true,
				Mining = true,
				Disenchanting = true
			}
			if lootableSpells[arguments[2]] then
				Character.lootSpell = arguments[2];
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
		
		if event == "LOOT_OPENED" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" then
			if Event.lootContainer then 
				print("LootContainer = ", Event.lootContainer);
			
				print("Nr items", GetNumLootItems())
				print("Autoloot", arguments[1])
				for i=1, GetNumLootItems() do
					print("Item", i, GetLootSlotInfo(i))
				end
			end

		end

		if event == "LOOT_CLOSED" then
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
					SpellBinding.onAdd(unitCaster, char, aura);
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
					SpellBinding.onRemove(nil, a.char, a);
				end
			end

			Event.AURAS = active

		end

	end


	function Event.on(event, callback)
		if type(callback) ~= "function" then print("Callback in event binding is not a function, got", type(callback)); return false end
		Event.index = Event.index + 1;
		Event.bindings[Event.index] = {event=event, callback=callback}
		return Event.index
	end

	function Event.off(id)
		Event.bindings[id] = nil
	end

	function Event.raise(evt, data)
		for _,v in pairs(Event.bindings) do
			if v.event == evt then
				v.callback(data)
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
