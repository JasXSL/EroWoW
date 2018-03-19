function ExiWoW.RPText:buildLibrary()
	
	local req = ExiWoW.RPText.Req;
	local ty = req.Types;
	local assetLib = ExiWoW.LibAssets;
	local spellKits = assetLib.spell_kits;
	local R = ExiWoW.R.rpTexts;
	

	-- Gets a formatted spell kit from lib_Assets (or more)
	-- A spell kit is a collection of spell names that share the same theme, such as frost, fire, basilisk stun etc
	local getsk = function(...)
		return ExiWoW.LibAssets:spellKitToRP(...);
	end

	-- Function templates
	local template_addExcitementMasochisticDefault = function(self)
		ExiWoW.ME:addExcitement(0.15, false, true);
	end
	local template_addExcitementMasochisticCrit = function(self)
		ExiWoW.ME:addExcitement(0.3, false, true);
	end
	local template_addExcitementDefault = function(self)
		ExiWoW.ME:addExcitement(0.1);
	end
	local template_addExcitementCrit = function(self)
		ExiWoW.ME:addExcitement(0.2);
	end
	


	-- Humanoid NPC attacker
	local template_condAttackerHumanoid = req:new({
		type = ty.RTYPE_TYPE,
		sender = true,
		data = {Humanoid = true}
	})
	-- Includes other viable humanoid types like undeads
	local template_condAttackerHumanoidish = req:new({
		type = ty.RTYPE_TYPE,
		sender = true,
		data = {Humanoid = true, Undead = true}
	})
	
	local template_condVictimBreasts = req:new({type = ty.RTYPE_HAS_BREASTS})
	local template_condVictimPenis = req:new({type = ty.RTYPE_HAS_PENIS})
	local template_condVictimVagina = req:new({type = ty.RTYPE_HAS_VAGINA})
	
	local template_condSpellAdd = req:new({type=ty.RTYPE_SPELL_ADD})
	local template_condSpellRem = req:new({type=ty.RTYPE_SPELL_REM})
	local template_condSpellTick = req:new({type=ty.RTYPE_SPELL_TICK})
	

	-- NPC Libraries
	local npc_tentacleFiend = {}
	npc_tentacleFiend["Writhing Terror"] = true;
	local template_condAttackerIsTentacleFiend = req:new({type=ty.RTYPE_NAME, data=npc_tentacleFiend, sender=true})


-- ACTIONS
	-- Fondle --
	-- You can set text_sender to nil to set self_cast_only to true

		-- TARGET --
			-- Fondle breasts target
			table.insert(R, ExiWoW.RPText:new({
				id = "FONDLE",
				text_sender = "You grab a hold of and rub %T's %Tbreasts!",
				text_receiver = "%S grabs a hold of and rubs your %Tbreasts!",
				sound = 57179,
				requirements = {template_condVictimBreasts}
			}))

			-- Fondle groin target
			table.insert(R, ExiWoW.RPText:new({
				id = "FONDLE",
				text_sender = "You grab a hold of and rub %T's %Tgroin!",
				text_receiver = "%S grabs a hold of and rubs your %Tgroin!",
				sound = 57179,
				requirements = {}
			}))

			-- Fondle butt target
			table.insert(R, ExiWoW.RPText:new({
				id = "FONDLE",
				text_sender = "You grab a hold of and rub %T's %Tbutt!",
				text_receiver = "%S grabs a hold of and rubs your %Tbutt!",
				sound = 57179,
				requirements = {}
			}))

		-- SELF --
			table.insert(R, ExiWoW.RPText:new({
				id = "FONDLE",
				text_receiver = "You rub your own %Tgroin!",
				sound = 57179,
				requirements = {}
			}))
			table.insert(R, ExiWoW.RPText:new({
				id = "FONDLE",
				text_receiver = "You rub your %Tbreasts!",
				sound = 57179,
				requirements = {
					req:new({
						type = ty.RTYPE_HAS_BREASTS
					})
				}
			}))
		--




-- MELEE SWINGS --
	-- HUMANOIDISH (crits) --

		table.insert(R, ExiWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S's attacks smacks against your %leftright %Tbreast!",
			sound = 37472,
			requirements = {template_condAttackerHumanoidish, template_condVictimBreasts},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementMasochisticCrit
		}))


		table.insert(R, ExiWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S's attack smacks painfully across your %Tgroin!",
			sound = 37472,
			requirements = {template_condAttackerHumanoidish},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementMasochisticCrit
		}))

		table.insert(R, ExiWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S throws a cheap shot at your %Tgroin!",
			sound = 37472,
			requirements = {template_condAttackerHumanoidish},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementMasochisticCrit
		}))

		table.insert(R, ExiWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S's attack smacks painfully across your %Tbreasts!",
			sound = 37472,
			requirements = {template_condAttackerHumanoidish, template_condVictimBreasts},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementMasochisticCrit
		}))


	-- Tentacle fiends (like the one in the draenei start area)
		table.insert(R, ExiWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S slips a tentacle into your clothes, tickling your %Tgroin!",
			sound = 21727,
			requirements = {template_condAttackerIsTentacleFiend},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementDefault
		}))
		table.insert(R, ExiWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S slips a tentacle into your clothes, tickling between your %Trtag buttcheeks!",
			sound = 21727,
			requirements = {template_condAttackerIsTentacleFiend},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementDefault
		}))
		table.insert(R, ExiWoW.RPText:new({
			id = "SWING_CRIT",
			text_receiver = "%S slips a tentacle into your clothes, slipping it up into your %Tvagina and wiggling it around!",
			sound = 21727,
			requirements = {template_condAttackerIsTentacleFiend, template_condVictimVagina},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementCrit
		}))
		table.insert(R, ExiWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S slips a tentacle into your clothes, hooping it around your nipples and tugs!",
			sound = 21729,
			requirements = {template_condAttackerIsTentacleFiend, template_condVictimBreasts},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementMasochisticDefault
		}))
		table.insert(R, ExiWoW.RPText:new({
			id = "SWING",
			text_receiver = "%S slips a tentacle up between your legs, tickling your %Tgroin!",
			sound = 21727,
			requirements = {template_condAttackerIsTentacleFiend},
			-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
			fn = template_addExcitementDefault
		}))
	--

