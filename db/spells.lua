-- Spell kits
-- These are used in both RPTexts and SpellBindings
-- Tags are not persistent, but they're added with prefix TMPSPELL_* when the event is raised
local appName, internal = ...;
local require = internal.require;

function internal.build.spells()

	local Spell = require("Spell");
	local Database = require("Database");
	local Condition = require("Condition");
	local ext = internal.ext;

	local addCond = Condition.get("is_spell_add");
	local tickCond = Condition.get("is_spell_tick");

	-- Ice
	ext:addSpell({id="Chilled", tags={"COLD"}});
	ext:addSpell({id="%Frostbolt", tags={"COLD"}});
	ext:addSpell({id="Frost Shock", tags={"COLD"}});
	ext:addSpell({id="Ice Blast", tags={"COLD"}});
	ext:addSpell({id="Frost Breath", tags={"COLD"}});
	ext:addSpell({id="Frost Cleave", tags={"COLD"}});
	
	ext:addSpell({id="Entangling Roots", tags={"ROOTS"}});
	ext:addSpell({id="Strangling Roots", tags={"ROOTS"}});
	ext:addSpell({id="Creeping Vines", tags={"ROOTS"}});
	
	
	ext:addSpell({id="Stormstrike", tags={"ELECTRIC"}});
	ext:addSpell({id="%Lightning", tags={"ELECTRIC"}});
	ext:addSpell({id="Shock", tags={"ELECTRIC"}});
	ext:addSpell({id="Zap", tags={"ELECTRIC"}});
	ext:addSpell({id="Lizard Bolt", tags={"ELECTRIC"}});
	
	ext:addSpell({id="Crystal Gaze", tags={"PETRIFY"}});
	ext:addSpell({id="Petrifying Blast", tags={"PETRIFY"}});
	ext:addSpell({id="Petrifying Stare", tags={"PETRIFY"}});
	ext:addSpell({id="Death Glare", tags={"PETRIFY"}});
	
	ext:addSpell({id="Insect Swarm", tags={"INSECTS"}});
	
	ext:addSpell({id="Void Whip", tags={"MAGIC_WHIP"}});
	
	ext:addSpell({id="Crimson Vial", tags={"SPILLABLE"}, conditions={addCond}});
	ext:addSpell({id="Bottle of Grog", tags={"SPILLABLE"}});

	ext:addSpell({id="%Sand", tags={"SAND"}});

	ext:addSpell({id="%Dirt", tags={"DIRT"}});
		
	ext:addSpell({id="%Toss", tags={"TOSSED"}});
	
	ext:addSpell({id="Shield Bash", tags={"SHIELD_BASH"}});
	
	ext:addSpell({id="Water Bolt", tags={"SLOSH"}});
	ext:addSpell({id="Slime Spray", tags={"SLOSH"}});
	ext:addSpell({id="Water Spout", tags={"SLOSH"}});
	ext:addSpell({id="Water Blast", tags={"SLOSH"}});

	ext:addSpell({id="Crystal Shards", tags={"SHARDS"}});
	ext:addSpell({id="Crystal Shard", tags={"SHARDS"}});

	-- Ground spikes
	ext:addSpell({id="Earth Spike", tags={"GROUND_SPIKE"}});

	ext:addSpell({id="Steam Blast", tags={"STEAM_BELOW"}});

	-- Generic bindings that don't add any tags
	ext:addSpell({id="Uppercut"});
	ext:addSpell({id="Headbutt"});
	ext:addSpell({id="Lashing Flurry", alias="SWING"});
	ext:addSpell({id="Flaying Vine", alias="SWING"});
	ext:addSpell({id="Bonk"});
	ext:addSpell({id="Shoot"});
	ext:addSpell({id="Lash of Pain"});
	ext:addSpell({id="Bop Barrage"});
	ext:addSpell({id="Big Bop"});
	ext:addSpell({id="Dancing Thorns"});
	ext:addSpell({id="Slitherstrike"});
	ext:addSpell({id="Icky Ink"});
	ext:addSpell({id="Willbreaker"});
	
	
	ext:addSpell({id="Quill Barb"});
	
	-- Debugging
	ext:addSpell({id="Hearthsteed", tags={"HEARTHSTEED"}});
	
	


end
