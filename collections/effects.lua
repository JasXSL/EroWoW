-- Effect templates, such as adding arousal
ExiWoW.LibAssets.effects = {}
local ef = ExiWoW.LibAssets.effects;


-- These are Effect effect definitions
	ef.debuffShardTickleButt = ExiWoW.Effect:new({
		detrimental = true,
		duration = 10,
		ticking = 0,
		max_stacks = 1,
		texture = "Interface/Icons/inv_enchanting_wod_crystalshard2",
		name = "Vibrating Shard",
		description = "A vibrating shard is lodged between your buttcheeks!",
		onAdd = function()
			ef:toggleVibHubProgram("SMALL_TICKLE", 11);
		end,
		onRemove = function()
			ef:toggleVibHubProgram("SMALL_TICKLE");
		end
	});
	ef.debuffShardTickleBreasts = ExiWoW.Effect:new({
		detrimental = true,
		duration = 10,
		ticking = 0,
		max_stacks = 1,
		texture = "Interface/Icons/inv_enchanting_wod_crystalshard2",
		name = "Vibrating Shard",
		description = "A vibrating shard is lodged between your breasts!",
		onAdd = function()
			ef:toggleVibHubProgram("SMALL_TICKLE", 11);
		end,
		onRemove = function()
			ef:toggleVibHubProgram("SMALL_TICKLE");
		end
	});
	ef.debuffShardTickleGroin = ExiWoW.Effect:new({
		detrimental = true,
		duration = 10,
		ticking = 0,
		max_stacks = 1,
		texture = "Interface/Icons/inv_enchanting_wod_crystalshard2",
		name = "Vibrating Shard",
		description = "A vibrating shard is stuck in your underwear!",
		onAdd = function()
			ef:toggleVibHubProgram("SMALL_TICKLE", 11);
		end,
		onRemove = function()
			ef:toggleVibHubProgram("SMALL_TICKLE");
		end
	});
	



-- Reusable functions
	ef.addExcitementMasochisticDefault = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_DEFAULT)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	ef.addExcitementMasochisticCrit = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_CRIT)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	ef.addExcitementDefault = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_DEFAULT)
		ExiWoW.ME:addExcitement(0.1);
	end
	ef.addExcitementCrit = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_CRIT)
		ExiWoW.ME:addExcitement(0.2);
	end

	ef.toggleVibHubProgram = function(self, program, duration)
		if not ExiWoW.VH then return end
		if not ExiWoW.VH.programs[program] then return end
		ExiWoW.VH:addTempProgram(ExiWoW.VH.programs[program], duration);
	end

	




