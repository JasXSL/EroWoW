local appName, internal = ...;
local require = internal.require;

local RPText = require("RPText")

-- LOOT TABLES --
local zones = ExiWoW.LibAssets.zones
local npc = ExiWoW.LibAssets.npcs

-- Loot tables
	ExiWoW.LibAssets.loot = {};
local f = ExiWoW.LibAssets.loot
	-- Syntax:
	--[[
		{
			{
				zone=ZoneName|ZoneNames|nil, 
				sub=SubZone|SubZones|nil, 
				name=npcname|npcnames|_FORAGE_|nil,
				points = {{x = xCoord, y=yCoord, rad=radius}...} OR nil, (You can use the pace ability to detect coordinates)
				items={{
					type = "Underwear" | "Charges",
					id = assetID,
					text = rpTextObject, (caster will be you, target will be the NPC on kill, otherwise you. For this you can use special tags %Q for nr items, and %Qs which returns "" if 1, otherwise "s")
					chance = 0-1,
					quant = 1,			-- Min quantity
					quantRand = 0,		-- Quantity to randomize on top of quant
					sound = successSoundID,
				}...}}
			...
		}
	]]
	local kultirasBoxers = {}
	kultirasBoxers["Sergeant Curtis"] = true
	kultirasBoxers["Lieutenant Palliter"] = true
	table.insert(f, {
		zone = "Durotar",
		name = kultirasBoxers,
		items = {
			{
				type = "Underwear", 
				id = "KULTIRAS_BOXERS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a folded pair of %item that %T was carrying!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Blade's Edge Mountains",
		name = "%Razaani",
		items = {
			{
				type = "Underwear", 
				id = "RAZAANI_SOULTHONG", 
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "%T was holding a small gem studded garment, you decide to hold on to it!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Netherstorm",
		name = "Spellreaver Marathelle",
		items = {
			{
				type = "Underwear", 
				id = "BLACK_LACE_PANTIES", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find some small black lace panties hidden in one of %T's pockets!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Netherstorm",
		name = "Summoner Kanthin",
		items = {
			{
				type = "Underwear", 
				id = "BLACK_LACE_SHORTS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find some small black lace shorts hidden in one of %T's pockets!"
				})
			}
		}
	})

	-- Furbolg drops
	table.insert(f, {
		name = npc.furbolg,
		items = {
			{
				type = "Underwear", 
				id = "FURBOLG_LOINCLOTH", 
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a spare loincloth on the defeated furbolg!"
				})
			}
		}
	})

	-- Satyr drops
	table.insert(f, {
		name = npc.satyr,
		items = {
			{
				type = "Underwear",
				id = "FELCLOTH_PANTIES",
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "The satyr was holding onto a small pair of felcloth panties!"
				})
			}
		}
	})

	table.insert(f, {
		name = npc.harpy,
		items = {
			{
				type = "Underwear",
				id = "JEWELED_HARPY_THONG",
				chance = 0.1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found an extra piece of underwear on the harpy!"
				})
			}
		}
	})


	-- Foraged loot
	table.insert(f, {
		zone = "Durotar",
		sub = "Razor Hill",
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "ORCISH_BRIEFS", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find some orcish briefs in a crate. They seem unused!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Mount Hyjal",
		sub = "The Forge of Supplication",
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "TWILIGHT_BRIEFS", 
				chance = 0.5,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a box of surplus twilight briefs."
				})
			}
		}
	})

	table.insert(f, {
		zone = "Azsuna",
		sub = "Runas's Hovel",
		points = {
			{x = 42.84, y=17.36, rad=0.1},
		},
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "MANA_GEM_THONG", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a sparkling thong emanating mana. Embroidered into the waist is the word \"Elisande\". Maybe that has something to do with Runas' exile."
				})
			}
		}
	})

	table.insert(f, {
		zone = "Azsuna",
		sub = "Lair of the Deposed",
		points = {
			{x = 49.49, y=8.1, rad=0.11},
		},
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "ARCHMAGE_BRIEFS", 
				chance = 1,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You found a pair of underwear that look like they may have belonged to a Kirin Tor archmage. 'Deposed' indeed."
				})
			}
		}
	})


	
	

	table.insert(f, {
		zone = "Feralas",
		sub = "Woodpaw Den",
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "SPIKED_LEATHER_JOCKSTRAP", 
				chance = 0.5,
				sound = 44577,
				text = RPText:new({
					text_receiver = "You find a discarded spiked leather jockstrap. These gnolls must be up to some weird stuff."
				})
			}
		}
	})


	table.insert(f, {
		zone = "Burning Steppes",
		sub = "The Skull Warren",
		name = "_FORAGE_",
		items={
			{
				type = "Underwear", 
				id = "SKULL_STRAP", 
				chance = 0.5,
				sound = 1199,
				text = RPText:new({
					text_receiver = "You find a skull with waist straps tucked away under some mushrooms"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Felwood",
		sub = "Whisperwind Grove",
		name = "_FORAGE_",
		points = {
			{x = 45.06, y=29.37, rad=0.06},
		},
		items={
			{
				type = "Underwear", 
				id = "LEAF_PANTIES", 
				chance = 1,
				sound = 911,
				text = RPText:new({
					text_receiver = "You sneakily look through the drawer, finding a pair of leafy panties. These must belong to Innkeeper Wylaria. You hastily pocket them."
				})
			}
		}
	})

	table.insert(f, {
		zone = "Winterspring",
		sub = "Everlook",
		name = "_FORAGE_",
		points = {
			{x = 59.21, y=50.16, rad=0.1},
			{x = 59.01, y=50.19, rad=0.14},
			{x = 60.18, y=50.54, rad=0.09},
			{x = 60.59, y=50.16, rad=0.29},
			
		},
		items={
			{
				type = "Underwear", 
				id = "WOOLY_SHORTS", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You found a crate of wooly shorts. Hopefully nobody will mind if a pair goes missing."
				})
			}
		}
	})

	
	
	table.insert(f, {
		zone = zones.sandy,
		name = "_FORAGE_",
		items={
			{
				type = "Charges", 
				id = "THROW_SAND", 
				chance = 0.8,
				sound = 73172,
				text = RPText:new({
					text_receiver = "You found a handful of sand!"
				})
			}
		}
	})
	table.insert(f, {
		sub = "%Strand",
		name = "_FORAGE_",
		items={
			{
				type = "Charges", 
				id = "THROW_SAND", 
				chance = 0.8,
				sound = 73172,
				text = RPText:new({
					text_receiver = "You found a handful of sand!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Swamp of Sorrows",
		sub = "Bogpaddle",
		name = "_FORAGE_",
		points = {
			{x = 72.41, y=16.89, rad=0.22},
			{x = 72.39, y=12.77, rad=0.32},
		},
		items={
			{
				type = "Underwear", 
				id = "HIGH_RISING_BIKINI_THONG_PINK", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find a crate of pink bikini thongs, hopefully nobody will notice if one goes missing!"
				})
			}
		}
	})

	table.insert(f, {
		zone = "Hellfire Peninsula",
		name = "_FORAGE_",
		points = {
			{x = 22.13, y=68.27, rad=0.1},
		},
		items={
			{
				type = "Underwear", 
				id = "NETHERWEAVE_PANTIES", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "You find a skimpy pair of netherweave panties that seem to have been left behind!"
				})
			}
		}
	})

	-- Crescent thong
	table.insert(f, {
		zone = "Zangarmarsh",
		name = "_FORAGE_",
		points = {
			{x = 23.41, y=66.33, rad=0.08},
		},
		items={
			{
				type = "Underwear", 
				id = "CRESCENT_THONG", 
				chance = 1,
				sound = 1185,
				text = RPText:new({
					text_receiver = "While Leesah'oh isn't watching, you snatch one of her panties from a crate in her tent!"
				})
			}
		}
	})

	table.insert(f, {
		name = npc.pincer,
		items={
			{
				type = "Charges", 
				id = "CLAW_PINCH", 
				chance = 0.05,
				quant = math.huge,
				text = RPText:new({
					text_receiver = "This big claw is pristine! I'll polish it and take it with me!"
				})
			}
		}
	})


	

