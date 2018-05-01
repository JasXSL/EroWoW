local appName, internal = ...
local require = internal.require;

function internal.build.quests()

	local Func = require("Func");
	local Quest = require("Quest");
	local Objective = Quest.Objective;
	local Reward = Quest.Reward;
	local ext = internal.ext;
	

	-- Test quest
	ext:addQuest({
		id = "SHOCKTACLE",
		name = "Shocktacle",
		start_text = {"You found a still squirming lightning tentacle on the bog strider.", "Maybe you could use the other bogstriders to recharge it?"},
		journal_entry = "You have found a barely squirming lightning tentacle on a bog strider in Zangarmarsh. If you were to charge it, it could make an interesting toy for sure!",
		rewards = {
			Reward:new({
				id = "CLAW_PINCH",
				type = "Charges",
				quant = 3
			}),
			Reward:new({
				id = "LEATHER_THONG",
				type = "Underwear",
				quant = 1
			})
		},
		objectives = {
			{
			Objective:new({
				id = "tether",
				name = "Get hit by lightning tethers",
				num = 6,				-- Num of name to do to complete it
				onObjectiveEnable = function() 
				
				end,		-- Raised when objective is activated
				onObjectiveDisable = function() 
				
				end	-- Raised when objective is completed or disabled
			}),
			Objective:new({
				id = "somethingElse",
				name = "Some other thing",
				num = 1
			})
			}
		},		-- You can wrap objectives in {} to create packages
	});


end