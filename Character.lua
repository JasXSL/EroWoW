-- Contains info about a character, 
EroWoW.Character = {}
EroWoW.Character.__index = EroWoW.Character;
EroWoW.Character.evtFrame = CreateFrame("Frame");
EroWoW.Character.eventBindings = {};		-- {id:(int)id, evt:(str)evt, fn:(func)function, numTriggers:(int)numTriggers=inf}
EroWoW.Character.eventBindingIndex = 0;	
EroWoW.Character.targetHasEroWoWFrame = nil;

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
		if UnitName("target") then
			-- Query for the addon
			EroWoW.Action:useOnTarget("A", "target", true);
		end
	end
	
	-- Handle combat log
	if event == "COMBAT_LOG_EVENT" then
		local timestamp, combatEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags =  ...; -- Those arguments appear for all combat event variants.
		local eventPrefix, eventSuffix = combatEvent:match("^(.-)_?([^_]*)$");
		if eventSuffix == "DAMAGE" then

			
			local damage = 0
			if eventPrefix == "SPELL" then
				damage = arguments[15]
			elseif eventPrefix == "SWING" then
				damage = arguments[12]
			end

			if damage <= 0 then return end
			local percentage = damage/UnitHealthMax("player");
			EroWoW.ME:addArousal(percentage*EroWoW.ME.masochism);
			

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
function EroWoW.Character:new(unitid, settings)
	local self = {}
	setmetatable(self, EroWoW.Character); 
	
	-- Visuals
	self.portraitArousalBar = false; -- Arousal bar frame thing
	self.capFlashTimer = 0			-- Timer event of arousal cap
	self.capFlashPow = 0
	self.portraitBorder = false;
	self.portraitResting = false;
	self.restingTimer = 0;
	self.restingPow = 0;

	-- Stats & Conf
	self.unitID = unitid;
	self.arousal = 0;
	self.hasControl = true;
	self.meditating = false;			-- Losing arousal 
	self.masochism = 0.25;


	
	-- Build the portrait
	self:buildCharacterPortrait();

	-- Feature tests
	self:addArousal(1.1);

	return self
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

function EroWoW.Character:addArousal(amount, set)

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

	self.portraitArousalBar:SetHeight(self.PORTRAIT_FRAME_HEIGHT*max(self:getArousalPerc(), 0.00001));

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
	self.portraitArousalBar = t;
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
	bg:SetSize(16,16);
	bg:SetPoint("TOPRIGHT",-88,-10);
	t = bg:CreateTexture(nil, "BACKGROUND");
	t:SetTexture("Interface/AddOns/EroWoW/media/icons/heart.blp");
	t:SetVertexColor(1,0.5,1);
	t:SetAlpha(0.75);
	t:SetAllPoints(bg);
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



