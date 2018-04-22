local appName, internal = ...
local require = internal.require;

function internal.build.rptexts()
	
	local Condition = require("Condition");	-- RPText requirement constructor
	local Database = require("Database");
	local ty = Condition.Types;			-- Local filter types
	local assetLib = ExiWoW.LibAssets;
	local spellKits = assetLib.spell_kits;		-- RP Text spell kits library
	local function getCondition(id)
		return Database.getID("Condition", id);
	end
	local ef = ExiWoW.LibAssets.effects;		-- RP Text effects library
	local RPText = require("RPText");

	-- Root extension
	local ext = internal.ext;
		
	-- Only wholesome family friendly PG stuff in here

	-- Tickle target
	ext:addRpText({
		id = "TICKLE",
		text_sender = "You tickle %T!",
		text_receiver = "%T tickles you!",
		requirements = {},
	})
	ext:addRpText({
		id = "TICKLE",
		text_sender = "You tickle %T with your %item!",
		text_receiver = "%S tickles you with %Shis %item!",
		requirements = {getCondition("invFeathers")},
	})

	-- Tickle self
	ext:addRpText({
		id = "TICKLE",
		text_bystander = "%T tickles %Thimself!",
		text_receiver = "You tickle yourself!",
		requirements = {},
		--fn = ef.addExcitementMasochisticDefault
	})
	ext:addRpText({
		id = "TICKLE",
		text_bystander = "%T tickles %Thimself with %This %item!",
		text_receiver = "You use your %item to tickle yourself!",
		requirements = {getCondition("invFeathers")},
		--fn = ef.addExcitementMasochisticDefault
	})

	-- Wedgie
	ext:addRpText({
		id = "WEDGIE",
		text_bystander = "%S grabs a hold of %T's %Tundies, giving %Thim a wedgie!",
		text_sender = "You grab a hold of %T's %Tundies, giving %Thim a wedgie!",
		text_receiver = "%S grabs a hold of your %Tundies, giving you a wedgie!",
		sound = 25626,
		requirements = {getCondition("targetWearsUnderwear")},
		--fn = ef.addExcitementMasochisticDefault
	})

	ext:addRpText({
		id = "WEDGIE",
		text_bystander = "%T grabs a hold of %This %Tundies and gives %Thimself a wedgie!",
		text_receiver = "You grab a hold of your %Tundies and give yourself a wedgie!",
		sound = 25626,
		requirements = {getCondition("targetWearsUnderwear")},
		--fn = ef.addExcitementMasochisticDefault
	})
	

	-- Insect swarm
	ext:addRpText({
		id = spellKits.insects,
		text_receiver = "The insects get into your equipment, skittering across your body!",
		--sound = 35103,
		requirements = {getCondition("spellAdd")},
		fn = ef.addExcitementDefault
	})

	-- Sand ADD
	ext:addRpText({
		id = spellKits.sand,
		text_receiver = "Sand gets into your clothes!",
		--sound = 35103,
		requirements = {getCondition("spellAdd")},
		fn = ef.addExcitementMasochisticDefault
	})

	ext:addRpText({
		id = spellKits.dirt,
		text_receiver = "Some dirt gets into your clothes!",
		--sound = 35103,
		requirements = {getCondition("spellTick")},
		fn = ef.addExcitementMasochisticDefault
	})

	ext:addRpText({
		id = "THROW_SAND",
		text_bystander = "%T throws sand into the air, some of which falls back down on %Thim and into %This clothes!",
		text_receiver = "You throw sand into the air, some of which falls back down on you and into your clothes!",
		sound = 73172,
		requirements = {}
	})

	ext:addRpText({
		id = "THROW_SAND",
		text_bystander = "%S throws a handful of sand at %T!",
		text_sender = "You throw a handful of sand at %T!",
		text_receiver = "%S throws a handful of sand at you!",
		sound = 907,
		requirements = {}
	})

	ext:addRpText({
		id = "CLAW_PINCH",
		text_bystander = "%S pinches %T's side with a big claw!",
		text_sender = "You pinch %T's side with your big claw!",
		text_receiver = "%S pinches your side with %Shis big claw!",
		sound = 36721,
		requirements = {}
	})
	ext:addRpText({
		id = "CLAW_PINCH",
		text_bystander = "%T pinches %T's nose with a big claw!",
		text_sender = "You pinch %T's nose with your big claw!",
		text_receiver = "%S pinches your nose with %Shis big claw!",
		sound = 36721,
		requirements = {}
	})
	ext:addRpText({
		id = "CLAW_PINCH",
		text_bystander = "%T pinches %This own nose with a big claw!",
		text_receiver = "You pinch your nose with your big claw!",
		sound = 36721,
		requirements = {}
	})

	

end