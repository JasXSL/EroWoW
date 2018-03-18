function EroWoW.RPText:buildLibrary()
	
	local req = EroWoW.RPText.Req;
	local ty = req.Types;

-- Fondle --
-- You can set text_sender to nil to set self_cast_only to true

	-- TARGET --
		-- Fondle breasts target
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_sender = "You grab a hold of and rub %T's %Tbreasts!",
			text_receiver = "%S grabs a hold of and rubs your %Tbreasts!",
			sound = 57179,
			requirements = {
				req:new({
					type = ty.RTYPE_HAS_BREASTS,
				})
			}
		}))

		-- Fondle groin target
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_sender = "You grab a hold of and rub %T's %Tgroin!",
			text_receiver = "%S grabs a hold of and rubs your %Tgroin!",
			sound = 57179,
			requirements = {}
		}))

		-- Fondle butt target
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_sender = "You grab a hold of and rub %T's %Tbutt!",
			text_receiver = "%S grabs a hold of and rubs your %Tbutt!",
			sound = 57179,
			requirements = {}
		}))

	-- SELF --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_receiver = "You rub your own %Tgroin!",
			sound = 57179,
			requirements = {}
		}))
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_receiver = "You rub your %Tbreasts!",
			sound = 57179,
			requirements = {
				req:new({
					type = ty.RTYPE_HAS_BREASTS
				})
			}
		}))






	-- HUMANOID MELEE SWINGS --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S attack smacked across your %Tgroin!",
			sound = 37472,
			requirements = {
				req:new({
					type = ty.RTYPE_TYPE,
					sender = true,
					data = {Humanoid = true}
				})
			},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = function(self)
				EroWoW.ME:addArousal(0.15, false, true);
			end
		}))

		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S attack smacked across your %Tbreasts!",
			sound = 37472,
			requirements = {
				req:new({
					type = ty.RTYPE_TYPE,
					sender = true,
					data = {Humanoid = true}
				})
			},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = function(self)
				EroWoW.ME:addArousal(0.15, false, true);
			end
		}))




	-- HUMANOID MELEE SWINGS CRIT --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S attack hit you straight in the groin!",
			sound = 37472,
			requirements = {
				req:new({
					type = ty.RTYPE_TYPE,
					sender = true,
					data = {Humanoid = true}
				})
			},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = function(self)
				print("Adding arousal")
				EroWoW.ME:addArousal(0.3, false, true);
			end
		}))


end