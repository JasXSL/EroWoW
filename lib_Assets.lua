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
	npc_pincer["Desert Crawler"] = true
	npc_pincer["Duneclaw Burrower"] = true
	npc_pincer["Duneclaw Lasher"] = true
	npc_pincer["Duneshore Crab"] = true
	npc_pincer["Duneclaw Matriarch"] = true
	npc_pincer["Scorpid Worker"] = true
	npc_pincer["Surf Crawler"] = true
	
	
	
	-- Things that can lash you
	local npc_lasher = {}
	npc_lasher["Juvenile Bloodpetal"] = true
	npc_lasher["Writhing Terror"] = true
	npc_lasher["Bloodpetal Flayer"] = true
	npc_lasher["Bloodpetal Thresher"] = true
	npc_lasher["Bloodpetal Trapper"] = true
	
	-- Ooze type NPCs
	local npc_ooze = {}
	npc_ooze["%Ooze"] = true
	
	
	-- Similar to tentacle fiends except the flowery kind with vines
	local npc_vines = {}
	npc_vines["Juvenile Bloodpetal"] = true
	npc_vines["Bloodpetal Flayer"] = true
	npc_vines["Bloodpetal Thresher"] = true
	npc_vines["Bloodpetal Trapper"] = true
	
	
	
	local npc_wasp = {}
	npc_wasp["Hazzali Stinger"] = true
	npc_wasp["Gorishi Wasp"] = true
	


-- RPText Condition templates
ExiWoW.LibAssets.rpTextConds = {}
local rtc = ExiWoW.LibAssets.rpTextConds

	-- Random chance
	rtc.rand10 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.1}})
	rtc.rand20 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.2}})
	rtc.rand30 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.3}})
	rtc.rand40 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.4}})
	rtc.rand50 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.5}})
	rtc.rand60 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.6}})
	rtc.rand70 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.7}})
	rtc.rand80 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.8}})
	rtc.rand90 = req:new({type=ty.RTYPE_RANDOM, data={chance=0.9}})
	

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
	rtc.attackerIsWasp = req:new({type=ty.RTYPE_NAME, data=npc_wasp, sender=true})
	rtc.attackerIsLasher = req:new({type=ty.RTYPE_NAME, data=npc_lasher, sender=true})
	rtc.attackerIsVines = req:new({type=ty.RTYPE_NAME, data=npc_vines, sender=true})
	rtc.attackerIsOoze = req:new({type=ty.RTYPE_NAME, data=npc_ooze, sender=true});

	-- Underwear
	rtc.targetWearsUnderwear = req:new({type=ty.RTYPE_UNDIES, data={true}});
	
	-- AURAS
	local knockdown = {};
	table.insert(knockdown, {name="lash", caster="Bloodpetal Lasher"})
	rtc.victimKnockedDown = req:new({type = ty.RTYPE_HAS_AURA, data=knockdown});

	-- Inv items
	local feathers = {};
	table.insert(feathers, {name="Light Feather"})
	rtc.invFeathers = req:new({type=ty.RTYPE_HAS_INVENTORY, data=feathers})


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
	sk.sand = {};										-- Sandblast stuff
	sk.dirt = {};										-- Same as above but dirt
	sk.tossed_objects = {};

	-- Ice
	sk.ice_common["Chilled"]=true;
	sk.ice["Frostbolt"]=true;
 
	-- Electric
	sk.electric_common["Lightning Shield"] = true
	sk.electric["Stormstrike"] = true
	sk.electric["Lightning Bolt"] = true
	sk.electric["Chain Lightning"] = true
	sk.electric["Lightning Breath"] = true
	sk.electric["Shock"] = true

	-- Basilisk freeze
	sk.basilisk["Crystal Gaze"] = true
	sk.basilisk["Petrifying Blast"] = true
	
	-- Insect swarms
	sk.insects["Insect Swarm"] = true



	sk.spillable_add["Crimson Vial"] = true
	sk.spillable["Bottle of Grog"] = true
	
	sk.sand["Sand Breath"] = true
	
	sk.dirt["Throw Dirt"] = true
	

	sk.tossed_objects["Bone Toss"] = true




-- Foraging
	ExiWoW.LibAssets.foraging = {};
	local f = ExiWoW.LibAssets.foraging
	-- Syntax:
	--[[
		{
			MajorZone = {
				Subzone = {
					{
						type = "Underwear",
						id = id,
						text = rpText object (both targ and caster will be you),
						chance = 0-1,
						sound = successSoundID
					}
				}
			}
		}

		Setting Subzone to * will be used for all subzones within the major zone
	]]


	f["Durotar"] = {}
	f["Durotar"]["Razor Hill"] = {
		{
			type = "Underwear", 
			id = "ORCISH_BRIEFS", 
			chance = 1,
			sound = 44577,
			text = ExiWoW.RPText:new({
				text_receiver = "You find some orcish briefs in a crate. They seem unused!"
			})
		}
	}
