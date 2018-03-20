-- Library of common reusable assets
ExiWoW.LibAssets = {}
local req = ExiWoW.RPText.Req;	-- RPText requirement constructor
local ty = req.Types;			-- Local filter types

-- When used in rp texts, they need to be prefixed with SPELL_
function ExiWoW.LibAssets.spellKitToRP(...)
	local kits = {...}
	local out = {}
	for k,kit in pairs(kits) do
		local input = ExiWoW.LibAssets.spell_kits[kit];
		for i,v in pairs(input) do
			local tx = "SPELL_"..i;
			out[tx] = true
		end
	end
	return out;
end






-- Effect templates, such as adding arousal
ExiWoW.LibAssets.effects = {}
local ef = ExiWoW.LibAssets.effects;

	ef.addExcitementMasochisticDefault = function(self)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	ef.addExcitementMasochisticCrit = function(self)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	ef.addExcitementDefault = function(self)
		ExiWoW.ME:addExcitement(0.1);
	end
	ef.addExcitementCrit = function(self)
		ExiWoW.ME:addExcitement(0.2);
	end


-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
	local npc_tentacleFiend = {}
	npc_tentacleFiend["Writhing Terror"] = true;

	-- NPCs that can pinch
	local npc_pincer = {}
	npc_pincer["%Scorpid"] = true

-- RPText Condition templates
ExiWoW.LibAssets.rpTextConds = {}
local rtc = ExiWoW.LibAssets.rpTextConds
	-- Humanoid NPC attacker
	rtc.attackerHumanoid = req:new({type = ty.RTYPE_TYPE,sender = true,data = {Humanoid = true}})
	-- Includes other viable humanoid types like undeads
	rtc.attackerHumanoidish = req:new({ type = ty.RTYPE_TYPE, sender = true, data = {Humanoid = true, Undead = true} })

	rtc.victimBreasts = req:new({type = ty.RTYPE_HAS_BREASTS})
	rtc.victimPenis = req:new({type = ty.RTYPE_HAS_PENIS})
	rtc.victimVagina = req:new({type = ty.RTYPE_HAS_VAGINA})

	rtc.spellAdd = req:new({type=ty.RTYPE_SPELL_ADD})
	rtc.spellRem = req:new({type=ty.RTYPE_SPELL_REM})
	rtc.spellTick = req:new({type=ty.RTYPE_SPELL_TICK})
	rtc.spellAddOrTick = {rtc.spellAdd, rtc.spellTick};
	
	-- NPC Name conditions
	rtc.attackerIsTentacleFiend = req:new({type=ty.RTYPE_NAME, data=npc_tentacleFiend, sender=true})
	rtc.attackerIsPinchy = req:new({type=ty.RTYPE_NAME, data=npc_pincer, sender=true})
		




-- Spell kits
-- These are used in both RPTexts and SpellBindings
ExiWoW.LibAssets.spell_kits = {}
local sk = ExiWoW.LibAssets.spell_kits;
	sk.ice = {}											-- Ice/Cold
	sk.ice_common = {}
	sk.electric = {};										-- Electric shocks
	sk.electric_common = {};
	sk.basilisk = {};										-- Basilisk stare stuns
	sk.insects = {};
	sk.spillable = {};									-- Liquids that can spill on a player, bottles, potions etc
	sk.spillable_add = {};								-- Same as above, but for long term buff adds, above is ticking

	-- Ice
	sk.ice_common["Chilled"]=true;
	sk.ice["Frostbolt"]=true;
 
	-- Electric
	sk.electric_common["Lightning Shield"] = true
	sk.electric["Stormstrike"] = true
	sk.electric["Lightning Bolt"] = true
	sk.electric["Chain Lightning"] = true

	-- Basilisk freeze
	sk.basilisk["Crystal Gaze"] = true
	sk.basilisk["Petrifying Blast"] = true
	
	-- Insect swarms
	sk.insects["Insect Swarm"] = true


	sk.spillable_add["Crimson Vial"] = true
	sk.spillable["Bottle of Grog"] = true
	
