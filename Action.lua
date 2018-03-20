local appName, internal = ...

ExiWoW.Action = {}
ExiWoW.Action.__index = ExiWoW.Action;
	ExiWoW.Action.LIB = {}
	ExiWoW.Action.GCD = false;				-- On global cooldown
	ExiWoW.Action.GCD_TIMER = 0;
	ExiWoW.Action.GCD_SECONDS = 1.5;
	ExiWoW.Action.GCD_STARTED = 0;
	-- Consts
	ExiWoW.Action.MELEE_RANGE = {37727};				-- These are itemIDs, used with 
	ExiWoW.Action.CASTER_RANGE = {34471,28767};
	ExiWoW.Action.tooltipTimer = 0;					-- Interval for refreshing the tooltip

	-- Cast timer
	ExiWoW.Action.CASTING_SPELL = nil;				-- Spell being cast
	ExiWoW.Action.CASTING_TIMER = nil;				-- Spell being cast
	ExiWoW.Action.CASTING_TARGET = "player";				-- Spell being cast
	ExiWoW.Action.CASTING_MOVEMENT_BINDING = nil		-- Event binding for moving while casting 
	ExiWoW.Action.CASTING_SPELL_BINDING = nil			-- Event binding for using a blizzard spell while casting
	ExiWoW.Action.FINISHING_SPELL_BINDING = nil
	ExiWoW.Action.CASTING_SOUND_LOOP = nil;					-- Sound loop
	ExiWoW.Action.CASTING_SOUND_FINISH_EVENT = nil;			-- Event handler for making the sound loop
	ExiWoW.Action.FRAME_CASTBAR = nil;

-- Define the class
function ExiWoW.Action:new(data)
	local self = {}
	setmetatable(self, ExiWoW.Action);

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
	
	self.cast_time = data.cast_time or 0						-- Cast time of spell
	self.cast_sound_loop = data.cast_sound_loop or false		-- Cast loop sound
	self.cast_sound_start = data.cast_sound_start or false		-- Start cast sound, played once
	self.cast_sound_success = data.cast_sound_success or false	-- Cast success sound, played once

	self.suppress_all_errors = data.suppress_all_errors or false

	-- Functions
	self.fn_send = data.fn_send									-- Function to execute on the sender when sending
	self.fn_receive = data.fn_receive							-- Function to execute on the receiver when receiving


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

	-- These CASTER conditions are used in filtering
	self.allowed_classes = data.allowed_classes or false;			-- Allowable classes, use classIndex: http://wowwiki.wikia.com/wiki/API_UnitClass
	self.allowed_races = data.allowed_races or false;				-- Allowable races, use raceEn: http://wowwiki.wikia.com/wiki/API_UnitRace
	self.disallowed_classes = data.disallowed_classes or false;		-- Nonallowed classes, use classIndex: http://wowwiki.wikia.com/wiki/API_UnitClass
	self.disallowed_races = data.disallowed_races or false;			-- Nonallowed races, use raceEn: http://wowwiki.wikia.com/wiki/API_UnitRace
	
	self.charges = data.charges or math.huge;						-- Charges tied to this spell. Charges can be added by loot?
	
	-- Convert to sets
	if self.allowed_classes ~= false then self.allowed_classes = ExiWoW:Set(self.allowed_classes); end
	if self.allowed_races ~= false then self.allowed_races = ExiWoW:Set(self.allowed_races); end
	


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

function ExiWoW.Action:import(data)

	-- Importable args
	if data.learned ~= nil and not self.learned then self.learned = not not data.learned end
	if data.favorite ~= nil then self.favorite = not not data.favorite end
	if data.cooldown_started and data.cooldown_started+self.cooldown > GetTime() then 
		self:setCooldown(self.cooldown+data.cooldown_started-GetTime(), true);
		self.cooldown_started = data.cooldown_started;
	end
	if data.charges ~= nil then self.charges = data.charges end

end

function ExiWoW.Action:export()

	return {
		id = self.id,
		learned = self.learned,
		favorite = self.favorite,
		cooldown_started = self.cooldown_started
	};

end



