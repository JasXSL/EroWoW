local appName, internal = ...
local require = internal.require;

function internal.Gateway()

	local Event = require("Event");
	local Character = require("Character");
	local RPText = require("RPText");
	local Spell = require("Spell");
	local Loot = require("Loot");
	local Action = require("Action");

	-- Swing
	local function onSwing(unit, sender, crit)
		local chance = globalStorage.swing_text_freq;
		if crit ~= "" then 
			chance = chance*4;
		end -- Crits have 3x chance for swing text

		local rand = math.random();
		if not RPText.getTakehitCD() and rand < chance and unit and not UnitIsPlayer(unit) then

			local chance = globalStorage.swing_text_freq;
			if crit ~= "" then chance = chance*4 end -- Crits have 3x chance for swing text
			-- id, senderUnit, receiverUnit, senderChar, receiverChar, spellData, event, action
			local npc = Character.buildNPC(unit, sender);
			local rp = RPText.get(Event.Types.SWING..crit, unit, "player", npc, ExiWoW.ME, nil, Event.Types.SWING..crit);
			if rp then
				RPText.setTakehitTimer();
				rp:convertAndReceive(npc, ExiWoW.ME)
			end
		end

	end
	Event.on(Event.Types.SWING, function(data)
		onSwing(data.unit, data.name, "");
	end);
	Event.on(Event.Types.SWING_CRIT, function(data)
		onSwing(data.unit, data.name, "_CRIT");
	end);


	-- See buildSpellTrigger in Event for aura
	-- name is the name of the unit
	local function onSpell(event, aura, unit, name)

		local chance = 1;
		if event == Event.SPELL_TICK then
			chance = 0.05;
		end
		chance = chance*globalStorage.spell_text_freq;
		
		local npc = Character.buildNPC(unit, sender);
		local spellData = RPText.buildSpellData(aura.spellId, aura.name, aura.harmful, npc.name, aura.count, aura.crit);

		-- See if this spell was bound at all
		local spell = Spell.filter(aura.name, unit, "player", npc, ExiWoW.ME, spellData, event)[1];
		if spell and not RPText.getTakehitCD() and math.random() < chance and not UnitInVehicle("player") then
			spellData.tags = spell:exportTags();
			local rp = RPText.get(event, unit, "player", npc, ExiWoW.ME, spellData, event);
			if rp then
				RPText.setTakehitTimer();
				rp:convertAndReceive(npc, ExiWoW.ME, false, spellData);
			end
		end

	end
	Event.on(Event.Types.SPELL_ADD, function(data) onSpell(Event.Types.SPELL_ADD, data.aura, data.unit, data.name); end);
	Event.on(Event.Types.SPELL_REM, function(data) onSpell(Event.Types.SPELL_REM, data.aura, data.unit, data.name); end);
	Event.on(Event.Types.SPELL_TICK, function(data) onSpell(Event.Types.SPELL_TICK, data.aura, data.unit, data.name); end);
	


	local function rollLoot(event, npcName)
		
		local npc = Character.buildNPC("none", npcName);
		
		---- senderUnit, receiverUnit, senderChar, receiverChar, spellData, event, action
		local available = Loot.filter("none", "player", npc, ExiWoW.ME, nil, event, Action.get("FORAGE"));

		local out = {};

		for _,loot in pairs(available) do
			for _,item in pairs(loot.items) do
				
				local chance = 1
				if item.chance then chance = item.chance end

				if math.random() < chance then

					local quant = item.quant;
					if not quant or quant < 1 then quant = 1 end

					if type(item.quantRand) == "number" and item.quantRand > 0 then
						quant = quant+math.random(item.quantRand+1)-1;
					end

					local added = ExiWoW.ME:addItem(item.type, item.id, quant);
					if added then
						-- RP text
						if item.text then 
							item.text.item = added.name;
							item.text:convertAndReceive(npc, ExiWoW.ME, false, nil, function(text)
								text = string.gsub(text, "%%Qs", quant ~= 1 and "s" or "")
								text = string.gsub(text, "%%Q", quant)
								return text
							end);
						end
						if item.sound then PlaySound(item.sound, "Dialog") end
						table.insert(out, item);
					end
				end
			end
		end

		if #out > 0 then return out end
		return false

	end
	Event.on(Event.Types.MONSTER_KILL, function(data) 
		rollLoot(Event.Types.MONSTER_KILL, data.name); 
	end);
	Event.on(Event.Types.FORAGE, function(data) 
		if not rollLoot(Event.Types.FORAGE, data.name) then
			PlaySound(1142, "Dialog")
			RPText.print("You found nothing");
		end
	end);
	


end
