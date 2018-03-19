function EroWoW.SpellBinding:buildLibrary()
	
	local sb = EroWoW.SpellBinding;
	local R = EroWoW.R.spellBindings;
	local spellKits = EroWoW.LibAssets.spell_kits;
	-- Simple form uses RPText for everything
	table.insert(R, sb:new({
		name = "Entangling Roots",
		procChance = 1
	}))
	table.insert(R, sb:new({
		name = spellKits.ice,
		procChance = 1
	}))
	table.insert(R, sb:new({
		name = spellKits.ice_common,
		procChance = 0.1
	}))

	

	-- ROGUE --
	table.insert(R, sb:new({
		name = "Crimson Vial",
		procChance = 0.25
	}))


	-- NPC --
	table.insert(R, sb:new({
		name = spellKits.electric_common,
		procChance = 0.1
	}))
	table.insert(R, sb:new({
		name = spellKits.electric,
		procChance = 0.4
	}))
	

	table.insert(R, sb:new({
		name = spellKits.basilisk,
		procChance = 1
	}))

	table.insert(R, sb:new({
		name = "Uppercut",
		procChance = 0.5
	}))

end