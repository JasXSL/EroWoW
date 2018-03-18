function EroWoW.RPText:buildLibrary()
	
	local req = EroWoW.RPText.Req;
	local ty = req.Types;

	-- Function templates
	local template_addArousalMasochisticDefault = function(self)
		EroWoW.ME:addArousal(0.15, false, true);
	end
	local template_addArousalMasochisticCrit = function(self)
		EroWoW.ME:addArousal(0.3, false, true);
	end
	local template_addArousalDefault = function(self)
		EroWoW.ME:addArousal(0.05, false, true);
	end
	local template_addArousalCrit = function(self)
		EroWoW.ME:addArousal(0.1, false, true);
	end
	


	-- Humanoid NPC attacker
	local template_condAttackerHumanoid = req:new({
		type = ty.RTYPE_TYPE,
		sender = true,
		data = {Humanoid = true}
	})
	local template_condVictimBreasts = req:new({type = ty.RTYPE_HAS_BREASTS})
	local template_condVictimPenis = req:new({type = ty.RTYPE_HAS_PENIS})
	local template_condVictimVagina = req:new({type = ty.RTYPE_HAS_VAGINA})
	
	local template_condSpellAdd = req:new({type=ty.RTYPE_SPELL_ADD})
	local template_condSpellRem = req:new({type=ty.RTYPE_SPELL_REM})
	local template_condSpellTick = req:new({type=ty.RTYPE_SPELL_TICK})
	


-- Fondle --
-- You can set text_sender to nil to set self_cast_only to true

	-- TARGET --
		-- Fondle breasts target
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "FONDLE",
			text_sender = "You grab a hold of and rub %T's %Tbreasts!",
			text_receiver = "%S grabs a hold of and rubs your %Tbreasts!",
			sound = 57179,
			requirements = {template_condVictimBreasts}
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





-- MELEE SWINGS --
	-- HUMANOID --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S attack smacked across your %Tgroin!",
			sound = 37472,
			requirements = {template_condAttackerHumanoid},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousalMasochisticDefault
		}))

		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S attack smacked across your %Tbreasts!",
			sound = 37472,
			requirements = {template_condAttackerHumanoid, template_condVictimBreasts},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousalMasochisticDefault
		}))




	-- HUMANOID CRIT --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S's attack hit you straight in the %Tgroin!",
			sound = 37472,
			requirements = {template_condAttackerHumanoid},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousalMasochisticCrit
		}))

		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S's attack hit you straight across your %Tbreasts!",
			sound = 37472,
			requirements = {template_condAttackerHumanoid, template_condVictimBreasts},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousalMasochisticCrit
		}))





-- SPELLS --

		-- Entangling Roots --
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SPELL_Entangling Roots",
			text_receiver = "A vine from the roots slips inside your clothes and starts tickling your %Tbutt!",
			sound = 48289,
			requirements = {template_condSpellAdd},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousal
		}))
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SPELL_Entangling Roots",
			text_receiver = "A vine from the roots slips inside your clothes and squeezes your %Tpenis!",
			sound = 48289,
			requirements = {template_condSpellAdd, template_condVictimPenis},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addArousal
		}))
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SPELL_Entangling Roots",
			text_receiver = "A vine from the roots slips inside your clothes and up inside your %Tvagina where it wiggles about!",
			sound = 48289,
			requirements = {template_condSpellAdd, template_condVictimVagina},
			fn = template_addArousalCrit
		}))
		table.insert(EroWoW.R.rpTexts, EroWoW.RPText:new({
			id = "SPELL_Entangling Roots",
			text_receiver = "A vine from the roots slips inside your clothes and wrap around %Tbreasts, squeezing them rigorously!",
			sound = 48289,
			requirements = {template_condSpellAdd, template_condVictimBreasts},
			fn = template_addArousalPain
		}))
		


end