-- SPELLS --

		-- GENERIC / NPC --

			-- Ice spells
			table.insert(R, ExiWoW.RPText:new({
				id = getsk("ice", "ice_common"),
				text_receiver = "The cold spell causes your nipples to harden!",
				--sound = 48289,
				requirements = {{template_condSpellAdd, template_condSpellTick}, template_condVictimBreasts},
				fn = template_addExcitementPain
			}))

			-- Lightning
				
				table.insert(R, ExiWoW.RPText:new({
					id = getsk("electric", "electric_common"),
					text_receiver = "The %spell shocks your nipples!",
					sound = 35286,
					requirements = {
						{template_condSpellAdd, template_condSpellTick},  -- OR
						template_condVictimBreasts
					},
					fn = template_addExcitementPain
				}))
				table.insert(R, ExiWoW.RPText:new({
					id = getsk("electric"),
					text_receiver = "The %spell painfully shocks your %Tbreasts!",
					sound = 35286,
					requirements = {
						{template_condSpellAdd, template_condSpellTick},  -- OR
						template_condVictimBreasts
					},
					fn = template_addExcitementPain
				}))


			-- Basilisk stares
				
				table.insert(R, ExiWoW.RPText:new({
					id = getsk("basilisk"),
					text_receiver = "The %spell causes your nipples to %harden!",
					--sound = 35103,
					requirements = {
						template_condSpellAdd,
						template_condVictimBreasts
					},
					fn = template_addExcitementDefault
				}))
				table.insert(R, ExiWoW.RPText:new({
					id = getsk("basilisk"),
					text_receiver = "The %spell causes your %Tpenis to %harden!",
					--sound = 35103,
					requirements = {
						template_condSpellAdd,
						template_condVictimPenis
					},
					fn = template_addExcitementDefault
				}))

			-- Uppercut
				table.insert(R, ExiWoW.RPText:new({
					id = "SPELL_Uppercut",
					text_receiver = "%S uppercuts your %Tbreasts with enough force to knock you back!",
					--sound = 35103,
					requirements = {
						template_condSpellTick,
						template_condVictimBreasts
					},
					fn = template_addExcitementMasochisticCrit
				}))
				table.insert(R, ExiWoW.RPText:new({
					id = "SPELL_Uppercut",
					text_receiver = "%S uppercuts your %leftright %Tbreast, jiggling it around heavily as you stagger backwards!",
					--sound = 35103,
					requirements = {
						template_condSpellTick,
						template_condVictimBreasts
					},
					fn = template_addExcitementMasochisticCrit
				}))






		-- DRUID --

			-- Entangling Roots
			table.insert(R, ExiWoW.RPText:new({
				id = "SPELL_Entangling Roots",
				text_receiver = "A vine from the roots slips inside your clothes and starts tickling your %Tbutt!",
				sound = 48289,
				requirements = {template_condSpellAdd},
				-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
				fn = template_addExcitement
			}))
			table.insert(R, ExiWoW.RPText:new({
				id = "SPELL_Entangling Roots",
				text_receiver = "A vine from the roots slips inside your clothes and squeezes your %Tpenis!",
				sound = 48289,
				requirements = {template_condSpellAdd, template_condVictimPenis},
				-- FN is currently only supported for NPC actions. PC->PC actions should use the Action system instead
				fn = template_addExcitement
			}))
			table.insert(R, ExiWoW.RPText:new({
				id = "SPELL_Entangling Roots",
				text_receiver = "A vine from the roots slips inside your clothes and up inside your %Tvagina where it wiggles about!",
				sound = 48289,
				requirements = {template_condSpellAdd, template_condVictimVagina},
				fn = template_addExcitementCrit
			}))
			table.insert(R, ExiWoW.RPText:new({
				id = "SPELL_Entangling Roots",
				text_receiver = "A vine from the roots slips inside your clothes and wrap around your %Tbreasts, squeezing them rigorously!",
				sound = 48289,
				requirements = {template_condSpellAdd, template_condVictimBreasts},
				fn = template_addExcitementPain
			}))
			


		

		-- ROGUE 
			-- Crimson vial
			table.insert(R, ExiWoW.RPText:new({
				id = "SPELL_Crimson Vial",
				text_receiver = "You spill some of the crimson vial all over your %Tbreasts!",
				sound = 1059,
				requirements = {template_condSpellAdd, template_condVictimBreasts},
				fn = template_addExcitementDefault
			}))




end