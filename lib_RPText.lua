function ExiWoW.RPText:buildLibrary()
	
	local req = ExiWoW.RPText.Req;	-- RPText requirement constructor
	local ty = req.Types;			-- Local filter types
	local assetLib = ExiWoW.LibAssets;
	local spellKits = assetLib.spell_kits;		-- RP Text spell kits library
	local rtc = ExiWoW.LibAssets.rpTextConds;	-- RP Text conditions
	local ef = ExiWoW.LibAssets.effects;		-- RP Text effects library
	
	-- Root extension
	local R = ExiWoW.R.rpTexts;
	

	-- Gets a formatted spell kit from lib_Assets (or more)
	-- A spell kit is a collection of spell names that share the same theme, such as frost, fire, basilisk stun etc
	local getsk = ExiWoW.LibAssets.spellKitToRP;
		
	-- Only wholesome family friendly PG stuff in here

	-- Tickle target
	table.insert(R, ExiWoW.RPText:new({
		id = "TICKLE",
		text_sender = "You tickle %T!",
		text_receiver = "%T tickles you!",
		requirements = {},
	}))
	table.insert(R, ExiWoW.RPText:new({
		id = "TICKLE",
		text_sender = "You tickle %T with your %item!",
		text_receiver = "%S tickles you with %Shis %item!",
		requirements = {rtc.invFeathers},
	}))

	-- Tickle self
	table.insert(R, ExiWoW.RPText:new({
		id = "TICKLE",
		text_receiver = "You tickle yourself!",
		requirements = {},
		--fn = ef.addExcitementMasochisticDefault
	}))
	table.insert(R, ExiWoW.RPText:new({
		id = "TICKLE",
		text_receiver = "You use your %item to tickle yourself!",
		requirements = {rtc.invFeathers},
		--fn = ef.addExcitementMasochisticDefault
	}))

	-- Wedgie
	table.insert(R, ExiWoW.RPText:new({
		id = "WEDGIE",
		text_sender = "You grab a hold of %T's %Tundies a wedgie!",
		text_receiver = "%S grabs a hold of your %Tundies, giving you a wedgie!",
		sound = 25626,
		requirements = {},
		--fn = ef.addExcitementMasochisticDefault
	}))

	table.insert(R, ExiWoW.RPText:new({
		id = "WEDGIE",
		text_receiver = "You grab a hold of your %Tundies and give yourself a wedgie!",
		sound = 25626,
		requirements = {rtc.targetWearsUnderwear},
		--fn = ef.addExcitementMasochisticDefault
	}))
	

	-- Insect swarm
	table.insert(R, ExiWoW.RPText:new({
		id = getsk("insects"),
		text_receiver = "The insects get into your equipment, skittering across your body!",
		--sound = 35103,
		requirements = {rtc.spellAdd},
		fn = ef.addExcitementDefault
	}))

	-- Sand ADD
	table.insert(R, ExiWoW.RPText:new({
		id = getsk("sand"),
		text_receiver = "Sand gets into your clothes!",
		--sound = 35103,
		requirements = {rtc.spellAdd},
		fn = ef.addExcitementMasochisticDefault
	}))

	table.insert(R, ExiWoW.RPText:new({
		id = getsk("dirt"),
		text_receiver = "Some dirt gets into your clothes!",
		--sound = 35103,
		requirements = {rtc.spellTick},
		fn = ef.addExcitementMasochisticDefault
	}))

	table.insert(R, ExiWoW.RPText:new({
		id = "THROW_SAND",
		text_receiver = "You throw sand into the air, some of which falls back down on you and into your clothes!",
		sound = 73172,
		requirements = {}
	}))

	table.insert(R, ExiWoW.RPText:new({
		id = "THROW_SAND",
		text_sender = "You throw a handful of sand at %T!",
		text_sender = "%S throws a handful of sand at you!",
		sound = 907,
		requirements = {}
	}))

end