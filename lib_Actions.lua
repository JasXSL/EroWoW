-- Library for Actions --
function ExiWoW.Action:buildLibrary()

			-- Template functions --
	
		
	local function sendRPText(self, sender, target, suppressErrors)

		local ts = ExiWoW.ME;
		local tt = ExiWoW.CAST_TARGET;
		if UnitIsUnit(target, "player") then tt = ts; end -- Self cast

		local rptext = ExiWoW.RPText:get(self.id, ts, tt);
		-- We only need a callback for this
		return {
			text=rptext.text_receiver,
			sender=ts:export(true),
			sound=rptext.sound
		}, 
		function(se, success, data) 
			if success then
				if rptext.sound then
					PlaySound(rptext.sound, "SFX");
				end
				if rptext.text_sender then 
					ExiWoW.RPText:print(ExiWoW.RPText:convert(rptext.text_sender, ts, tt))
				end
			end
		end
	end

	local function receiveRPText( self, sender, target, args)

		if args.text and args.sender then
			local ts = ExiWoW.Character:new(args.sender, sender);
			ExiWoW.RPText:print(ExiWoW.RPText:convert(args.text, ts, ExiWoW.ME))
		end
		
		-- Play receiving sound if not self cast
		if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") and args.sound then 
			PlaySound(args.sound, "SFX");
		end

	end



			-- LIBRARY --

	-- Meta action that checks if target has ExiWoW --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "A",
		global_cooldown = false,
		suppress_all_errors = true,
		party_restricted = false,
		allow_stunned = true,
		allow_instance = true,
		allow_caster_dead = true,
		allow_targ_dead = true,
		hidden = true,
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)
			ExiWoW.TARGET = nil
			-- Return no data, but one callback
			return nil, function(se, success, data, sender)
				if success then
					ExiWoW.TARGET = ExiWoW.Character:new(data, sender);
					local offset = 0;
					if ExiWoW.TARGET:isFemale() then offset = 0.25;
					elseif not ExiWoW.TARGET:isMale() then offset = 0.5; end
					ExiWoW.Frames.targetHasExiWoWFrame.genderTexture:SetTexCoord(offset,offset+0.25,0,1);
					ExiWoW.Frames.targetHasExiWoWFrame:Show();
				end
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, data)
			return ExiWoW.ME:export(true)
		end

	}))

	-- Disrobe --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "DISROBE",
		name = "Disrobe",
		description = "Removes a piece of armor from your target.",
		texture = "ability_rogue_plunderarmor",
		--cooldown = 120,
		cooldown = 10,
		require_stealth = true,
		allow_targ_combat = false,
		party_restricted = true,
		cast_time = 2,
		allow_caster_moving = false,
		cast_sound_loop = 6425,				-- Tailoring, see http://www.wowhead.com/sound=6425/tailoring
		max_distance = ExiWoW.Action.MELEE_RANGE,
		-- allow_self = false,

		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)

			-- Return no data, but one callback
			return nil, function(se, success, data)
				if not success then
					if data and data[1] then ExiWoW:reportError(data[1], suppressErrors); end
					self:resetCooldown();
				else
					PlaySound(1202, "SFX");
					ExiWoW:reportError(ExiWoW:unitRpName(sender) .. " successfully removed "..Ambiguate(UnitName(target), "all").."'s "..ExiWoW:itemSlotToname(data.slot).."!");
				end
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, suppressErrors)
			local all_slots = {
				1, -- Head
				3, -- Shoulder
				4, -- Shirt
				5, -- Chest
				6, -- Belt
				7, -- Pants
				8, -- Boots
				10, -- Gloves
				15, -- Cloak
				19 -- Tabard
			}
			local equipped_slots = {};
			for k,v in pairs(all_slots) do
				local item = GetInventoryItemID(target, v)
				local transmog, _, _, _, _, _, hidden = C_Transmog.GetSlotInfo(v, 0);
				if item ~= nil and not hidden then
					table.insert( equipped_slots, v )
				end
			end

			if next(equipped_slots) == nil then
				return false, {Ambiguate(UnitName("player"), "all") .. " has no strippable slots!"}
			end

			local slot = equipped_slots[ math.random( #equipped_slots ) ];
			ExiWoW:removeEquipped(slot);
			ExiWoW:reportError(ExiWoW:unitRpName(sender) .. " tugged off your "..ExiWoW:itemSlotToname(slot).."!");
			if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") then 
				PlaySound(1202, "SFX");
			end
			return true, {slot=slot}
		end

	}))

	-- meditate --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "MEDITATE",
		self_only = true,
		name = "Meditate",
		description = "Meditate for a while, allowing your excitement to fade at a greatly increased rate.",
		texture = "monk_ability_transcendence",
		cooldown = 0,
		allow_caster_moving = false,
		allow_targ_combat = false,
		important = true,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, suppressErrors)

			if ExiWoW.ME.meditating then
				return ExiWoW:reportError("You are already meditating!");
			end

			-- Start meditation --
			DoEmote("SIT");
			ExiWoW.ME.meditating = true;
			ExiWoW.ME:toggleResting(true)
			ExiWoW.Character:bind("PLAYER_STARTED_MOVING", function()
				ExiWoW.ME:toggleResting(false)
				ExiWoW.ME.meditating = false;
			end, 1);
			return true

		end
	}))

	-- Spot excitement (Public, melee range) --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "SPOT_EXCITEMENT",
		name = "Spot Excitement",
		important = true,
		description = "Spot excitement of a nearby player.",
		texture = "sha_ability_rogue_bloodyeye_nightborne",
		cooldown = 0,
		max_distance = ExiWoW.Action.MELEE_RANGE,
		party_restricted = false,
		fn_send = function(self, sender, target, suppressErrors)
			-- We only need a callback for this
			return nil, function(se, success, data) ExiWoW.Action:handleExcitementCallback(target, success, data) end
		end,
		fn_receive = ExiWoW.Action.returnExcitement
	}));

	-- Sniff (Worgen) --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "SNIFF",
		name = "Sniff",
		description = "Sniff the excitement of a player.",
		texture = "inv_wolfdraenormountshadow",
		cooldown = 0,
		max_distance = ExiWoW.Action.CASTER_RANGE,
		party_restricted = false,
		allowed_races = {"Worgen"},
		fn_send = function(self, sender, target, suppressErrors)
			DoEmote("SNIFF", target);
			-- Callback
			return nil, function(se, success, data) ExiWoW.Action:handleExcitementCallback(target, success, data) end
		end,
		fn_receive = ExiWoW.Action.returnExcitement
	}));

	-- Fondle (Public) --
	table.insert(ExiWoW.R.actions, ExiWoW.Action:new({
		id = "FONDLE",
		name = "Fondle",
		description = "Fondle a player.",
		texture = "ability_paladin_handoflight",
		--cooldown = 1.5,
		cast_sound_success = 57179,
		allow_instance = true,
		max_distance = ExiWoW.Action.MELEE_RANGE,
		fn_send = sendRPText,
		fn_receive = function(self, sender, target, args)
			receiveRPText(self, sender, target, args) -- Default behavior
			-- Custom actions
			ExiWoW.ME:addExcitement(0.05);
			return true
		end
	}));

end