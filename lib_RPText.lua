function ExiWoW.RPText:buildLibrary()
	
	
	local assetLib = ExiWoW.LibAssets;
	local spellKits = assetLib.spell_kits;		-- RP Text spell kits library
	local rtc = ExiWoW.LibAssets.rpTextConds;	-- RP Text conditions
	local ef = ExiWoW.LibAssets.effects;		-- RP Text effects library
	
	-- Root extension
	local R = ExiWoW.R.rpTexts;
	

	-- Gets a formatted spell kit from lib_Assets (or more)
	-- A spell kit is a collection of spell names that share the same theme, such as frost, fire, basilisk stun etc
	local getsk = ExiWoW.LibAssets.spellKitToRP;
		
	-- Only PG stuff in here
	
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


end