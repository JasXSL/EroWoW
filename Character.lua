-- Contains info about a character, 
EroWoW.Character = {}
EroWoW.Character.__index = EroWoW.Character;
EroWoW.Character.evtFrame = CreateFrame("Frame");
EroWoW.Character.eventBindings = {};		-- {id:(int)id, evt:(str)evt, fn:(func)function, numTriggers:(int)numTriggers=inf}
EroWoW.Character.eventBindingIndex = 0;	
EroWoW.Character.targetHasEroWoWFrame = nil;	-- Gender display
EroWoW.Character.portraitArousalBar = false; 	-- Arousal bar frame thing

-- Consts
EroWoW.Character.AROUSAL_FADE_PER_SEC = 0.05;
EroWoW.Character.AROUSAL_MAX = 1.25;				-- You can overshoot max arousal and have to wait longer
EroWoW.Character.AROUSAL_FADE_IDLE = 0.001;

EroWoW.Character.PORTRAIT_FRAME_WIDTH = 19;
EroWoW.Character.PORTRAIT_FRAME_HEIGHT = 19;
EroWoW.Character.PORTRAIT_PADDING = 7;


-- Static
function EroWoW.Character:ini()

	EroWoW.Character.evtFrame:SetScript("OnEvent", EroWoW.Character.onEvent)
	EroWoW.Character.evtFrame:RegisterEvent("PLAYER_STARTED_MOVING")
	EroWoW.Character.evtFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
	EroWoW.Character.evtFrame:RegisterEvent("UNIT_SPELLCAST_START");
	EroWoW.Character.evtFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
	EroWoW.Character.evtFrame:RegisterEvent("SOUNDKIT_FINISHED");
	EroWoW.Character.evtFrame:RegisterEvent("COMBAT_LOG_EVENT")
	EroWoW.Character.evtFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	
		
	-- Main timer, ticking once per second
	EroWoW.Timer:set(function()
		
		-- Owner meditation
		local me = EroWoW.ME;
		local fade = 0;
		if me.meditating then
			fade = EroWoW.Character.AROUSAL_FADE_PER_SEC;
		elseif not UnitAffectingCombat("player") then
			fade = EroWoW.Character.AROUSAL_FADE_IDLE;
		end
		me:addArousal(-fade);


	end, 1, math.huge)

end

function EroWoW.Character:onEvent(event, ...)

	local arguments = {...}

	for k,v in pairs(EroWoW.Character.eventBindings) do

		if v.evt == event then

			local trigs = v.numTriggers -1;

			-- Remove if out of triggers
			if trigs < 1 then
				EroWoW.Character.eventBindings[k] = nil;
			else
				EroWoW.Character.eventBindings[k].numTriggers = trigs;
			end

			if type(v.fn) == "function" then
				v:fn(arguments);
			end

		end
	end

	if event == "PLAYER_TARGET_CHANGED" then
		EroWoW.Character.targetHasEroWoWFrame:Hide();
		if UnitExists("target") then
			-- Query for the addon
			EroWoW.Action:useOnTarget("A", "target", true);
		end
	end
	
	-- Handle combat log
	if event == "COMBAT_LOG_EVENT" then
		local timestamp, combatEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags =  ...; -- Those arguments appear for all combat event variants.
		local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");
		if eventSuffix == "DAMAGE" then

			local crit = ""
			if arguments[18] then crit = "_CRIT" end


			local damage = 0
			if eventPrefix == "SPELL" or eventPrefix == "SPELL_PERIODIC" then

				-- Todo: Add spell triggers
				damage = arguments[15]
				print("Spell was", arguments[13])


			elseif eventPrefix == "SWING" then
				damage = arguments[12]

				-- See if a viable unit exists
				local u = false
				if sourceGUID == UnitGUID("target") then u = "target"
				elseif sourceGUID == UnitGUID("focus") then u = "focus"
				elseif sourceGUID == UnitGUID("mouseover") then u = "mouseover"
				end

				local chance = EroWoW.GS.swing_text_freq;
				local rand = math.random()
				if rand < chance and u and not UnitIsPlayer(u) then

					local npc = EroWoW.Character:new({}, sourceName);
					npc.type = UnitCreatureType(u);
					--npc.race = UnitRace(u);
					npc.class = UnitClass(u);

					local sex = UnitSex(u);
					if sex == 2 then npc.penis_size = 2
					elseif sex == 3 then 
						npc.breast_size = 2;
						npc.vagina_size = 0;
					end

					local rp = EroWoW.RPText:get(eventPrefix..crit, npc, EroWoW.ME)
					if rp then 
						EroWoW.RPText:print(EroWoW.RPText:convert(rp.text_receiver, npc, EroWoW.ME))
						if rp.sound then
							PlaySound(rp.sound, "SFX");
						end
						if type(rp.fn) == "function" then
							rp:fn();
						end
					end

				end
			end

			if damage <= 0 then return end
			local percentage = damage/UnitHealthMax("player");
			EroWoW.ME:addArousal(percentage*0.1, false, true);
			

	   end
	end
