-- RPText Condition templates
ExiWoW.LibAssets.rpTextConds = {}
local rtc = ExiWoW.LibAssets.rpTextConds
local npc = ExiWoW.LibAssets.npcs
local req = ExiWoW.RPText.Req;	-- RPText requirement constructor
local ty = req.Types;			-- Local filter types

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
	rtc.attackerHumanoidish = req:new({ type = ty.RTYPE_TYPE, sender = true, data = {Humanoid = true, Undead = true, Demon=true} })

	rtc.victimBreasts = req:new({type = ty.RTYPE_HAS_BREASTS})
	rtc.victimPenis = req:new({type = ty.RTYPE_HAS_PENIS})
	rtc.victimVagina = req:new({type = ty.RTYPE_HAS_VAGINA})
	
	rtc.spellAdd = req:new({type=ty.RTYPE_SPELL_ADD})
	rtc.spellRem = req:new({type=ty.RTYPE_SPELL_REM})
	rtc.spellTick = req:new({type=ty.RTYPE_SPELL_TICK})
	rtc.spellAddOrTick = {rtc.spellAdd, rtc.spellTick};
	
	-- NPC Name conditions
	rtc.attackerIsTentacleFiend = req:new({type=ty.RTYPE_NAME, data=npc.tentacleFiend, sender=true})
	rtc.attackerIsPinchy = req:new({type=ty.RTYPE_NAME, data=npc.pincer, sender=true})
	rtc.attackerIsWasp = req:new({type=ty.RTYPE_NAME, data=npc.wasp, sender=true})
	rtc.attackerIsLasher = req:new({type=ty.RTYPE_NAME, data=npc.lasher, sender=true})
	rtc.attackerIsVines = req:new({type=ty.RTYPE_NAME, data=npc.vines, sender=true})
	rtc.attackerIsOoze = req:new({type=ty.RTYPE_NAME, data=npc.ooze, sender=true});

	
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

	-- Armor
	rtc.chestPlate = req:new({type=ty.RTYPE_EQUIPMENT, data={slot=5, type="Plate"}})
	rtc.crotchPlate = req:new({type=ty.RTYPE_EQUIPMENT, data={slot=7, type="Plate"}})
	
