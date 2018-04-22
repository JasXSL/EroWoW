local appName, internal = ...
local require = internal.require;

-- Library for Actions --
function internal.build.actions()

	local Action = require("Action");
	local Character = require("Character");
	local Tools = require("Tools");
	local UI = require("UI");
	local RPText = require("RPText");
	local Event = require("Event");
	local Condition = require("Condition");

	local ef = ExiWoW.LibAssets.effects
	local extension = internal.ext;
	

			-- LIBRARY --

	-- Meta action that checks if target has ExiWoW --
	extension:addAction({
		id = "A",
		global_cooldown = false,
		suppress_all_errors = true,
		hidden = true,
		conditions = {},
		not_defaults = {
			"party_restricted",
			"not_stunned",
			"not_in_instance",
			"sender_alive",
			"victim_alive",
			"not_in_vehicle"
		},
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)
			ExiWoW.TARGET = nil

			-- Return no data, but one callback
			return nil, function(se, success, data, sender)
				if not success then return end
				sender = Ambiguate(sender, "all")
				if success and UnitIsUnit(sender, "target") then
					ExiWoW.TARGET = Character:new(data, sender);
					local offset = 0;
					if ExiWoW.TARGET:isFemale() then offset = 0.25;
					elseif not ExiWoW.TARGET:isMale() then offset = 0.5; end
					UI.portrait.targetHasExiWoWFrame.genderTexture:SetTexCoord(offset,offset+0.25,0,1);
					UI.portrait.targetHasExiWoWFrame:Show();
				end
			end
		end,
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, data)
			return true, ExiWoW.ME:export(true)
		end

	})

	-- Disrobe --
	extension:addAction({
		id = "DISROBE",
		name = "Disrobe",
		description = "Removes a piece of armor from your target.",
		texture = "ability_rogue_plunderarmor",
		--cooldown = 120,
		cooldown = 10,
		cast_time = 2,
		cast_sound_loop = 6425,				-- Tailoring, see http://www.wowhead.com/sound=6425/tailoring
		conditions = {
			Condition.get("require_stealth"),
			Condition.get("victim_no_combat"),
			Condition.get("sender_no_combat"),
			Condition.get("require_party"),
			Condition.get("sender_not_moving"),
			Condition.get("melee_range"),
		},
		not_defaults = {},

		-- allow_self = false,
		fn_cast = function(self, sender, target, suppressErrors)
			DoEmote("KNEEL", target);
		end,
		-- Custom sending logic
		fn_send = function(self, sender, target, suppressErrors)

			-- Return no data, but one callback
			return nil, function(se, success, data)
				if not success then
					if data and data[1] then Tools.reportError(data[1], suppressErrors); end
					self:resetCooldown();
				else
					PlaySound(1202, "SFX");
					Tools.reportError(
						Tools.unitRpName(sender) .. " successfully removed "..
						Ambiguate(UnitName(target), "all").."'s "..
						Tools.itemSlotToname(data.slot).."!"
					);
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
			Character:removeEquipped(slot);
			Tools.reportError(Tools.unitRpName(sender) .. " tugged off your "..Tools.itemSlotToname(slot).."!");
			if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") then 
				PlaySound(1202, "SFX");
			end
			return true, {slot=slot}
		end

	})

	-- meditate --
	extension:addAction({
		id = "MEDITATE",
		name = "Meditate",
		description = "Meditate for a while, allowing your excitement to fade at a greatly increased rate.",
		texture = "monk_ability_transcendence",
		cooldown = 0,
		important = true,
		conditions = {
			Condition.get("sender_no_combat"),
			Condition.get("sender_not_moving"),
			Condition.get("only_selfcast"),
		},
		not_defaults = {},
		-- Handle the receiving end here
		fn_receive = function(self, sender, target, suppressErrors)

			if ExiWoW.ME.meditating then
				return Tools.reportError("You are already meditating!");
			end

			-- Start meditation --
			DoEmote("SIT");
			ExiWoW.ME.meditating = true;
			ExiWoW.ME:toggleResting(true)
			Event.on("PLAYER_STARTED_MOVING", function()
				ExiWoW.ME:toggleResting(false)
				ExiWoW.ME.meditating = false;
			end, 1);
			return true

		end
	})

	-- Spot excitement (Public, melee range) --
	extension:addAction({
		id = "ASSESS",
		name = "Assess",
		important = true,
		description = "Take a good look at your target, revealing some information about them.",
		texture = "inv_darkmoon_eye",
		cooldown = 0,
		conditions = {
			Condition.get("melee_range"),
		},
		not_defaults = {
			"party_restricted"
		},
		fn_send = function(self, sender, target, suppressErrors)
			-- We only need a callback for this
			return nil, function(se, success, data) Action.handleInspectCallback(target, success, data) end
		end,
		fn_receive = function()
			return true, ExiWoW.ME:export(true)
		end
	});

	-- Sniff (Worgen) --
	extension:addAction({
		id = "SNIFF",
		name = "Sniff",
		description = "Sniff out some information about your target from a distance.",
		texture = "inv_wolfdraenormountshadow",
		cooldown = 0,
		conditions = {
			Condition.get("caster_range"),
		},
		filters = {
			Condition:new({type=Condition.Types.RTYPE_RACE, data={Worgen=true}, sender=true})
		},
		not_defaults = {
			"party_restricted",
		},
		fn_send = function(self, sender, target, suppressErrors)
			DoEmote("SNIFF", target);
			-- Callback
			return nil, function(se, success, data) Action.handleInspectCallback(target, success, data) end
		end,
		fn_receive = function()
			return true, ExiWoW.ME:export(true)
		end
	});

	-- Tickle --
	extension:addAction({
		id = "TICKLE",
		name = "Tickle",
		description = "Tickle a player.",
		texture = "Spell_shadow_fingerofdeath",
		cooldown = 6,
		conditions = {
			Condition.get("melee_range"),
		},
		not_defaults = {},
		fn_send = function(self, sender, target, suppressErrors)
			if not UnitIsUnit(target, "player") then 
				DoEmote("TICKLE", target);
			end
			return self:sendRPText(sender, target, suppressErrors);
		end,
		fn_receive = function(self, sender, target, args)
			DoEmote("GIGGLE", target);
			self:receiveRPText(sender, target, args)
			return true
		end
	});

	-- Wedgie --
	extension:addAction({
		id = "WEDGIE",
		name = "Wedgie",
		description = "Give a player a wedgie, provided they're wearing underwear.",
		texture = "Spell_holy_fistofjustice",
		cooldown = 6,
		conditions = {
			Condition.get("targetWearsUnderwear"),
			Condition.get("melee_range"),
		},
		no_defaults = {
			"party_restricted"
		},
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
					if success and not UnitIsUnit(target, "player") then
					ExiWoW.LibAssets.effects:painSound(race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			DoEmote("GASP");
			ExiWoW.LibAssets.effects.addExcitementMasochisticDefault();
			self:receiveRPText(sender, target, args);
			return true
		end
	});

	-- Forage --
	extension:addAction({
		id = "FORAGE",
		name = "Forage",
		description = "Search your active area for items.",
		texture = "icon_treasuremap",
		cooldown = 0,
		cast_sound_loop = 1104,
		cast_time = 3,
		conditions = {
			Condition.get("only_selfcast"),
			Condition.get("sender_not_moving"),
		},
		not_defaults = {},
		fn_cast = function(self, sender, target, suppressErrors)
			DoEmote("KNEEL", target);
		end,
		fn_send = function(self, sender, target, suppressErrors)
			return nil;
		end,
		fn_receive = function(self, sender, target, args)
			Character.forage()
			return true
		end
	});

	-- Pace --
	extension:addAction({
		id = "PACE",
		name = "Pace",
		description = "First use: Stake a starting point. Second use: Get the distance from the starting point, measured in map coordinates.",
		texture = "ability_tracking",
		cooldown = 0,
		conditions = {
			Condition.get("only_selfcast"),
		},
		not_defaults = {},
		fn_send = function(self, sender, target, suppressErrors)
			return nil;
		end,
		fn_receive = function(self, sender, target, args)
			SetMapToCurrentZone()
			local px,py = GetPlayerMapPosition("player")
			px = px*100
			py = py*100

			if self.starting_point then
				local x = self.starting_point.x
				local y = self.starting_point.y
				local dist = math.floor(math.sqrt((px-x)*(px-x)+(py-y)*(py-y))*100)/100
				self.starting_point = nil
				RPText.print("You are comfortable that you paced a distance of "..dist.." units")
				PlaySound(73276, "SFX")
			else
				self.starting_point = {x=px, y=py}
				PlaySound(42485, "SFX")
				RPText.print("You stake a starting point at X:"..(math.floor(px*100)/100)..", Y:"..(math.floor(py*100)/100))
			end
			return true
		end
	});










		-- Consumable --
	extension:addAction({
		id = "THROW_SAND",
		name = "Sand",
		description = "Throw sand at your target.",
		max_charges = 10,
		charges = 0,
		texture = "spell_sandexplosion",
		cooldown = 0,
		cast_time = 0.5,
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					ExiWoW.LibAssets.effects:painSound(race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			self:receiveRPText(sender, target, args)
			ef.addExcitementMasochisticDefault();
			return true
		end
	});

	-- Claw pinch
	extension:addAction({
		id = "CLAW_PINCH",
		name = "Claw Pinch",
		description = "Use your large claw to pinch your target.",
		charges = 0,
		texture = "inv_misc_claw_lobstrok_red",
		cooldown = 0,
		fn_send = function(self, sender, target, suppressErrors)
			local race = UnitRace(target)
			local gender = UnitSex(target)
			return self:sendRPText(sender, target, suppressErrors, function(se, success)
				if success and not UnitIsUnit(target, "player") then
					ExiWoW.LibAssets.effects:painSound(race, gender)
				end
			end);
		end,
		fn_receive = function(self, sender, target, args)
			self:receiveRPText(sender, target, args)
			ef.addExcitementMasochisticDefault();
			return true
		end
	});
	

end