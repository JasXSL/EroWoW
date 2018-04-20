local appName, internal = ...;
local require = internal.require;

-- RPText Condition templates
ExiWoW.LibAssets.rpTextConds = {}
local rtc = ExiWoW.LibAssets.rpTextConds
local npc = ExiWoW.LibAssets.npcs
local Condition = require("Condition");	-- RPText requirement constructor
local ty = Condition.Types;				-- Local filter types

	-- Random chance
	rtc.rand10 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.1}})
	rtc.rand20 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.2}})
	rtc.rand30 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.3}})
	rtc.rand40 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.4}})
	rtc.rand50 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.5}})
	rtc.rand60 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.6}})
	rtc.rand70 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.7}})
	rtc.rand80 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.8}})
	rtc.rand90 = Condition:new({type=ty.RTYPE_RANDOM, data={chance=0.9}})
	

	-- Humanoid NPC attacker
	rtc.attackerHumanoid = Condition:new({type = ty.RTYPE_TYPE,sender = true,data = {Humanoid = true}})
	-- Includes other viable humanoid types like undeads
	rtc.attackerHumanoidish = Condition:new({ type = ty.RTYPE_TYPE, sender = true, data = {Humanoid = true, Undead = true, Demon=true} })

	rtc.victimBreasts = Condition:new({type = ty.RTYPE_HAS_BREASTS})
	rtc.victimPenis = Condition:new({type = ty.RTYPE_HAS_PENIS})
	rtc.victimVagina = Condition:new({type = ty.RTYPE_HAS_VAGINA})

	rtc.attackerBreasts = Condition:new({type = ty.RTYPE_HAS_BREASTS, sender=true})
	rtc.attackerPenis = Condition:new({type = ty.RTYPE_HAS_PENIS, sender=true})
	rtc.attackerVagina = Condition:new({type = ty.RTYPE_HAS_VAGINA, sender=true})

	rtc.largeBreasts = Condition:new({type = ty.RTYPE_BREASTS_GREATER, data={2}});
	rtc.largePenis = Condition:new({type = ty.RTYPE_PENIS_GREATER, data={2}});
	rtc.largeButt = Condition:new({type = ty.RTYPE_BUTT_GREATER, data={2}});
	
	
	
	rtc.spellAdd = Condition:new({type=ty.RTYPE_SPELL_ADD})
	rtc.spellRem = Condition:new({type=ty.RTYPE_SPELL_REM})
	rtc.spellTick = Condition:new({type=ty.RTYPE_SPELL_TICK})
	rtc.spellAddOrTick = {rtc.spellAdd, rtc.spellTick};
	
	-- NPC Name conditions
	rtc.attackerIsTentacleFiend = Condition:new({type=ty.RTYPE_NAME, data=npc.tentacleFiend, sender=true})
	rtc.attackerIsPinchy = Condition:new({type=ty.RTYPE_NAME, data=npc.pincer, sender=true})
	rtc.attackerIsWasp = Condition:new({type=ty.RTYPE_NAME, data=npc.wasp, sender=true})
	rtc.attackerIsLasher = Condition:new({type=ty.RTYPE_NAME, data=npc.lasher, sender=true})
	rtc.attackerIsVines = Condition:new({type=ty.RTYPE_NAME, data=npc.vines, sender=true})
	rtc.attackerIsOoze = Condition:new({type=ty.RTYPE_NAME, data=npc.ooze, sender=true});
	rtc.attackerIsFeltotemMale = Condition:new({type=ty.RTYPE_NAME, data=npc.feltotemMale, sender=true});

	rtc.maleWhispers = Condition:new({type=ty.RTYPE_REQUIRE_MALE})
	rtc.femaleWhispers = Condition:new({type=ty.RTYPE_REQUIRE_FEMALE})
	rtc.otherWhispers = Condition:new({type=ty.RTYPE_REQUIRE_OTHER})
	

	
	-- Underwear
	rtc.targetWearsUnderwear = Condition:new({type=ty.RTYPE_UNDIES, data={true}});
	
	-- AURAS
	local knockdown = {};
	table.insert(knockdown, {name="lash", caster="Bloodpetal Lasher"})
	rtc.victimKnockedDown = Condition:new({type = ty.RTYPE_HAS_AURA, data=knockdown});
	local paralysis = {};
	table.insert(paralysis, {name="Paralysis"});
	rtc.victimParalyzed = Condition:new({type = ty.RTYPE_HAS_AURA, data=paralysis});
	

	-- Inv items
	local feathers = {};
	table.insert(feathers, {name="Light Feather"})
	rtc.invFeathers = Condition:new({type=ty.RTYPE_HAS_INVENTORY, data=feathers})

	-- Armor
	rtc.chestPlate = Condition:new({type=ty.RTYPE_EQUIPMENT, data={slot=5, type="Plate"}})
	rtc.crotchPlate = Condition:new({type=ty.RTYPE_EQUIPMENT, data={slot=7, type="Plate"}})

	