function ExiWoW.Action:setCooldown(overrideTime, ignoreGlobal)

	-- This action is completely excempt from cooldowns
	if (ignoreGlobal or not self.global_cooldown) and self.cooldown <= 0 then return end

	if self.global_cooldown and not ignoreGlobal then
		ExiWoW.Action:setGlobalCooldown();
	end

	local cd = self.cooldown;
	if overrideTime then cd = overrideTime end;

	self:resetCooldown();
	if cd > 0 then
		self.on_cooldown = true;
		self.cooldown_started = GetTime();
		ExiWoW.Timer:set(function(se)
			self:resetCooldown();
		end, cd);
	end
	ExiWoW.Menu:refreshSpellsPage();


end

function ExiWoW.Action:setGlobalCooldown()

	ExiWoW.Action.GCD = true;
	ExiWoW.Action.GCD_STARTED = GetTime();
	ExiWoW.Timer:clear(ExiWoW.Action.GCD_TIMER);
	ExiWoW.Timer:set(function()
		ExiWoW.Action.GCD = false;
		ExiWoW.Action.GCD_STARTED = 0;
	end, ExiWoW.Action.GCD_SECONDS);
	ExiWoW.Menu:refreshSpellsPage();

end

function ExiWoW.Action:resetCooldown()

	self.on_cooldown = false;
	ExiWoW.Timer:clear(self.cooldown_timer);
	self.cooldown_started = 0;
	ExiWoW.Menu:refreshSpellsPage();

end

-- Returns when cooldown started and how long it is
function ExiWoW.Action:getCooldown()

	local gl = ExiWoW.Action.GCD_SECONDS+ExiWoW.Action.GCD_STARTED;
	local ll = self.cooldown_started+self.cooldown;

	local ctime = GetTime();
	-- We're not on a cooldown --
	if ll < ctime and gl < ctime then return 0, 0 end

	-- Global cooldown is longer
	if gl > ll then
		return ExiWoW.Action.GCD_STARTED, ExiWoW.Action.GCD_SECONDS;
	end

	-- Local cooldown --
	return self.cooldown_started, self.cooldown;

end

-- Validates conditions used in ability display
function ExiWoW.Action:validateFiltering(caster, suppressErrors)

	local _, _, cls = UnitClass(caster);
	local _, rname = UnitRace(caster);

	if self.allowed_classes ~= false and not self.allowed_classes[cls] then
		return ExiWoW:reportError("Invalid class.", suppressErrors)
	end

	if self.allowed_races ~= false and not self.allowed_races[rname] then
		return ExiWoW:reportError("Invalid race.", suppressErrors)
	end
	
	if self.disallowed_classes ~= false and self.disallowed_classes[cls] then
		return ExiWoW:reportError("Invalid class.", suppressErrors)
	end

	if self.disallowed_races ~= false and self.disallowed_races[rname] then
		return ExiWoW:reportError("Invalid race.", suppressErrors)
	end
	

	-- Send validation
	if caster == "player" then
		
		if self.charges < 1 then
			return ExiWoW:reportError("Not enough charges.", suppressErrors)
		end

		if not self.learned then
			return ExiWoW:reportError("Spell not learned.", suppressErrors)
		end

	end

	return true;

end