end

function EroWoW.Character:bind(evt, fn, numTriggers)

	EroWoW.Character.eventBindingIndex = EroWoW.Character.eventBindingIndex+1;
	table.insert(EroWoW.Character.eventBindings, {
		id = EroWoW.Character.eventBindingIndex,
		evt = evt,
		fn = fn,
		numTriggers = numTriggers or math.huge
	});

	return EroWoW.Character.eventBindingIndex;

end

function EroWoW.Character:unbind(id)

	for k,v in pairs(EroWoW.Character.eventBindings) do
		if v.id == id then
			EroWoW.Character.eventBindings[k] = nil;
			return
		end
	end

end






-- Class declaration
function EroWoW.Character:new(settings, name)
	local self = {}
	setmetatable(self, EroWoW.Character); 
	if type(settings) ~= "table" then
		settings = {}
	end
	
	local getVar = function(v, def)
		if v == nil then return def end
		return v
	end

	-- Visuals
	self.capFlashTimer = 0			-- Timer event of arousal cap
	self.capFlashPow = 0
	self.portraitBorder = false;
	self.portraitResting = false;
	self.restingTimer = 0;
	self.restingPow = 0;

	-- Stats & Conf
	self.name = name;					-- Nil for player self
	self.arousal = 0;
	self.hasControl = true;
	self.meditating = false;			-- Losing arousal 
	self.masochism = 0.25;
	
	-- These are automatically set on export if full is set.
	-- They still need to be fetched from settings though when received by a unit for an RP text
	self.class = settings.class or UnitClass("player");
	self.race = settings.race or UnitRace("player");

	-- These are not sent on export, but can be used locally for NPC events
	self.type = "player";				-- Can be overridden like humanoid etc. 
	
	-- 

	-- Importable properties
	-- Use EroWoW.Character:getnSize
	-- If all these are false, size will be set to 2 for penis/breasts, 0 for vagina. Base on character sex in WoW 
	self.penis_size = getVar(settings.penis_size, false);				-- False or range between 0 and 4
	self.vagina_size = getVar(settings.vagina_size, false);				-- False or 0
	self.breast_size = getVar(settings.breast_size, false);				-- False or range between 0 and 4
	self.butt_size = getVar(settings.butt_size, 2);						-- Always a number
	
	-- Build the portrait
	self:buildCharacterPortrait();

	-- Feature tests
	--self:addArousal(1.1);

	return self
end

-- Exporting
function EroWoW.Character:export(full)
	local out = {
		arousal = self.arousal,
		penis_size = self.penis_size,
		vagina_size = self.vagina_size,
		breast_size = self.breast_size,
		butt_size = self.butt_size,
	};
	-- Should only be used for "player"
	if full then
		out.class = UnitClass("player");
		out.race = UnitRace("player");
	end
	return out;
