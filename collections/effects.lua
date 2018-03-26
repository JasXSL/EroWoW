-- Effect templates, such as adding arousal
ExiWoW.LibAssets.effects = {}
local ef = ExiWoW.LibAssets.effects;

	ef.addExcitementMasochisticDefault = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_DEFAULT)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	ef.addExcitementMasochisticCrit = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_CRIT)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	ef.addExcitementDefault = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_DEFAULT)
		ExiWoW.ME:addExcitement(0.1);
	end
	ef.addExcitementCrit = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_CRIT)
		ExiWoW.ME:addExcitement(0.2);
	end

	ef.toggleVibHubProgram = function(self, program, on)
		if not ExiWoW.VH then return end
		if not ExiWoW.VH.programs[program] then return end
		ExiWoW.VH:toggleProgram(ExiWoW.VH.programs[program], on);
	end






