-- Effect templates, such as adding arousal
ExiWoW.LibAssets.effects = {}
local ef = ExiWoW.LibAssets.effects;

	ef.addExcitementMasochisticDefault = function(self)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	ef.addExcitementMasochisticCrit = function(self)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	ef.addExcitementDefault = function(self)
		ExiWoW.ME:addExcitement(0.1);
	end
	ef.addExcitementCrit = function(self)
		ExiWoW.ME:addExcitement(0.2);
	end