end

-- Gets a clamped arousal value
function EroWoW.Character:getArousalPerc()
	return max(min(self.arousal,1),0);
end

-- Raised when you max or drop off max arousal --
function EroWoW.Character:onCapChange()
	local maxed = self.arousal >= 1

	EroWoW.Timer:clear(self.capFlashTimer);
	local se = self
	if maxed then
		self.capFlashTimer = EroWoW.Timer:set(function()
			se.capFlashPow = se.capFlashPow+0.25;
			if se.capFlashPow >= 2 then se.capFlashPow = 0 end
			local green = -0.5 * (math.cos(math.pi * se.capFlashPow) - 1)
			se.portraitBorder:SetVertexColor(1,0.5+green*0.5,1);
		end, 0.05, math.huge);
	else
		se.portraitBorder:SetVertexColor(1,1,1);
	end

end

function EroWoW.Character:addArousal(amount, set, multiplyMasochism)

	if multiplyMasochism then amount = amount*self.masochism end

	local pre = self.arousal >= 1
	if not set then
		self.arousal = self.arousal+tonumber(amount);
	else
		self.arousal = tonumber(amount);
	end

	self.arousal =max(min(self.arousal, EroWoW.Character.AROUSAL_MAX), 0);
	self:updateArousalDisplay();

	if (self.arousal >= 1) ~= pre then
		self:onCapChange()
	end

end

function EroWoW.Character:toggleResting(on)

	EroWoW.Timer:clear(self.restingTimer);
	local se = self
	if on then
		se.restingPow = 0
		self.restingTimer = EroWoW.Timer:set(function()
			se.restingPow = se.restingPow+0.1;
			local opacity = -0.5 * (math.cos(math.pi * se.restingPow) - 1)
			se.portraitResting:SetAlpha(0.5+opacity*0.5);
		end, 0.05, math.huge);
	else
		self.portraitResting:SetAlpha(0);
	end

end

function EroWoW.Character:updateArousalDisplay()

	EroWoW.Character.portraitArousalBar:SetHeight(self.PORTRAIT_FRAME_HEIGHT*max(self:getArousalPerc(), 0.00001));

end

