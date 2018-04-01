function ExiWoW.Effect:buildLibrary()

	local ef = ExiWoW.LibAssets.effects

	-- These are Effect effect definitions
	table.insert(ExiWoW.R.effects, ExiWoW.Effect:new({
		id = "debuffShardTickleButt",
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
	}));

	table.insert(ExiWoW.R.effects, ExiWoW.Effect:new({
		id = "debuffShardTickleBreasts",
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
	}));
	table.insert(ExiWoW.R.effects, ExiWoW.Effect:new({
		id = "debuffShardTickleGroin",
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
	}));
	
	-- /run ExiWoW.Effect:run("oozeInClothes")
	table.insert(ExiWoW.R.effects, ExiWoW.Effect:new({
		id = "oozeInClothes",
		detrimental = true,
		duration = 600,
		ticking = 5,
		max_stacks = 1,
		texture = "Interface/Icons/inv_misc_food_legion_gooslime_chunk",
		name = "Ooze",
		description = "Living ooze has made it into your clothes! Right click to remove it.",
		onAdd = function(self, binding, fromReload)
			self.rightClicked = false
			ef:toggleVibHubProgram("IDLE_OOZE", 600)
			if not fromReload then
				ExiWoW.RPText:trigger("FX_OozeInClothesAdd", ExiWoW.ME, ExiWoW.ME)
			end
		end,
		onTick = function(self)
			if math.random() < 0.25 then
				ExiWoW.RPText:trigger("FX_OozeInClothesTick", ExiWoW.ME, ExiWoW.ME)
			end
		end,
		onRemove = function(self)
			ef:toggleVibHubProgram("IDLE_OOZE")
			
			if not self.rightClicked then
				ExiWoW.RPText:trigger("FX_OozeInClothesFade", ExiWoW.ME, ExiWoW.ME)
			end
			--ef:toggleVibHubProgram("SMALL_TICKLE");
		end,
		onRightClick = function(self, data)
			self.rightClicked = true
			local effect = data.effect
			local id = data.id

			-- Create a custom removal action
			local remAction =  ExiWoW.Action:new({
				id = "_",
				self_only = true,
				name = "Remove Goo",
				description = "Removes the living goo from your clothes.",
				texture = "ability_bossfelmagnaron_handempowered",
				cooldown = 0,
				cast_sound_loop = 79252,
				allow_caster_moving = false,
				cast_time = 5,
				allow_targ_combat = false,
				-- Handle the receiving end here
				fn_send = function(self, sender, target, suppressErrors)
		
					ExiWoW.RPText:trigger("FX_OozeInClothesRem", ExiWoW.ME, ExiWoW.ME)
					ExiWoW.Effect:rem(id)

					return false
				end
			})
			ExiWoW.Action:useOnTarget(remAction, "player")
			
			return false
		end
	}));


end