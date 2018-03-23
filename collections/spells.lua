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
	sk.shield_bash = {}
	sk.slosh = {}										-- Sloshing things, like water bolt

	-- Ice
	sk.ice_common["Chilled"]=true;
	sk.ice["Frostbolt"]=true;
 
	-- Electric
	sk.electric["Stormstrike"] = true
	sk.electric["%Lightning"] = true
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

	-- Shield bash
	sk.shield_bash["Shield Bash"] = true

	-- Slosh
	sk.slosh["Water Bolt"] = true





