function ExiWoW.RPText:buildLibrary()
	
	
	local assetLib = ExiWoW.LibAssets;
	local spellKits = assetLib.spell_kits;		-- RP Text spell kits library
	local rtc = ExiWoW.LibAssets.rpTextConds;	-- RP Text conditions
	local ef = ExiWoW.LibAssets.effects;		-- RP Text effects library
	
	-- Root extension
	local R = ExiWoW.R.rpTexts;
	

	-- Gets a formatted spell kit from lib_Assets (or more)
	-- A spell kit is a collection of spell names that share the same theme, such as frost, fire, basilisk stun etc
	local getsk = function(...)
		return ExiWoW.LibAssets:spellKitToRP(...);
	end

	
	-- Only PG stuff in here


end