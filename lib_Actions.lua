-- Library for Actions --

-- Meta action that checks if target has erowow --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
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
		-- Return no data, but one callback
		return nil, function(se, success, data)
			if success then
				EroWoW.Character.targetHasEroWoWFrame:Show();
			end
		end
	end,
	-- Handle the receiving end here
	fn_receive = function(self, sender, target, suppressErrors)
		return true
	end

}))

-- Disrobe --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
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
	max_distance = EroWoW.Action.MELEE_RANGE,
	-- allow_self = false,

	-- Custom sending logic
	fn_send = function(self, sender, target, suppressErrors)

		-- Return no data, but one callback
		return nil, function(se, success, data)
			if not success then
				if data and data[1] then EroWoW:reportError(data[1], suppressErrors); end
				self:resetCooldown();
			else
				PlaySound(1202, "SFX");
				EroWoW:reportError(EroWoW:unitRpName(sender) .. " successfully removed "..Ambiguate(UnitName(target), "all").."'s "..EroWoW:itemSlotToname(data.slot).."!");
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
		EroWoW:removeEquipped(slot);
		EroWoW:reportError(EroWoW:unitRpName(sender) .. " tugged off your "..EroWoW:itemSlotToname(slot).."!");
		if not UnitIsUnit(sender, "player") then 
			PlaySound(1202, "SFX");
		end
		return true, {slot=slot}
	end

}))

-- meditate --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
	id = "MEDITATE",
	self_only = true,
	name = "Meditate",
	description = "Meditate for a while, allowing your arousal to fade at a greatly increased rate.",
	texture = "monk_ability_transcendence",
	cooldown = 0,
	allow_caster_moving = false,
	allow_targ_combat = false,
	important = true,
	-- Handle the receiving end here
	fn_receive = function(self, sender, target, suppressErrors)

		if EroWoW.ME.meditating then
			return EroWoW:reportError("You are already meditating!");
		end

		-- Start meditation --
		DoEmote("SIT");
		EroWoW.ME.meditating = true;
		EroWoW.ME:toggleResting(true)
		EroWoW.Character:bind("PLAYER_STARTED_MOVING", function()
			EroWoW.ME:toggleResting(false)
			EroWoW.ME.meditating = false;
		end, 1);
		return true

	end
}))

-- Spot arousal (Public, melee range) --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
	id = "SPOT_AROUSAL",
	name = "Spot Arousal",
	important = true,
	description = "Spot arousal of a nearby player.",
	texture = "sha_ability_rogue_bloodyeye_nightborne",
	cooldown = 0,
	max_distance = EroWoW.Action.MELEE_RANGE,
	party_restricted = false,
	fn_send = function(self, sender, target, suppressErrors)
		-- We only need a callback for this
		return nil, function(se, success, data) EroWoW.Action:handleArousalCallback(target, success, data) end
	end,
	fn_receive = EroWoW.Action.returnArousal
}));

-- Sniff (Worgen) --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
	id = "SNIFF",
	name = "Sniff",
	description = "Sniff the arousal of a player.",
	texture = "inv_wolfdraenormountshadow",
	cooldown = 0,
	max_distance = EroWoW.Action.CASTER_RANGE,
	party_restricted = false,
	allowed_races = {"Worgen"},
	fn_send = function(self, sender, target, suppressErrors)
		DoEmote("SNIFF", target);
		-- Callback
		return nil, function(se, success, data) EroWoW.Action:handleArousalCallback(target, success, data) end
	end,
	fn_receive = EroWoW.Action.returnArousal
}));

-- Fondle (Public) --
table.insert(EroWoW.Action.LIB, EroWoW.Action:new({
	id = "FONDLE",
	name = "Fondle",
	description = "Fondle a player.",
	texture = "ability_paladin_handoflight",
	--cooldown = 1.5,
	cast_sound_success = 57179,
	allow_instance = true,
	max_distance = EroWoW.Action.MELEE_RANGE,
	fn_send = function(self, sender, target, suppressErrors)
		local text = "Some RP text";
		-- We only need a callback for this
		return {text=text}, 
		function(se, success, data) 
			if success then
				print(text)
			end
		end
	end,
	fn_receive = function(self, sender, target, args)

		if args.text then
			print("Received text", args.text)
		end
		
		-- Play receiving sound if not self cast
		if not UnitIsUnit(sender, "player") then 
			PlaySound(self.cast_sound_success, "SFX");
		end
		return true
	end
}));

