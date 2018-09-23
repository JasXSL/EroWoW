-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

function internal.build.zones()

	local Spell = require("Spell");
	local Database = require("Database");
	local Condition = require("Condition");
	local ext = internal.ext;
	
	ext:addZone({id="Durotar", tags={"SAND"}});
	ext:addZone({id="Burning Steppes", tags={"SAND"}});
	ext:addZone({id="Tanaris", tags={"SAND"}});
	ext:addZone({id="Westfall", tags={"SAND"}});
	ext:addZone({id="Barrens", tags={"SAND"}});
	ext:addZone({id="Stonetalon Mountains", tags={"SAND"}});
	ext:addZone({id="Thousand Needles", tags={"SAND"}});
	ext:addZone({id="Desolace", tags={"SAND"}});
	ext:addZone({id="Searing Gorge", tags={"SAND"}});
	ext:addZone({id="Badlands", tags={"SAND"}});
	ext:addZone({id="Blasted Lands", tags={"SAND"}});
	ext:addZone({id="Deadwind Pass", tags={"SAND"}});
	ext:addZone({id="Hellfire Peninsula", tags={"SAND"}});
	ext:addZone({id="Blade's Edge Mountains", tags={"SAND"}});
	ext:addZone({id="Netherstorm", tags={"SAND"}});
	ext:addZone({id="Shadowmoon Valley", tags={"SAND"}});
	ext:addZone({id="Vol'Dun", tags={"SAND"}});
	ext:addZone({id="Nazmir", tags={"MUSHROOMS","SWAMP"}});
	
	ext:addZone({id="Zangarmarsh", tags={"MUSHROOMS","SWAMP"}});

end