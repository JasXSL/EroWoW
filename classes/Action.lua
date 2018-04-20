local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;
local UI, Database, Tools, Timer, RPText, Character, Event, Index;	-- These are setup in ini

local Action = {}
Action.__index = Action;

	Action.GCD = false;				-- On global cooldown
	Action.GCD_TIMER = 0;
	Action.GCD_SECONDS = 1.5;
	Action.GCD_STARTED = 0;
	-- Consts
	Action.MELEE_RANGE = {37727};				-- These are itemIDs, used with 
	Action.CASTER_RANGE = {34471,28767};
	Action.tooltipTimer = 0;					-- Interval for refreshing the tooltip

	-- Cast timer
	Action.CASTING_SPELL = nil;				-- Spell being cast
	Action.CASTING_TIMER = nil;				-- Spell being cast
	Action.CASTING_TARGET = "player";				-- Spell being cast
	Action.CASTING_MOVEMENT_BINDING = nil		-- Event binding for moving while casting 
	Action.CASTING_SPELL_BINDING = nil			-- Event binding for using a blizzard spell while casting
	Action.FINISHING_SPELL_BINDING = nil
	Action.CASTING_SOUND_LOOP = nil;					-- Sound loop
	Action.CASTING_SOUND_FINISH_EVENT = nil;			-- Event handler for making the sound loop
	Action.FRAME_CASTBAR = nil;


	Action.ini = function()

		UI = require("UI");
		Database = require("Database");
		Tools = require("Tools");
		Timer = require("Timer");
		RPText = require("RPText");
		Character = require("Character");
		Event = require("Event");
		Index = require("Index");

		Action.FRAME_CASTBAR = CreateFrame("StatusBar", "ExiWoWCastBar", UIParent, "CastingBarFrameTemplate");
		local sb = Action.FRAME_CASTBAR;
		CastingBarFrame_OnLoad(sb, false, false, false);
		sb:SetSize(195,13);
		sb:SetPoint("CENTER", UIParent, "CENTER", 0, -200);

		--Action.Lib[1]:toggleCastBar(true);
	end
	

	-- Define the class
	function Action:new(data)
		local self = {}
		setmetatable(self, Action);

		if type(data) ~= "table" then
			data = {}
		end

		local getVar = function(v, def)
			if v == nil then return def end
			return v
		end

		-- Settings
		self.id = data.id or ""										-- ID of Action
		self.name = data.name or ""									-- Name of action
		self.description = data.description or ""					-- Description of action
		self.texture = data.texture or ""							-- Texture, does not need a path
		self.cooldown = data.cooldown or 0							-- Internal cooldown
		self.global_cooldown = getVar(data.global_cooldown, true)			-- Affected by global cooldown
		self.alias = data.alias or false							-- Lets you override the ID for a send
		self.cast_time = data.cast_time or 0						-- Cast time of spell
		self.cast_sound_loop = data.cast_sound_loop or false		-- Cast loop sound
		self.cast_sound_start = data.cast_sound_start or false		-- Start cast sound, played once
		self.cast_sound_success = data.cast_sound_success or false	-- Cast success sound, played once
		self.rarity = type(data.rarity) == "number" and data.rarity or 2
		if self.rarity < 1 then self.rarity = 1
		elseif self.rarity > 7 then self.rarity = 7
		end

		self.suppress_all_errors = data.suppress_all_errors or false

		-- Functions
		self.fn_send = data.fn_send									-- Function to execute on the sender when sending
		self.fn_receive = data.fn_receive							-- Function to execute on the receiver when receiving
		self.fn_cast = data.fn_cast									-- Function to execute on the sender when starting a cast
		self.fn_done = data.fn_done									-- Function sent on both success and interrupt

		-- Conditions
		self.self_only = data.self_only or false;					-- Auto targets self
		self.require_stealth = data.require_stealth or false;		-- Require the caster to be in stealth (only caster can be checked)
		self.require_party = getVar(data.require_party, false)		-- Require caster and target to be in the same party. This ignores if  party_restricted is false. You should use it for tasks where the API itself restricts to party.
		self.party_restricted = getVar(data.party_restricted, true)	-- Same as above, but can be turned off in settings
		self.allow_caster_combat = getVar(data.allow_caster_combat, true)	-- Caster can use this in combat
		self.allow_targ_combat = getVar(data.allow_targ_combat, true)		-- Target can receive this in combat

		self.max_distance = data.max_distance or 0;					-- Sets a max spell distance, this value is actually an item ID
		self.allow_self = getVar(data.allow_self, true)				-- Allow self cast
		self.allow_stunned = data.allow_stunned or false; 				-- Allow to be used when caster is stunned
		self.allow_targ_moving = getVar(data.allow_targ_moving, true)			-- Can't use this on a moving target
		self.allow_caster_moving = getVar(data.allow_caster_moving, true)		-- Can't use this while you're moving
		self.allow_instance = data.allow_instance or false;				-- Allow in instances
		self.allow_caster_dead = data.allow_caster_dead or false;		-- Allow if caster is dead
		self.allow_targ_dead = data.allow_targ_dead or false;			-- Allow if target is dead
		self.max_charges = type(data.max_charges) == "number" and data.max_charges or math.huge;

		self.allow_in_vehicle = data.allow_in_vehicle or false;			-- Allow if either player is in a vehicle

		-- These CASTER conditions are used in filtering
		self.allowed_classes = data.allowed_classes or false;			-- Allowable classes, use classIndex: http://wowwiki.wikia.com/wiki/API_UnitClass
		self.allowed_races = data.allowed_races or false;				-- Allowable races, use raceEn: http://wowwiki.wikia.com/wiki/API_UnitRace
		self.disallowed_classes = data.disallowed_classes or false;		-- Nonallowed classes, use classIndex: http://wowwiki.wikia.com/wiki/API_UnitClass
		self.disallowed_races = data.disallowed_races or false;			-- Nonallowed races, use raceEn: http://wowwiki.wikia.com/wiki/API_UnitRace
		
		self.charges = data.charges or math.huge;						-- Charges tied to this spell. Charges can be added by loot?

		self.target_has_underwear = data.target_has_underwear;			-- Nil = either, false = no underwear, true = has underwear, table = {name=true, name2=true...}

		-- Convert to sets
		if self.allowed_classes ~= false then self.allowed_classes = Tools.createSet(self.allowed_classes); end
		if self.allowed_races ~= false then self.allowed_races = Tools.createSet(self.allowed_races); end
		


		-- Custom
		self.hidden = data.hidden or false;								-- Hides action from action window
		self.learned = getVar(data.learned, true);						-- This spell needs to be learned
		self.favorite = data.favorite or false;							-- Gets priority above the rest
		self.important = data.important or false;						-- Gets priority below favorite

		-- Internal
		self.on_cooldown = false
		self.cooldown_timer = 0;
		self.cooldown_started = 0;
		

		return self;
	end





			-- Methods --
	-- Saving & Loading --

	function Action:import(data)

		-- Importable args
		if data.learned ~= nil and not self.learned then self.learned = not not data.learned end
		if data.favorite ~= nil then self.favorite = not not data.favorite end
		if data.cooldown_started and data.cooldown_started+self.cooldown > GetTime() then 
			self:setCooldown(self.cooldown+data.cooldown_started-GetTime(), true);
			self.cooldown_started = data.cooldown_started;
		else
			self.cooldown_started = 0;
		end
		if data.charges then self.charges = data.charges end
		if self.charges == "INF" then self.charges = math.huge end

	end

	function Action:export()

		local charges = self.charges
		if charges == math.huge then charges = "INF" end
		return {
			id = self.id,
			learned = self.learned,
			favorite = self.favorite,
			cooldown_started = self.cooldown_started,
			charges = charges
		};

	end


	-- Charges
	function Action:consumeCharges(nr)
		if not nr then nr = 1 end

		-- Not enough charges
		if self.charges-nr < 0 then return false end

		self.charges = self.charges-nr;
		if self.charges > self.max_charges then self.charges = self.max_charges end
		UI.actionPage.update();
		return true;

	end


	function Action:setCooldown(overrideTime, ignoreGlobal)

		-- This action is completely excempt from cooldowns
		if (ignoreGlobal or not self.global_cooldown) and self.cooldown <= 0 then return end

		if self.global_cooldown and not ignoreGlobal then
			Action:setGlobalCooldown();
		end

		local cd = self.cooldown;
		if overrideTime then cd = overrideTime end;

		self:resetCooldown();
		if cd > 0 then
			self.on_cooldown = true;
			self.cooldown_started = GetTime();
			Timer.set(function(se)
				self:resetCooldown();
			end, cd);
		end
		UI.actionPage.update();


	end

	function Action:setGlobalCooldown()

		Action.GCD = true;
		Action.GCD_STARTED = GetTime();
		Timer.clear(Action.GCD_TIMER);
		Timer.set(function()
			Action.GCD = false;
			Action.GCD_STARTED = 0;
		end, Action.GCD_SECONDS);
		UI.actionPage.update();

	end

	function Action:resetCooldown()

		self.on_cooldown = false;
		Timer.clear(self.cooldown_timer);
		self.cooldown_started = 0;
		UI.actionPage.update();

	end

	-- Returns when cooldown started and how long it is
	function Action:getCooldown()

		local gl = Action.GCD_SECONDS+Action.GCD_STARTED;
		local ll = self.cooldown_started+self.cooldown;

		local ctime = GetTime();
		-- We're not on a cooldown --
		if ll < ctime and gl < ctime then return 0, 0 end

		-- Global cooldown is longer
		if gl > ll then
			return Action.GCD_STARTED, Action.GCD_SECONDS;
		end

		-- Local cooldown --
		return self.cooldown_started, self.cooldown;

	end

	-- Validates conditions used in ability display
	function Action:validateFiltering(caster, suppressErrors)

		local _, _, cls = UnitClass(caster);
		local _, rname = UnitRace(caster);

		if self.allowed_classes ~= false and not self.allowed_classes[cls] then
			return Tools.reportError("Invalid class.", suppressErrors)
		end

		if self.allowed_races ~= false and not self.allowed_races[rname] then
			return Tools.reportError("Invalid race.", suppressErrors)
		end
		
		if self.disallowed_classes ~= false and self.disallowed_classes[cls] then
			return Tools.reportError("Invalid class.", suppressErrors)
		end

		if self.disallowed_races ~= false and self.disallowed_races[rname] then
			return Tools.reportError("Invalid race.", suppressErrors)
		end
		

		-- Send validation
		if caster == "player" then
			
			if self.charges < 1 then
				return Tools.reportError("Not enough charges.", suppressErrors)
			end

			if not self.learned then
				return Tools.reportError("Spell not learned.", suppressErrors)
			end

		end

		return true;

	end


	-- Condition validation
	-- Validates for both receive and send --
	-- Returns boolean true on success
	function Action:validate(unitCaster, unitTarget, suppressErrors, isSend, isCastComplete)

		if self.suppress_all_errors then suppressErrors = true end -- Allow actions to suppress errors - 
		
		-- Make sure it's not on cooldown
		if isSend and not isCastComplete and (self.on_cooldown or (self.global_cooldown and Action.GCD)) then
			return Tools.reportError("Can't do that yet", suppressErrors);
		end

		local inInstance = IsInInstance()
		if inInstance and not self.allow_instance then
			return Tools.reportError("Can't be used in instances.", suppressErrors)
		end

		-- Make sure target and caster are actual units
		unitCaster = Ambiguate(unitCaster, "all")
		unitTarget = Ambiguate(unitTarget, "all")
		if not UnitExists(unitCaster) then
			return Tools.reportError("Caster does not exist", suppressErrors);
		end
		if not UnitExists(unitTarget) then
			return Tools.reportError("No viable target", suppressErrors);
		end

		if not UnitIsPlayer(unitCaster) or not UnitIsPlayer(unitTarget) then
			return Tools.reportError("Target is not a player", suppressErrors);
		end

		if not self.allow_in_vehicle and (UnitInVehicle(unitCaster) or UnitInVehicle(unitTarget)) then
			return Tools.reportError("Target is in a vehicle", suppressErrors);
		end

		if not Index.checkHardLimits(unitCaster, unitSender, suppressErrors) then
			return false;
		end

		-- Validate filtering. Filtering is also used in if a spell should show up whatsoever
		if not self:validateFiltering(unitCaster, suppressErrors) then return false end


		-- Check self cast
		local isSelf =
			(unitCaster == "player" and UnitIsUnit(unitTarget, "player")) or
			(unitTarget == "player" and UnitIsUnit(unitCaster, "player"));
		if not self.allow_self and isSelf then
			return Tools.reportError("Action can not target self", suppressErrors);
		end

		-- Unit must be in a party or raid
		local inParty = UnitInRaid(unitCaster) or UnitInParty(unitCaster) or UnitInRaid(unitTarget) or UnitInRaid(unitTarget) or isSelf
		if not inParty and self.require_party then
			return Tools.reportError("Target is not in your party or raid", suppressErrors);
		end

		-- Check dead
		if UnitIsDeadOrGhost(unitCaster) and not self.allow_caster_dead then
			return Tools.reportError("You are dead.", suppressErrors);
		end
		if UnitIsDeadOrGhost(unitTarget) and not self.allow_targ_dead then
			return Tools.reportError("Your target is dead", suppressErrors);
		end

		

		-- Unit in range
		if self.max_distance ~= 0 and (not self:checkRange(unitTarget) or not self:checkRange(unitCaster)) then
			return Tools.reportError("Too far away!", suppressErrors);
		end

		-- Check combat
		if not self.allow_targ_combat and UnitAffectingCombat(unitTarget) then
			return Tools.reportError("Target is in combat", suppressErrors);
		end
		if not self.allow_targ_combat and UnitAffectingCombat(unitTarget) then
			return Tools.reportError("You are in combat", suppressErrors);
		end



		-- Validations only when SENDING (these are limited to caster) --
		if unitCaster == "player" then

			-- Make sure we're not stunned
			local pl = ExiWoW.ME;
			if not HasFullControl() and not self.allow_stunned then
				return Tools.reportError("Can't use actions right now", suppressErrors);
			end

			-- Stealth
			if not IsStealthed() and self.require_stealth then
				return Tools.reportError("You must be in stealth to use this action!", suppressErrors);
			end

			-- Unit movement --
			if not self.allow_caster_moving and GetUnitSpeed(unitCaster) > 0 then
				return Tools.reportError("Can't use while moving", suppressErrors);
			end
			if not self.allow_targ_moving and GetUnitSpeed(unitTarget) > 0 then
				return Tools.reportError("Can't use on a moving target", suppressErrors);
			end

		-- Validate when RECEIVING --
		else
		end

		-- Underwear
		if self.target_has_underwear ~= nil then
			local pl = ExiWoW.TARGET;

			if unitTarget == "player" then
				pl = ExiWoW.ME;
			end
			
			if not pl then 
				return Tools.reportError("Target data missing. Try re-targeting!", suppressErrors);
			end
			local uw = pl:getUnderwear()
			if self.target_has_underwear == false and uw ~= false then
				return Tools.reportError("Target is wearing underwear!", suppressErrors);
			elseif self.target_has_underwear == true and uw == false then
				return Tools.reportError("Target is not wearing underwear!", suppressErrors);
			elseif type(self.target_has_underwear) == "table" and (not uw or not self.target_has_underwear[uw.id]) then
				return Tools.reportError("Target is not wearing the required underwear!", suppressErrors);
			end
		end

		return true

	end

	function Action:checkRange(target, item)
		if not item then item = self.max_distance end
		for i,v in ipairs(item) do
			if IsItemInRange(v, target) then
				return true;
			end
		end
		return false;
	end


		-- TOOLTIP HANDLING --
	function Action:onTooltip(frame)

		Timer.clear(Action.tooltipTimer);
		if not not frame then

			-- Set timer for refreshing
			local th = self
			Action.tooltipTimer = Timer.set(function()
				th:drawTooltip()
			end, 0.25, math.huge);

			GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
			self:drawTooltip();

		else

			GameTooltip:Hide();

		end


	end

		-- Returns range in yards based on the range consts --
	function Action.getRangeYards()
		return 40;
	end


	function Action:drawTooltip()

		local v = self
		GameTooltip:ClearLines()
		GameTooltip:AddLine(v.name, 1, 1, 1)

		-- CD --
		local started, duration = v:getCooldown();
		local singles = {}

		if v.cast_time > 0 then
			table.insert(singles, Tools.timeFormat(v.cast_time).." cast");
		else
			table.insert(singles, "Instant")
		end

		if not v.self_only and v.max_distance then
			if v.max_distance == Action.MELEE_RANGE then
				table.insert(singles, "Melee Range");
			else
				table.insert(singles, tostring(v:getRangeYards()).." yd range");
			end
		end

		if v.cooldown > 0 then
			table.insert(singles, Tools.timeFormat(v.cooldown).." cooldown");
		end

		local c = 0.8	-- Brightness of text
		local x = 0		-- Iterator for double texts
		local pre = ""	-- Previous text
		-- a starts at 1 because hurdurlua
		for a,text in pairs(singles) do
			if a%2 == 0 then
				GameTooltip:AddDoubleLine(pre, text, c,c,c,c,c,c);
			else 
				pre = text
			end
			x = x+1;
		end
		if x%2 == 1 then
			GameTooltip:AddLine(pre, c,c,c);
		end

		

		if v.require_stealth then
			GameTooltip:AddLine("Requires Stealth", c,c,c);
		end

		if not v.self_only then

			if v.require_party then
				GameTooltip:AddLine("Requires Party Member", c,c,c);
			elseif v.party_restricted then
				GameTooltip:AddLine("Party Restricted", c,c,c);
			end

		end

		if not v.allow_caster_combat or not v.allow_targ_combat then
			GameTooltip:AddLine("Disabled in Combat", c,c,c);
		end

		if started > 0 then
			GameTooltip:AddLine("Cooldown remaining: "..tostring(Tools.timeFormat(duration-(GetTime()-started))), 1, 1,1, 0.75);
		end


		GameTooltip:AddLine(v.description, nil, nil, nil, true)
		GameTooltip:Show()

	end

		-- CASTBAR --
	-- Shows castbar for this action, or can be used statically to turn off
	function Action:toggleCastBar(on)


		local sb = Action.FRAME_CASTBAR;

		if not on then
			-- Hide
			sb.casting = false;
			sb:Hide();
			return;
		end

		local startColor = CastingBarFrame_GetEffectiveStartColor(sb, false, notInterruptible);
		sb:SetStatusBarColor(startColor:GetRGB());
		if sb.flashColorSameAsStart then
			sb.Flash:SetVertexColor(startColor:GetRGB());
		else
			sb.Flash:SetVertexColor(1, 1, 1);
		end

		--sb.Spark:Show();

		sb.value = 0;
		sb.maxValue = self.cast_time;
		sb:SetMinMaxValues(0, sb.maxValue);
		sb:SetValue(sb.value);
		
		sb.Text:SetText(self.name);
		CastingBarFrame_ApplyAlpha(sb, 1.0);

		sb.holdTime = 0;
		sb.casting = true;
		sb.castID = 0;
		sb.channeling = nil;
		sb.fadeOut = nil;

		if self.texture then 
			sb.Icon:SetTexture("Interface/Icons/"..self.texture);
		end
		
		sb:Show();

	end


	-- Template functions for callbacks and such --
	function Action:sendRPText(sender, target, suppressErrors, callback)

		local ts = ExiWoW.ME;
		local tt = ExiWoW.CAST_TARGET;
		if UnitIsUnit(target, "player") then tt = ts; end -- Self cast

		local id = self.id;
		if self.alias then id = self.alias end
		local rptext = RPText.get(id, ts, tt);

		if not rptext then return false end
		-- Send the text
		return {
			t=rptext.text_receiver,
			se=ts:export(true),
			so=rptext.sound,
			i=rptext.item
		}, 
		-- Callback
		function(se, success, data) 
			if success then

				if type(callback) == "function" then
					callback(se, success, data);
				end

				if rptext.sound then
					PlaySound(rptext.sound, "SFX");
				end
				local tx = rptext.text_sender
				
				if type(data) == "table" and data.receiver then 
					tx = rptext.text_receiver 
				end

				if tx then 
					RPText.print(RPText.convert(tx, ts, tt, nil, rptext.item))
				end

				if rptext.text_bystander then
					Index.sendBystanderText(RPText.convert(rptext.text_bystander, ts, tt, nil, rptext.item))
				end
			end
		end
	end

	function Action:receiveRPText( sender, target, args)

		if args.t and args.se then
			local ts = Character:new(args.se, sender);
			RPText.print(RPText.convert(args.t, ts, ExiWoW.ME, nil, args.i))
		end
		
		-- Play receiving sound if not self cast
		if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") and args.so then 
			PlaySound(args.so, "SFX");
		end
	end




