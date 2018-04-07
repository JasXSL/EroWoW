-- Effect templates, such as adding arousal
ExiWoW.LibAssets.effects = {}
local ef = ExiWoW.LibAssets.effects;



-- Sound kits
	-- /run ExiWoW.LibAssets.effects:painSound()
	function ef:painSound(race, sex)
		local sounds = {
			HumanM = 2942,
			HumanF = 2938,
			NightElfM = 2957,
			NightElfF = 2934,
			DwarfM = 2930,
			DwarfF = 2926,
			GnomeM = 3276,
			GnomeF = 3270,
			DraeneiM = 8985,
			DraeneiF = 8989,
			WorgenM = 21451,
			WorgenF = 22452,
			OrcM = 0,
			OrcF = 40744,
			TrollM = 3308,
			TrollF = 3302,
			ScourgeM = 1316,
			ScourgeF = 1362,
			TaurenM = 1354,
			TaurenF = 227,
			BloodElfM = 8997,
			BloodElfF = 8993,
			GoblinM = 18494,
			GoblinF = 18499,
			PandarenM = 28825,
			PandarenF = 31718,
			VoidElfM = 0,
			VoidElfF = 0,
			LightforgedDraeneiM = 0,
			LightforgedDraeneiF = 0,
			HighmountainTaurenM = 0,
			HighmountainTaurenF = 0,
			NightborneM = 0,
			NightborneF = 0,
		}
		ef:playCharSound(sounds, race, sex);
	end

	-- /run ExiWoW.LibAssets.effects:critSound()
	function ef:critSound(race, sex)
		local sounds = {
			HumanM = 2943,
			HumanF = 2939,
			NightElfM = 2958,
			NightElfF = 2935,
			DwarfM = 2931,
			DwarfF = 2927,
			GnomeM = 3277,
			GnomeF = 3271,
			DraeneiM = 8986,
			DraeneiF = 8990,
			WorgenM = 21452,
			WorgenF = 22453,
			OrcM = 0,
			OrcF = 40745,
			TrollM = 3309,
			TrollF = 3303,
			ScourgeM = 1317,
			ScourgeF = 1363,
			TaurenM = 1355,
			TaurenF = 228,
			BloodElfM = 8998,
			BloodElfF = 8994,
			GoblinM = 18495,
			GoblinF = 18500,
			PandarenM = 28824,
			PandarenF = 31719,
			VoidElfM = 0,
			VoidElfF = 0,
			LightforgedDraeneiM = 0,
			LightforgedDraeneiF = 0,
			HighmountainTaurenM = 0,
			HighmountainTaurenF = 0,
			NightborneM = 0,
			NightborneF = 0,
		}
		ef:playCharSound(sounds, race, sex);
	end

	function ef:playCharSound(library, race, sex)
		if not race then
			race = UnitRace("player");
		end
		if not gender then
			gender = UnitSex("player");
		end
		if gender == 2 then race = race.."M"
		elseif gender == 3 then race = race.."F"
		end

		race = race:gsub("%s+", "")

		if not library[race] then return end
		PlaySound(library[race], "SFX")

	end

	
-- Reusable functions
	ef.addExcitementMasochisticDefault = function(self, sender, receiver)
		-- Swing pain sounds are handled by WoW
		if type(self) ~= "table" or not self.id or (not self.id.SWING and not self.id.SWING_CRIT) then
			ef:painSound()
		end
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_DEFAULT)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	ef.addExcitementMasochisticCrit = function(self)
		-- Swing pain sounds are handled by WoW

		-- Trigger pain sound if
		if 
			type(self) ~= "table" or -- Self is not a table, not 100% sure about this
			not self.id or
			(	-- It is a table, but
				not (self.id.SWING or self.id.SWING_CRIT) or -- It's not a melee swing
				ExiWoWLocalStorage.tank_mode -- Or tank mode is on
			) then 
				ef:critSound() 
			end
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_M_CRIT)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	ef.addExcitementDefault = function(self)
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_DEFAULT)
		ExiWoW.ME:addExcitement(0.1);
	end
	ef.addExcitementCrit = function(self)
		if type(self) ~= "table" or not (self.id.SWING and not self.id.SWING_CRIT) then
			ef:painSound()
		end
		ExiWoW.Event:raise(ExiWoW.Event.Types.EXADD_CRIT)
		ExiWoW.ME:addExcitement(0.2);
	end

	ef.toggleVibHubProgram = function(self, program, duration)
		if not ExiWoW.VH then return end
		if not ExiWoW.VH.programs[program] then return end
		ExiWoW.VH:addTempProgram(ExiWoW.VH.programs[program], duration);
	end

	