-- Condition validation
-- Validates for both receive and send --
-- Returns boolean true on success
function ExiWoW.Action:validate(unitCaster, unitTarget, suppressErrors)

	if self.suppress_all_errors then suppressErrors = true end -- Allow actions to suppress errors - 
	
	-- Make sure it's not on cooldown
	if unitCaster == "player" and (self.on_cooldown or (self.global_cooldown and ExiWoW.Action.GCD)) then
		return ExiWoW:reportError("Can't do that yet", suppressErrors);
	end

	local inInstance = IsInInstance()
	if inInstance and not self.allow_instance then
		return ExiWoW:reportError("Can't be used in instances.", suppressErrors)
	end


	-- Make sure target and caster are actual units
	unitCaster = Ambiguate(unitCaster, "all")
	unitTarget = Ambiguate(unitTarget, "all")
	if not UnitExists(unitCaster) then
		return ExiWoW:reportError("Caster does not exist", suppressErrors);
	end
	if not UnitExists(unitTarget) then
		return ExiWoW:reportError("No viable target", suppressErrors);
	end

	if not UnitIsPlayer(unitCaster) or not UnitIsPlayer(unitTarget) then
		return ExiWoW:reportError("Target is not a player", suppressErrors);
	end

	if not internal.checkHardlimits(unitCaster, unitSender, suppressErrors) then
		return false;
	end

	-- Validate filtering. Filtering is also used in if a spell should show up whatsoever
	if not self:validateFiltering(unitCaster, suppressErrors) then return false end


	-- Check self cast
	local isSelf =
		(unitCaster == "player" and UnitIsUnit(unitTarget, "player")) or
		(unitTarget == "player" and UnitIsUnit(unitCaster, "player"));
	if not self.allow_self and isSelf then
		return ExiWoW:reportError("Action can not target self", suppressErrors);
	end

	-- Unit must be in a party or raid
	local inParty = UnitInRaid(unitCaster) or UnitInParty(unitCaster) or UnitInRaid(unitTarget) or UnitInRaid(unitTarget) or isSelf
	if not inParty and self.require_party then
		return ExiWoW:reportError("Target is not in your party or raid", suppressErrors);
	end

	-- Check dead
	if UnitIsDeadOrGhost(unitCaster) and not self.allow_caster_dead then
		return ExiWoW:reportError("You are dead.", suppressErrors);
	end
	if UnitIsDeadOrGhost(unitTarget) and not self.allow_targ_dead then
		return ExiWoW:reportError("Your target is dead you creep", suppressErrors);
	end



	-- Unit in range
	if self.max_distance ~= 0 and (not self:checkRange(unitTarget) or not self:checkRange(unitCaster)) then
		return ExiWoW:reportError("Too far away!", suppressErrors);
	end

	-- Check combat
	if not self.allow_targ_combat and UnitAffectingCombat(unitTarget) then
		return ExiWoW:reportError("Target is in combat", suppressErrors);
	end
	if not self.allow_targ_combat and UnitAffectingCombat(unitTarget) then
		return ExiWoW:reportError("You are in combat", suppressErrors);
	end




	-- Validations only when SENDING (these are limited to caster) --
	if unitCaster == "player" then

		-- Make sure we're not stunned
		local pl = ExiWoW.ME;
		if not HasFullControl() and not self.allow_stunned then
			return ExiWoW:reportError("Can't use actions right now", suppressErrors);
		end

		-- Stealth
		if not IsStealthed() and self.require_stealth then
			return ExiWoW:reportError("You must be in stealth to use this action!", suppressErrors);
		end

		-- Unit movement --
		if not self.allow_caster_moving and GetUnitSpeed(unitCaster) > 0 then
			return ExiWoW:reportError("Can't use while moving", suppressErrors);
		end
		if not self.allow_targ_moving and GetUnitSpeed(unitTarget) > 0 then
			return ExiWoW:reportError("Can't use on a moving target", suppressErrors);
		end

	-- Validate when RECEIVING --
	else
	end

	


	return true

end

function ExiWoW.Action:checkRange(target)
	for i,v in ipairs(self.max_distance) do
		if IsItemInRange(v, target) then
			return true;
		end
	end
	return false;
end


	-- TOOLTIP HANDLING --
function ExiWoW.Action:onTooltip(frame)

	ExiWoW.Timer:clear(ExiWoW.Action.tooltipTimer);
	if not not frame then

		-- Set timer for refreshing
		local th = self
		ExiWoW.Action.tooltipTimer = ExiWoW.Timer:set(function()
			th:drawTooltip()
		end, 0.25, math.huge);

		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		self:drawTooltip();

	else

		GameTooltip:Hide();

	end


end

	-- Returns range in yards based on the range consts --
function ExiWoW.Action:getRangeYards()
	return 40;
end

function ExiWoW.Action:drawTooltip()

	local v = self
	GameTooltip:ClearLines()
	GameTooltip:AddLine(v.name, 1, 1, 1)

	-- CD --
	local started, duration = v:getCooldown();
	local singles = {}

	if v.cast_time > 0 then
		table.insert(singles, ExiWoW:timeFormat(v.cast_time).." cast");
	else
		table.insert(singles, "Instant")
	end

	if not v.self_only and v.max_distance then
		if v.max_distance == ExiWoW.Action.MELEE_RANGE then
			table.insert(singles, "Melee Range");
		else
			table.insert(singles, tostring(v:getRangeYards()).." yd range");
		end
	end

	if v.cooldown > 0 then
		table.insert(singles, ExiWoW:timeFormat(v.cooldown).." cooldown");
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
		GameTooltip:AddLine("Cooldown remaining: "..tostring(ExiWoW:timeFormat(duration-(GetTime()-started))), 1, 1,1, 0.75);
	end


	GameTooltip:AddLine(v.description, nil, nil, nil, true)
	GameTooltip:Show()

