local appName, internal = ...
local require = internal.require;

function internal.build.spellBindings()
	
	local sb = require("SpellBinding");
	local R = ExiWoW.R;
	local spellKits = ExiWoW.LibAssets.spell_kits;

	R:addSpellBinding({
		name = spellKits.roots,
		procChance = 1
	})


	-- Simple form uses RPText for everything
	R:addSpellBinding({
		name = spellKits.roots,
		procChance = 1
	})
	R:addSpellBinding({
		name = spellKits.ice,
		procChance = 1
	})
	R:addSpellBinding({
		name = spellKits.ice_common,
		procChance = 0.1
	})

	

	-- Spillable
	R:addSpellBinding({
		name = spellKits.spillable,
		procChance = 0.25
	})
	R:addSpellBinding({
		name = spellKits.spillable_add,
		procChance = 0.25
	})


	-- NPC --
	R:addSpellBinding({
		name = spellKits.electric_common,
		procChance = 0.1
	})
	R:addSpellBinding({
		name = spellKits.electric,
		procChance = 0.4
	})
	

	R:addSpellBinding({
		name = spellKits.basilisk,
		procChance = 1
	})

	R:addSpellBinding({
		name = "Uppercut",
		procChance = 0.5
	})

	R:addSpellBinding({
		name = "Headbutt",
		procChance = 0.5
	})

	R:addSpellBinding({
		name = spellKits.insects,
		procChance = 0.5
	})

	R:addSpellBinding({
		name = spellKits.sand,
		procChance = 0.5
	})
	R:addSpellBinding({
		name = spellKits.dirt,
		procChance = 0.5
	})

	R:addSpellBinding({
		name = "Bone Toss",
		procChance = 0.5
	})

	-- Lasher in ungoro
	R:addSpellBinding({
		name = "Lashing Flurry",
		alias = "SWING",
		procChance = 0.25
	})
	R:addSpellBinding({
		name = "Flaying Vine",
		alias = "SWING",
		procChance = 0.5
	})

	-- Bash
	R:addSpellBinding({
		name = spellKits.shield_bash,
		procChance = 0.5
	})

	R:addSpellBinding({
		name = spellKits.slosh,
		procChance = 1
	})

	R:addSpellBinding({
		name = "Bonk",
		procChance = 0.4
	})

	R:addSpellBinding({
		name = "Shoot",
		procChance = 0.1
	})

	R:addSpellBinding({
		name = "Lash of Pain",
		procChance = 0.5
	})
	
	R:addSpellBinding({
		name = spellKits.shards,
		procChance = 0.05
	})

	R:addSpellBinding({
		name = "Bop Barrage",
		procChance = 0.05
	})
	R:addSpellBinding({
		name = "Big Bop",
		procChance = 0.5
	})

	R:addSpellBinding({
		name = "Dancing Thorns",
		procChance = 0.05
	})

	R:addSpellBinding({
		name = "Slitherstrike",
		procChance = 0.25
	})

	R:addSpellBinding({
		name = spellKits.magicWhip,
		procChance = 0.5
	})
	
	R:addSpellBinding({
		name = spellKits.groundSpike,
		procChance = 0.5
	})

	R:addSpellBinding({
		name = spellKits.steam_below,
		procChance = 0.25,
	})

	
end