-- STATIC --

	function Action.sort()
		Database.sort("Action", function(a,b)
			local aimportance = (a.favorite and 1 or 0)*2+(a.important and 1 or 0);
			local bimportance = (b.favorite and 1 or 0)*2+(b.important and 1 or 0);
			if aimportance > bimportance then return true end
			if aimportance < bimportance then return false end
			return a.name < b.name;
		end)	
	end

	-- Useful stuff for actions --
	function Action.handleInspectCallback(target, success, data)
		-- Fail --
		if not success then return false end

		local char = Character:new(data, target)
		local out = "Inspecting "..Ambiguate(UnitName(target), "all").." you can tell that"
		local muscle = char.muscle_tone
		local fat = char.fat
		local butt = char:getButtSize()
		local breasts = char:getBreastSize()
		local junk = char:getPenisSize()

		local texts = {}
		if muscle < 3 then table.insert(texts, "frail")
		elseif muscle < 5 then table.insert(texts, "weak")
		elseif muscle > 7 then table.insert(texts, "brawny")
		elseif muscle > 5 then table.insert(texts, "toned")
		end
		if fat < 2 then table.insert(texts, "emaciated")
		elseif fat < 4 then table.insert(texts, "slender")
		elseif fat > 7 then table.insert(texts, "corpulent")
		elseif fat > 5 then table.insert(texts, "burly")
		end

		if #texts > 0 then out = out.." they look "..table.concat(texts, ", and ")..". They have"
		else out = out.." they have"
		end

		texts = {}
		if butt == 0 then table.insert(texts, "a flat butt")
		elseif butt == 1 then table.insert(texts, "a small butt")
		elseif butt == 2 then table.insert(texts, "an average butt")
		elseif butt == 3 then table.insert(texts, "a large butt")
		elseif butt == 4 then table.insert(texts, "a huge butt")
		end
		if breasts == false then table.insert(texts, "no breasts")
		elseif breasts == 0 then table.insert(texts, "a mostly flat chest")
		elseif breasts == 1 then table.insert(texts, "a small chest")
		elseif breasts == 2 then table.insert(texts, "average sized breasts")
		elseif breasts == 3 then table.insert(texts, "a large chest")
		elseif breasts == 4 then table.insert(texts, "a huge chest")
		end
		if junk == 0 then table.insert(texts, "a barely visible pants bulge")
		elseif junk == 1 then table.insert(texts, "a small pants bulge")
		elseif junk == 2 then table.insert(texts, "an average pants bulge")
		elseif junk == 3 then table.insert(texts, "a generous pants bulge")
		elseif junk == 4 then table.insert(texts, "a massive pants bulge")
		end
		
		if #texts > 0 then
			out = out.." "..table.concat(texts, " and ")
		end
		out = out.."."

		if char.excitement > 0 then
			out = out.."\nThey "
			if char.excitement < 0.25 then out = out.."seem a little flustered"
			elseif char.excitement < 0.5 then out = out.."seem somewhat flustered"
			elseif char.excitement < 0.75 then out = out.."seem pretty flustered"
			elseif char.excitement < 1 then out = out.."seem very flustered"
			else out = out.."are fidgeting, looking highly uncomfortable"
			end
			out = out.."."
		end

		RPText.print(out);
	end


	-- Get from library by id
	function Action.get(id)

		local lib = Database.filter("Action");
		for i, act in pairs(lib) do
			if act.id == id then return act end
		end
		return false

	end

	-- Send an action, id can also be an action
	function Action.useOnTarget(id, target, castFinish)

		if Action.CASTING_SPELL then
			return Tools.reportError("You are already using an action!");
		end

		-- Find the action
		local action = id;
		if type(action) ~= "table" then
			action = Action.get(id);
			if not action then
				return Tools.reportError("Action not found: "..id);
			end
		end

		-- Self cast actions don't need to send a message
		if action.self_only or not UnitExists("target") then
			target = "player"
		end

		if action.charges-1 < 0 then
			return Tools.reportError("Not enough charges");
		end

		-- Validate conditions
		if not action:validate("player", target, ignoreErrors, true, castFinish) then return false end

		-- Set cooldowns etc

		-- Use special function, if it returns false, then prevent default behavior
		local args = {}
		local callback = nil
		
		-- Default send logic

		ExiWoW.CAST_TARGET = ExiWoW.TARGET

		if not castFinish then Action:setGlobalCooldown() end

		if action.cast_time <= 0 or castFinish then 

			Event.raise(Event.Types.ACTION_SENT, {id=action.id, target=target})
			if type(action.fn_done) == "function" then action:fn_done(true) end
			if type(action.fn_send) == "function" then
				args, callback = action:fn_send("player", target, suppressErrors);
				if args == false then return false end -- Return false from your custom function to prevent a send
			end

			

			-- Finish cast
			action:setCooldown(false, true);
			-- Send to target
			local first,last = UnitName(target)
			if last then first = first.."-"..last end
			Index.sendAction(Ambiguate(first, "all"), action.id, args, function(...)
				if type(callback) == "function" then callback(...) end
				local self, success = ...
				Event.raise(Event.Types.ACTION_USED, {id=id, target=target, args=args, success=success})
				if success then
					action:consumeCharges(1);
				end
			end)
			
		else 
			-- Start cast
			Action.beginSpellCast(action, target);
		end

	end


	-- Receive an action
	function Action.receive(id, sender, args, allowErrors)

		local action = Action.get(id);
		if not action then return false end			-- Received Action not found

		-- Received action is invalid
		if not action:validate(sender, "player", not allowErrors, false, false) then 
			return false 
		end

		-- Returns (bool)success, (var)data
		if type(action.fn_receive) == "function" then
			return action:fn_receive(sender, "player", args);
		else return true
		end
	end

	-- Tools for conditions
	function Action.computeDistance(x1,y1,z1,x2,y2,z2, instance1, instance2)
		if instance1 ~= instance2 then return end
		return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2-z1) ^ 2) ^ 0.5
	end

	function Action.beginSpellCast(action, target)

		Action:endSpellCast(false);
		Action.CASTING_SPELL = action;
		Action.CASTING_TARGET = Ambiguate( UnitName(target), "all" );
		-- Timer
		Action.CASTING_TIMER = Timer.set(function()
			Action:endSpellCast(true);
		end, action.cast_time);

		-- Cast bar
		action:toggleCastBar(true);

		if type(action.fn_cast) == "function" then
			action:fn_cast("player", target, suppressErrors)
		end

		local interrupt = function()
			PlaySound(10846, "SFX");
			Tools.reportError("Interrupted");
			Action.endSpellCast(false);
			if type(action.fn_done) == "function" then action:fn_done(false) end
		end

		if action.cast_sound_start then
			PlaySound(action.cast_sound_start, "SFX")
		end

		-- Audio loop
		if action.cast_sound_loop then
			local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
			Action.CASTING_SOUND_LOOP = handle;
			Action.CASTING_SOUND_FINISH_EVENT = Character.bind("SOUNDKIT_FINISHED", function(data)
				if data[1] == Action.CASTING_SOUND_LOOP then 
					local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
					Action.CASTING_SOUND_LOOP = handle;
				end
			end)
		end

		-- Move interrupt
		if not action.allow_caster_moving then
			Action.CASTING_MOVEMENT_BINDING = Character.bind("PLAYER_STARTED_MOVING", interrupt)
		end

		-- Official effect
		Action.CASTING_SPELL_BINDING = Character.bind("UNIT_SPELLCAST_START", function(data)
			if UnitIsUnit(data[1], "PLAYER") then interrupt() end
		end)
		Action.FINISHING_SPELL_BINDING = Character.bind("UNIT_SPELLCAST_SUCCESS", function(data)
			if UnitIsUnit(data[1], "PLAYER") then interrupt() end
		end)

		
	end

	function Action.endSpellCast(success)

		-- Make sure we are actually casting --
		if not Action.CASTING_SPELL then return end

		local self = Action.CASTING_SPELL;
		
		Character.unbind(Action.CASTING_MOVEMENT_BINDING);
		Character.unbind(Action.CASTING_SPELL_BINDING);
		Character.unbind(Action.FINISHING_SPELL_BINDING);
		Character.unbind(Action.CASTING_SOUND_FINISH_EVENT);

		-- Let it play the fade out animation
		if not success then
			Event.raise(Event.Types.ACTION_INTERRUPTED, {id=Action.CASTING_SPELL.id, target=Action.CASTING_TARGET})
			Action:toggleCastBar(false);
		end

		if Action.CASTING_SOUND_LOOP then
			StopSound(Action.CASTING_SOUND_LOOP);
			Action.CASTING_SOUND_LOOP = nil
		end

		if success and self.cast_sound_success then
			PlaySound(self.cast_sound_success, "SFX")
		end

		Timer.clear(Action.CASTING_TIMER);
		Timer.clear(Action.CASTING_INTERVAL);
		
		local c = Action.CASTING_SPELL
		Action.CASTING_SPELL = nil;
		if success then
			Action.useOnTarget(c, Action.CASTING_TARGET, true);
		end

	end

export(
	"Action", 
	Action,
	{
		sort = Action.sort,
		get = Action.get,
		useOnTarget = Action.useOnTarget,
		endSpellCast = Action.endSpellCast
	},
	Action
)