end


	-- CASTBAR --
-- Shows castbar for this action, or can be used statically to turn off
function ExiWoW.Action:toggleCastBar(on)


	local sb = ExiWoW.Action.FRAME_CASTBAR;

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
function ExiWoW.Action:sendRPText(sender, target, suppressErrors)

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

function ExiWoW.Action:receiveRPText( sender, target, args)

	if args.text and args.sender then
		local ts = ExiWoW.Character:new(args.sender, sender);
		ExiWoW.RPText:print(ExiWoW.RPText:convert(args.text, ts, ExiWoW.ME))
	end
	
	-- Play receiving sound if not self cast
	if not UnitIsUnit(Ambiguate(sender, "ALL"), "player") and args.sound then 
		PlaySound(args.sound, "SFX");
	end

end




	-- STATIC --

-- INI --

function ExiWoW.Action:ini()

	ExiWoW.Action:libSort()
	ExiWoW.Menu:refreshSpellsPage()
	
	ExiWoW.Action.FRAME_CASTBAR = CreateFrame("StatusBar", "ExiWoWCastBar", UIParent, "CastingBarFrameTemplate");
	local sb = ExiWoW.Action.FRAME_CASTBAR;
	CastingBarFrame_OnLoad(sb, false, false, false);
	sb:SetSize(195,13);
	sb:SetPoint("CENTER", UIParent, "CENTER", 0, -200);

	--ExiWoW.Action.LIB[1]:toggleCastBar(true);

end

function ExiWoW.Action:libSort()
	table.sort(ExiWoW.Action.LIB, function(a,b)

		local aimportance = (a.favorite and 1 or 0)*2+(a.important and 1 or 0);
		local bimportance = (b.favorite and 1 or 0)*2+(b.important and 1 or 0);
	
		if aimportance > bimportance then return true end
		if aimportance < bimportance then return false end
		return a.name < b.name;
	
	end)	
end

-- Useful stuff for actions --
function ExiWoW.Action:handleExcitementCallback(target, success, data)
	-- Fail --
	if not success then return false end

	-- Output text --
	local text = "looks extremely aroused!";

	if data[1] <= 0 then text = "does not look aroused.";
	elseif data[1] < 0.25 then text = "looks a little aroused."
	elseif data[1] < 0.5 then text = "looks somewhat aroused."
	elseif data[1] < 0.75 then text = "looks aroused."
	elseif data[1] < 1 then text = "looks heavily aroused.";
	end

	ExiWoW:reportNotice(Ambiguate(UnitName(target), "all").." "..text);
end

function ExiWoW.Action:returnExcitement()
	return true, {ExiWoW.ME.excitement};
end


-- Get from library by id
function ExiWoW.Action:get(id)

	for i, act in pairs(ExiWoW.Action.LIB) do
		if act.id == id then return act end
	end
	return false

end

-- Send an action
function ExiWoW.Action:useOnTarget(id, target, castFinish)

	if ExiWoW.Action.CASTING_SPELL then
		return ExiWoW:reportError("You are already using an action!");
	end

	-- Find the action
	local action = ExiWoW.Action:get(id);
	if not action then
		return ExiWoW:reportError("Action not found: "..id);
	end

	-- Self cast actions don't need to send a message
	if action.self_only or not UnitExists("target") then
		target = "player"
	end

	

	-- Validate conditions
	if not action:validate("player", target, ignoreErrors) then return false end

	-- Set cooldowns etc

	-- Use special function, if it returns false, then prevent default behavior
	local args = {}
	local callback = nil
	if type(action.fn_send) == "function" then
		args, callback = action:fn_send("player", target, suppressErrors);
		if args == false then return false end -- Return false from your custom function to prevent a send
	end

	-- Default send logic

	ExiWoW.CAST_TARGET = ExiWoW.TARGET
	if action.cast_time <= 0 or castFinish then 
		-- Finish cast
		action:setCooldown();
		-- Send to target
		local first,last = UnitName(target)
		if last then first = first.."-"..last end
		ExiWoW:sendAction(Ambiguate(first, "all"), action.id, args, callback)
	else 
		-- Start cast
		ExiWoW.Action:beginSpellCast(action, target);
	end

