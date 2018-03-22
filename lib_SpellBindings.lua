function ExiWoW.SpellBinding:buildLibrary()
	
	local sb = ExiWoW.SpellBinding;
	local R = ExiWoW.R.spellBindings;
	local spellKits = ExiWoW.LibAssets.spell_kits;
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

	

	-- Spillable
	table.insert(R, sb:new({
		name = spellKits.spillable,
		procChance = 0.25
	}))
	table.insert(R, sb:new({
		name = spellKits.spillable_add,
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

	table.insert(R, sb:new({
		name = "Headbutt",
		procChance = 0.5
	}))

	table.insert(R, sb:new({
		name = spellKits.insects,
		procChance = 0.5
	}))

	table.insert(R, sb:new({
		name = spellKits.sand,
		procChance = 0.5
	}))
	table.insert(R, sb:new({
		name = spellKits.dirt,
		procChance = 0.5
	}))

	table.insert(R, sb:new({
		name = "Bone Toss",
		procChance = 0.5
	}))

	-- Lasher in ungoro
	table.insert(R, sb:new({
		name = "Lashing Flurry",
		alias = "SWING",
		procChance = 0.25
	}))
	table.insert(R, sb:new({
		name = "Flaying Vine",
		alias = "SWING",
		procChance = 0.5
	}))

	-- Bash
	table.insert(R, sb:new({
		name = spellKits.shield_bash,
		procChance = 0.5
	}))

	table.insert(R, sb:new({
		name = spellKits.slosh,
		procChance = 1
	}))
	

end