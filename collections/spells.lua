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
	sk.shards = {}										-- Small shards
	sk.magicWhip = {}									-- Such as void whip, detached whips
	sk.groundSpike = {}									-- Earth spike etc
	sk.roots = {}

	-- Ice
	sk.ice_common["Chilled"]=true;
	sk.ice["%Frostbolt"]=true;
	sk.ice["Frost Shock"]=true;
	sk.ice["Ice Blast"]=true;
	sk.ice["Frost Breath"]=true;
	sk.ice["Frost Cleave"]=true;
	
	
	-- Roots
	sk.roots["Entangling Roots"] = true
	sk.roots["Strangling Roots"] = true
	
 
	-- Electric
	sk.electric["Stormstrike"] = true
	sk.electric["%Lightning"] = true
	sk.electric["Shock"] = true
	sk.electric["Zap"] = true
	sk.electric["Lizard Bolt"] = true
	
	

	-- Basilisk freeze
	sk.basilisk["Crystal Gaze"] = true
	sk.basilisk["Petrifying Blast"] = true
	sk.basilisk["Petrifying Stare"] = true
	
	
	-- Insect swarms
	sk.insects["Insect Swarm"] = true

	-- Magic whips
	sk.magicWhip["Void Whip"] = true


	sk.spillable_add["Crimson Vial"] = true
	sk.spillable["Bottle of Grog"] = true
	
	sk.sand["Sand Breath"] = true
	
	sk.dirt["Throw Dirt"] = true
	

	sk.tossed_objects["Bone Toss"] = true

	-- Shield bash
	sk.shield_bash["Shield Bash"] = true

	-- Slosh
	sk.slosh["Water Bolt"] = true
	sk.slosh["Slime Spray"] = true
	sk.slosh["Water Spout"] = true
	
	-- Small shards
	sk.shards["Crystal Shards"] = true

	-- Ground spikes
	sk.groundSpike["Earth Spike"] = true

	-- Steam blast from below
	local steam_below = {}
	sk.steam_below = steam_below
	steam_below["Steam Blast"] = true
	