function EroWoW.Character:buildCharacterPortrait()

	local frameWidth = EroWoW.Character.PORTRAIT_FRAME_WIDTH;
	local frameHeight = EroWoW.Character.PORTRAIT_FRAME_HEIGHT;
	local padding = EroWoW.Character.PORTRAIT_PADDING;

	-- Icon
	local bg = CreateFrame("Button",nil,PlayerFrame); --frameType, frameName, frameParent, frameTemplate   
	bg:SetFrameStrata("HIGH");
	bg:SetSize(frameWidth,frameHeight);
	bg:SetPoint("TOPLEFT",80,-5);

	local mask = bg:CreateMaskTexture()
	mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetPoint("CENTER")

	-- Background
	local t = bg:CreateTexture(nil, "BACKGROUND");
	t:SetColorTexture(0,0,0,0.5);
	t:AddMaskTexture(mask)
	t:SetAllPoints(bg);


	-- Status bar
	local bar = CreateFrame("Frame", nil, bg);
	bar:SetPoint("TOPLEFT")
	bar:SetSize(frameWidth,frameHeight)

	t = bar:CreateTexture(nil, "BORDER");
	t:SetPoint("BOTTOM");
	t:SetSize(frameWidth,frameHeight);
	t:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
	--t:SetHeight(frameHeight*max(self.arousal, 0.00001)); -- Setting to 0 doesn't work
	t:SetRotation(-math.pi/2);
	t:SetVertexColor(1,0.75,1)
	t:AddMaskTexture(mask);
	EroWoW.Character.portraitArousalBar = t;
	self:updateArousalDisplay();

	-- Border

	local ol = CreateFrame("Button", nil, bar);
	ol:SetPoint("TOPLEFT", -padding+1, padding-1)
	ol:SetSize(frameWidth+padding*2,frameHeight+padding*2)

	-- Inner
	t = ol:CreateTexture(nil, "BACKGROUND");
	t:SetTexture("Interface/common/portrait-ring-withbg-highlight");
	t:SetPoint("CENTER", 2);
	t:SetVertexColor(0.75,1,0.75);
	t:SetTexCoord(0.3,0.7,0.3,0.7);
	t:SetAlpha(0);
	t:SetSize(frameWidth,frameHeight);
	self.portraitResting = t;

	-- Outer
	
	t = ol:CreateTexture(nil, "ARTWORK");
	t:SetTexture("Interface\\MINIMAP\\MiniMap-TrackingBorder");
	t:SetTexCoord(0.01,0.61,0,0.6);
	t:SetPoint("CENTER", 1,4);
	t:SetAllPoints(ol);
	self.portraitBorder = t;
	
	-- Overlay
	t = ol:CreateTexture(nil, "HIGHLIGHT");
	t:SetTexture("Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight");
	t:SetVertexColor(1,1,0.7);
	t:SetPoint("CENTER", 0,0);
	t:SetBlendMode("ADD");
	t:SetSize(frameWidth+15,frameHeight+15);

	-- Bind events
	ol:RegisterForClicks("AnyUp");
	ol:SetScript("OnClick", function (self, button, down)
		EroWoW.Menu:toggle();
	end);
	

	-- BUILD THE TARGET PORTRAIT --
	bg = CreateFrame("Button",nil,TargetFrame); --frameType, frameName, frameParent, frameTemplate   
	bg:SetFrameStrata("HIGH");
	bg:SetSize(20,20);
	bg:SetPoint("TOPRIGHT",-88,-10);
	t = bg:CreateTexture(nil, "BACKGROUND");
	t:SetTexture("Interface/AddOns/EroWoW/media/icons/genders.blp");
	t:SetVertexColor(1,0.5,1);
	t:SetTexCoord(0,0.25,0,1);
	t:SetAlpha(0.75);
	t:SetAllPoints(bg);
	bg.genderTexture = t;
	EroWoW.Character.targetHasEroWoWFrame = bg;
	bg:Hide();

	--[[
	t = ol:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	t:SetAllPoints(ol)
	t:SetJustifyH("CENTER")
	t:SetJustifyV("MIDDLE")
	t:SetTextColor(0.75,0.5,0.75,1)
	t:SetText(floor(self.arousal*100))
	]]

end

function EroWoW.Character:isGenderless()
	if self.penis_size == false and self.vagina_size == false and self.breast_size == false and self.type == "player" then
		return true
	end
	return false; 
end

function EroWoW.Character:getPenisSize()
	
	if self:isGenderless() then
		if UnitSex("player") == 2 
		then return 2
		else return false end
	end

	return self.penis_size

end

function EroWoW.Character:getBreastSize()
	
	if self:isGenderless() ~= "number" then
		if UnitSex("player") == 3
		then return 2
		else return false end
	end

	return self.breast_size

end

function EroWoW.Character:getVaginaSize()
	
	if self:isGenderless() ~= "number" then
		if UnitSex("player") == 3
		then return 0
		else return false end
	end

	return self.vagina_size

end

function EroWoW.Character:getButtSize()
	
	if type(self.butt_size) ~= "number" then
		return 2
	end

	return self.butt_size

end

-- Returns an Ambiguate name
function EroWoW.Character:getName()
	if self.name == nil then
		return Ambiguate(UnitName("player"), "all") 
	end
	return Ambiguate(self.name, "all");
end

function EroWoW.Character:isMale()
	return self:getPenisSize() ~= false and self:getBreastSize() == false and self:getVaginaSize() == false
end

function EroWoW.Character:isFemale()
	return self:getPenisSize() == false and self:getBreastSize() ~= false and self:getVaginaSize() ~= false
end

