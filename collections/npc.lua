-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
ExiWoW.LibAssets.npcs = {}
local npcs = ExiWoW.LibAssets.npcs

	local npc_tentacleFiend = {}
	npc_tentacleFiend["Writhing Terror"] = true;
	npc_tentacleFiend["Fiendling Flesh Beast"] = true;
	

	-- NPCs that can pinch
	local npc_pincer = {}
	npcs.pincer = npc_pincer

	npc_pincer["%Scorpid"] = true
	npc_pincer["Desert Crawler"] = true
	npc_pincer["Duneclaw Burrower"] = true
	npc_pincer["Duneclaw Lasher"] = true
	npc_pincer["Duneshore Crab"] = true
	npc_pincer["Duneclaw Matriarch"] = true
	npc_pincer["Scorpid Worker"] = true
	npc_pincer["%Surf Crawler"] = true
	npc_pincer["Silt Crawler"] = true
	npc_pincer["Clattering Crawler"] = true
	npc_pincer["Spined Crawler"] = true
	npc_pincer["%Makrura"] = true
	npc_pincer["Moonshell Crawler"] = true
	
	

	local furbolg = {}
	npcs.furbolg = furbolg
	furbolg["%Thistlefur "] = true
	
	
	
	-- Things that can lash you
	local npc_lasher = {}
	npcs.lasher = npc_lasher

	npc_lasher["Juvenile Bloodpetal"] = true
	npc_lasher["Writhing Terror"] = true
	npc_lasher["Bloodpetal Flayer"] = true
	npc_lasher["Bloodpetal Thresher"] = true
	npc_lasher["Bloodpetal Trapper"] = true
	npc_lasher["Fiendling Flesh Beast"] = true
	npc_lasher["Gloomshade Blossom"] = true
	
	
	-- Ooze type NPCs
	local npc_ooze = {}
	npcs.ooze = npc_ooze
	npc_ooze["%Ooze"] = true
	
	
	-- Similar to tentacle fiends except the flowery kind with vines
	local npc_vines = {}
	npcs.vines = npc_vines
	npc_vines["Juvenile Bloodpetal"] = true
	npc_vines["%Bloodpetal"] = true
	npc_lasher["Gloomshade Blossom"] = true
	
	
	local npc_wasp = {}
	npcs.wasp = npc_wasp
	npc_wasp["Hazzali Stinger"] = true
	npc_wasp["Gorishi Wasp"] = true
	