end


-- Receive an action
function ExiWoW.Action:receive(id, sender, args, allowErrors)

	local action = ExiWoW.Action:get(id);
	if not action then return false end			-- Received Action not found

	-- Received action is invalid
	if not action:validate(sender, "player", not allowErrors) then 
		return false 
	end

	-- Returns (bool)success, (var)data
	return action:fn_receive(sender, "player", args);

end

-- Tools for conditions
function ExiWoW.Action:computeDistance(x1,y1,z1,x2,y2,z2, instance1, instance2)
	if instance1 ~= instance2 then return end
	return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2-z1) ^ 2) ^ 0.5
end

function ExiWoW.Action:beginSpellCast(action, target)

	ExiWoW.Action:endSpellCast(false);
	ExiWoW.Action.CASTING_SPELL = action;
	ExiWoW.Action.CASTING_TARGET = Ambiguate( UnitName(target), "all" );
	ExiWoW.Action.CASTING_TIMER = ExiWoW.Timer:set(function()
		ExiWoW.Action:endSpellCast(true);
	end, action.cast_time);

	-- Cast bar
	action:toggleCastBar(true);

	local interrupt = function()
		PlaySound(10846, "SFX");
		ExiWoW:reportError("Interrupted");
		ExiWoW.Action:endSpellCast(false);
	end

	if action.cast_sound_start then
		PlaySound(action.cast_sound_start, "SFX")
	end

	-- Audio loop
	if action.cast_sound_loop then
		local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
		ExiWoW.Action.CASTING_SOUND_LOOP = handle;
		ExiWoW.Action.CASTING_SOUND_FINISH_EVENT = ExiWoW.Character:bind("SOUNDKIT_FINISHED", function(data)
			if data[1] == ExiWoW.Action.CASTING_SOUND_LOOP then 
				local _, handle = PlaySound(action.cast_sound_loop, "SFX", false, true);
				ExiWoW.Action.CASTING_SOUND_LOOP = handle;
			end
		end)
	end

	if not action.allow_caster_moving then
		ExiWoW.Action.CASTING_MOVEMENT_BINDING = ExiWoW.Character:bind("PLAYER_STARTED_MOVING", interrupt)
	end

	ExiWoW.Action.CASTING_SPELL_BINDING = ExiWoW.Character:bind("UNIT_SPELLCAST_START", function(data)
		if UnitIsUnit(data[1], "PLAYER") then interrupt() end
	end)
	ExiWoW.Action.FINISHING_SPELL_BINDING = ExiWoW.Character:bind("UNIT_SPELLCAST_SENT", function(data)
		if UnitIsUnit(data[1], "PLAYER") then interrupt() end
	end)

	
end

function ExiWoW.Action:endSpellCast(success)

	-- Make sure we are actually casting --
	if not ExiWoW.Action.CASTING_SPELL then return end

	
	ExiWoW.Character:unbind(ExiWoW.Action.CASTING_MOVEMENT_BINDING);
	ExiWoW.Character:unbind(ExiWoW.Action.CASTING_SPELL_BINDING);
	ExiWoW.Character:unbind(ExiWoW.Action.FINISHING_SPELL_BINDING);
	ExiWoW.Character:unbind(ExiWoW.Action.CASTING_SOUND_FINISH_EVENT);

	-- Let it play the fade out animation
	if not success then
		ExiWoW.Action:toggleCastBar(false);
	end

	if ExiWoW.Action.CASTING_SOUND_LOOP then
		StopSound(ExiWoW.Action.CASTING_SOUND_LOOP);
		ExiWoW.Action.CASTING_SOUND_LOOP = nil
	end

	if success and self.cast_sound_success then
		PlaySound(self.cast_sound_success, "SFX")
	end

	ExiWoW.Timer:clear(ExiWoW.Action.CASTING_TIMER);
	ExiWoW.Timer:clear(ExiWoW.Action.CASTING_INTERVAL);
	
	local id = ExiWoW.Action.CASTING_SPELL.id;
	ExiWoW.Action.CASTING_SPELL = nil;
	if success then
		ExiWoW.Action:useOnTarget(id, ExiWoW.Action.CASTING_TARGET, true);
	end

end


