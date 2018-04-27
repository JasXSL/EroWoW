-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.npcs()

	local NPC = require("NPC");
	local Database = require("Database");
	local ext = internal.ext;

	ext:addNPC({id="Writhing Terror",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Fiendling Flesh Beast",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Fleshfiend",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Parasitic Fleshbeast",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Nightmare Terror",tags={"TENTACLE_FIEND", "LASHER"}});
	ext:addNPC({id="Shadowfiend",tags={"TENTACLE_FIEND", "LASHER"}});


	ext:addNPC({id="%Scorpid",tags={"PINCHY"}});
	ext:addNPC({id="Desert Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Duneclaw Burrower",tags={"PINCHY"}});
	ext:addNPC({id="Duneclaw Lasher",tags={"PINCHY"}});
	ext:addNPC({id="Duneshore Crab",tags={"PINCHY"}});
	ext:addNPC({id="Duneclaw Matriarch",tags={"PINCHY"}});
	ext:addNPC({id="Scorpid Worker",tags={"PINCHY"}});
	ext:addNPC({id="%Surf Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Silt Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Clattering Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Spined Crawler",tags={"PINCHY"}});
	ext:addNPC({id="%Makrura",tags={"PINCHY"}});
	ext:addNPC({id="%Mak'Rana",tags={"PINCHY"}});
	ext:addNPC({id="King Azureback",tags={"PINCHY"}});
	ext:addNPC({id="Moonshell Crawler",tags={"PINCHY"}});
	ext:addNPC({id="Skittering Doomstinger",tags={"PINCHY"}});
	ext:addNPC({id="%Scorpashi",tags={"PINCHY"}});
	ext:addNPC({id="%Bogstrok",tags={"PINCHY"}});
	ext:addNPC({id="%Drysnap",tags={"PINCHY"}});
	ext:addNPC({id="Deepwater Spikeback",tags={"PINCHY"}});
	ext:addNPC({id="Coastal Spikeback",tags={"PINCHY"}});
	ext:addNPC({id="Leyscar Scuttler",tags={"PINCHY"}});
	
	
	ext:addNPC({id="Feltotem Warmonger",tags={"FELTOTEM"}, gender=2});
	ext:addNPC({id="Feltotem Bloodsinger",tags={"FELTOTEM"}, gender=2});
	ext:addNPC({id="Torok Bloodtotem",tags={"FELTOTEM"}, gender=2});
	
	ext:addNPC({id="%Thistlefur",tags={"FURBOLG"}});
	ext:addNPC({id="%Deadwood",tags={"FURBOLG"}});
	ext:addNPC({id="%Winterfall",tags={"FURBOLG"}});

	ext:addNPC({id="%Harpy",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Witchwood Hag",tags={"HARPY"}, gender=3});
	ext:addNPC({id="%Crawliac",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Ragi the Hexxer",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Agara Deathsong",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Ugla the Hag",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Screeching Hag-Sister",tags={"HARPY"}, gender=3});
	ext:addNPC({id="Screeching Harridan",tags={"HARPY"}, gender=3});
	
	ext:addNPC({id="Jadefire Felsworn",tags={"SATYR"}, gender=2});
	ext:addNPC({id="Jadefire Rogue",tags={"SATYR"}, gender=2});
	ext:addNPC({id="%Satyr",tags={"SATYR"}, gender=2});
	
	ext:addNPC({id="%Bloodpetal",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Bloodpetal Flayer",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Gloomshade Blossom",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Uprooted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Corrupted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Uprooted Lasher",tags={"LASHER", "VINES"}});
	ext:addNPC({id="Lashvine",tags={"LASHER", "VINES"}});
	ext:addNPC({id="%Lasher",tags={"LASHER"}});

	ext:addNPC({id="Nether Maiden",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Salia",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Moora",tags={"SUCCUBUS", "LASHER"}, gender=3});
	ext:addNPC({id="Sister of Grief",tags={"SUCCUBUS", "LASHER"}, gender=3});

	ext:addNPC({id="%Ooze",tags={"OOZE"}});
	ext:addNPC({id="%Slime",tags={"OOZE"}});
	ext:addNPC({id="%Sludge",tags={"OOZE"}});
	ext:addNPC({id="Boiling Springbubble",tags={"OOZE"}});

	

	ext:addNPC({id="Hazzali Stinger",tags={"SILITHID", "WASP"}});
	ext:addNPC({id="Gorishi Wasp",tags={"SILITHID", "WASP"}});
	


	-- World containers can also use tags
	

end