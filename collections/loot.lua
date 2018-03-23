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
					text = rpTextObject, (caster will be you, target will be the NPC on kill, otherwise you)
					chance = 0-1,
					quant = 1,
					sound = successSoundID
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
				text = ExiWoW.RPText:new({
					text_receiver = "You found a folded pair of %item that %T was carrying!"
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
				text = ExiWoW.RPText:new({
					text_receiver = "You find some orcish briefs in a crate. They seem unused!"
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
				text = ExiWoW.RPText:new({
					text_receiver = "You find a skull with waist straps tucked away under some mushrooms"
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
				text = ExiWoW.RPText:new({
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
				text = ExiWoW.RPText:new({
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
				text = ExiWoW.RPText:new({
					text_receiver = "You find a crate of pink bikini thongs, hopefully nobody will notice if one goes missing!"
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
				text = ExiWoW.RPText:new({
					text_receiver = "This big claw is pristine! I'll polish it and take it with me!"
				})
			}
		}
	})


	

