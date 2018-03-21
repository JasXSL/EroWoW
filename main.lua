local appName, internal = ...
--[[
	/console scriptErrors 1

	TODO:
	- Add in more abilities & Spell triggers
	- Add pagination if you manage to fill up the whole first page
	- Write VH Addon
	- Alt click = create macro
	 
]]

ExiWoW = {};
ExiWoW.APP_NAME = "ExiWoW"
ExiWoW.R = nil					-- Root extension

-- Targets
ExiWoW.ME = nil					-- My character
ExiWoW.TARGET = nil				-- Target character, do not use in actions
ExiWoW.CAST_TARGET = nil		-- Cast target character, use this in actions

ExiWoW.Frames = {}
ExiWoW.Frames.targetHasExiWoWFrame = nil;	-- Gender display
ExiWoW.Frames.portraitExcitementBar = false; 	-- Excitement bar frame thing
ExiWoW.Frames.PORTRAIT_FRAME_WIDTH = 19;
ExiWoW.Frames.PORTRAIT_FRAME_HEIGHT = 19;
ExiWoW.Frames.PORTRAIT_PADDING = 7;

-- GlobalStorage defaults
local gDefaults = {
	swing_text_freq = 0.15,		-- Percent chance of a swing triggering a special text. Crits are 4x this value
	spell_text_freq = 1,		-- Percent chance of spell damage triggering a special text
	takehit_rp_rate = 6,			-- RP texts from being hit by spells and abilities can only trigger this often
	enable_in_dungeons = false,
	enable_public = false,
};
-- LocalStorage defaults
local lDefaults = {
	penis_size = false,
	vagina_size = false,
	breast_size = false,
	butt_size = 2,
	masochism = 0.25,			-- Value between 0 and 1
	abilities = {},
	excitement = 0
};

-- Constants
ExiWoW.GENITALS_PENIS = 1;
ExiWoW.GENITALS_VAGINA = 2;
ExiWoW.GENITALS_BREASTS = 4;

-- Register main frame
ExiWoW.MAIN = CreateFrame("Frame")
ExiWoW.MAIN:RegisterEvent("ADDON_LOADED");
ExiWoW.MAIN:RegisterEvent("PLAYER_LOGOUT");
ExiWoW.MAIN:RegisterEvent("CHAT_MSG_ADDON")
ExiWoW.MAIN:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	ExiWoW:onEvent(self, event, prefix, message, channel, sender)
end)

-- Initializer --
function ExiWoW:ini()

	--ExiWoW.Menu.ini();
	

	-- Add character
	ExiWoW.ME = ExiWoW.Character:new();

	ExiWoW.ME.penis_size = ExiWoWLocalStorage.penis_size;
	ExiWoW.ME.vagina_size = ExiWoWLocalStorage.vagina_size;
	ExiWoW.ME.breast_size = ExiWoWLocalStorage.breast_size;
	ExiWoW.ME.butt_size = ExiWoWLocalStorage.butt_size;
	ExiWoW.ME.masochism = ExiWoWLocalStorage.masochism;
	ExiWoW.ME.excitement = ExiWoWLocalStorage.excitement;
	

	ExiWoW:buildUnitFrames();
	

	-- Initialize timer and character
	
	ExiWoW.Timer.ini();
	ExiWoW.Character:ini()
	ExiWoW.Menu:ini();
	ExiWoW.ME:onCapChange()

	ExiWoW.R = ExiWoW.Extension:import({id="ROOT"}, true);	-- Build the main extension for assets
	
	-- Action slash command
	SLASH_EWACT1 = '/ewact'
	function SlashCmdList.EWACT(msg, editbox) ExiWoW.Action:useOnTarget(msg, "target") end
	SLASH_EWRESET1 = '/ewreset'
	function SlashCmdList.EWRESET(msg, editbox) ExiWoW:resetSettings() end

	ExiWoW.Action:ini()

	-- Build libraries
	ExiWoW.RPText:buildLibrary()
	ExiWoW.Action:buildLibrary()
	ExiWoW.SpellBinding:buildLibrary()
	ExiWoW.Extension:index() -- Update the built libraries

	-- Bind listener
	RegisterAddonMessagePrefix(ExiWoW.APP_NAME.."_act")		-- Sends an action	 {cb:cbToken, id:action_id, data:(var)data}
	RegisterAddonMessagePrefix(ExiWoW.APP_NAME.."_cb")		-- Receive a callback {cb:cbToken, success:(bool)success, data:(var)data}
	

	print("ExiWoW online!");
end

-- Checks dungeon/party hardlimit
internal.checkHardlimits = function(sender, receiver, suppressErrors)

	-- Public toggle
	if not ExiWoWGlobalStorage.enable_public then
		local isSelf =
			(sender == "player" and UnitIsUnit(sender, "player")) or
			(receiver == "player" and UnitIsUnit(receiver, "player"));

		if sender and not UnitInRaid(sender) and not UnitInParty(sender) and not isSelf then
			return ExiWoW:reportError("Sender is not in your party", suppressErrors);
		end
		if receiver and not UnitInRaid(receiver) and not UnitInParty(receiver) and not isSelf then
			return ExiWoW:reportError("Target is not in your party", suppressErrors);
		end
	end

	if not ExiWoWGlobalStorage.enable_in_dungeons then

		if IsInInstance() then
			return ExiWoW:reportError("Can't use in an instance.", suppressErrors)
		end

	end
	return true;

end


-- Reset settings
function ExiWoW:resetSettings()
	local s = ExiWoWGlobalStorage;
	for k,v in pairs(gDefaults) do s[k] = v end
	s = ExiWoWLocalStorage;
	for k,v in pairs(lDefaults) do s[k] = v end
	print("Settings reset")
end


	-- Primary event handler --
	-- Handles addon commands and loading --
function ExiWoW:onEvent(self, event, prefix, message, channel, sender)


	if event == "ADDON_LOADED" and prefix == ExiWoW.APP_NAME then
		
		if not ExiWoWLocalStorage then ExiWoWLocalStorage = {} end
		if not ExiWoWGlobalStorage then ExiWoWGlobalStorage = {} end
		
		-- Loading
		for k,v in pairs(gDefaults) do
			if ExiWoWGlobalStorage[k] == nil then ExiWoWGlobalStorage[k] = v end
		end
		for k,v in pairs(lDefaults) do
			if ExiWoWLocalStorage[k] == nil then ExiWoWLocalStorage[k] = v end
		end
		
		-- From here we can initialize
		ExiWoW:ini();

		

		-- Load in abilities
		for k,v in pairs(ExiWoWLocalStorage.abilities) do
			local abil = ExiWoW.Action:get(v.id)
			if abil then abil:import(v) end
		end

		-- Redraw with cooldowns
		ExiWoW.Action:libSort();
		ExiWoW.Menu:refreshSpellsPage();

	end

	if event == "PLAYER_LOGOUT" then

		-- Saving
		local l = ExiWoWLocalStorage;

		l.excitement = ExiWoW.ME.excitement;

		l.abilities = {};
		for k,v in pairs(ExiWoW.Action.LIB) do
			if not v.hidden then
				table.insert( l.abilities, v:export() )
			end
		end
		
	end

	-- Action received
	if event == "CHAT_MSG_ADDON" then 
		
		if prefix == ExiWoW.APP_NAME.."_act" then

			local sname = Ambiguate(sender, "all") 			-- Sender name for use in units
			local data = ExiWoW.json.decode(message); 		-- JSON decode message
			local cb = data.cb								-- Callback if exists
			local aID = data.id								-- Action ID
			local success, data = ExiWoW.Action:receive(aID, sender, data.data);
			if cb then
				ExiWoW:sendCallback(cb, sname, success, data);
			end

		end

		if prefix == ExiWoW.APP_NAME.."_cb" then

			local sname = Ambiguate(sender, "all")
			local data = ExiWoW.json.decode(message);
			local cb = data.cb
			ExiWoW.Callbacks:trigger(cb, data.success, data.data, sender);

		end

	end
end


	-- Communications --
function ExiWoW:sendAction(unit, actionID, data, callback)

	local out = {
		id = actionID,
		data = data
	};

	if type(callback) == "function" then
		out.cb = ExiWoW.Callbacks:add(callback);
	end
	SendAddonMessage(ExiWoW.APP_NAME.."_act", ExiWoW.json.encode(out), "WHISPER", unit)
end

function ExiWoW:sendCallback(token, unit, success, data)

	local out = {
		cb = token,
		success = success,
		data = data
	};

	SendAddonMessage(ExiWoW.APP_NAME.."_cb", ExiWoW.json.encode(out), "WHISPER", unit)

end


	-- Tools --
-- Returns false so you can use it as a return value
function ExiWoW:reportError(message, ignore)
	if ignore then return false end
	UIErrorsFrame:AddMessage(message, 1.0, 0.0, 0.0, 53, 6);
	return false;
end

function ExiWoW:reportNotice(message)
	UIErrorsFrame:AddMessage(message, 0.5, 1.0, 0.5, 53, 6);
	return true;
end

-- Returns an RP name, removing realm name if needed and replacing self with you
function ExiWoW:unitRpName(unit)
	unit = Ambiguate(unit, "all")
	if UnitIsUnit(unit, "player") then return "YOU" end
	return unit;
end


function ExiWoW:timeFormat(seconds)

	if seconds > 3600 then return tostring(math.ceil(seconds/3600)).." Hr" end
	if seconds > 60 then return tostring(math.ceil(seconds/60)) .. " Min" end
	return tostring(math.ceil(seconds)).." Sec"
end

function ExiWoW:Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function ExiWoW:itemSlotToname(slot)
	local all_slots = {}
	all_slots[1] = "head armor"
	all_slots[3] = "shoulder armor"
	all_slots[4] = "shirt"
	all_slots[5] = "chestpiece"
	all_slots[6] = "belt"
	all_slots[7] = "pants"
	all_slots[8] = "boots"
	all_slots[10] = "gloves"
	all_slots[15] = "cloak"
	all_slots[19] = "tabard"
	return all_slots[slot]
end


-- Unit Frames -
function ExiWoW:buildUnitFrames()

	local frameWidth = ExiWoW.Frames.PORTRAIT_FRAME_WIDTH;
	local frameHeight = ExiWoW.Frames.PORTRAIT_FRAME_HEIGHT;
	local padding = ExiWoW.Frames.PORTRAIT_PADDING;

	-- Icon
	local bg = CreateFrame("Button",nil,PlayerFrame); --frameType, frameName, frameParent, frameTemplate   
	bg:SetMovable(true)
	bg:RegisterForDrag("LeftButton")
	bg:SetScript("OnDragStart", bg.StartMoving)
	bg:SetScript("OnDragStop", bg.StopMovingOrSizing)
	
	

	-- Bind events
	bg:RegisterForClicks("AnyUp");
	bg:SetScript("OnClick", function (self, button, down)
		ExiWoW.Menu:toggle();
	end);

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
	--t:SetHeight(frameHeight*max(self.excitement, 0.00001)); -- Setting to 0 doesn't work
	t:SetRotation(-math.pi/2);
	t:SetVertexColor(1,0.75,1)
	t:AddMaskTexture(mask);
	ExiWoW.Frames.portraitExcitementBar = t;
	ExiWoW.ME:updateExcitementDisplay();

	-- Border

	local ol = CreateFrame("Frame", nil, bar);
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
	t = ol:CreateTexture(nil, "OVERLAY");
	t:SetTexture("Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight");
	t:SetVertexColor(1,1,0.7);
	t:SetPoint("CENTER", 0,0);
	t:SetBlendMode("ADD");
	t:SetSize(frameWidth+15,frameHeight+15);
	t:SetAlpha(0);
	bg.highlight = t;
	bg:SetScript("OnEnter", function(self) self.highlight:SetAlpha(1) end)
	bg:SetScript("OnLeave", function(self) self.highlight:SetAlpha(0) end)
	

	-- BUILD THE TARGET PORTRAIT --
	bg = CreateFrame("Button",nil,TargetFrame); --frameType, frameName, frameParent, frameTemplate   
	bg:SetMovable(true)
	bg:EnableMouse(true);
	bg:RegisterForDrag("LeftButton")
	bg:SetScript("OnDragStart", bg.StartMoving)
	bg:SetScript("OnDragStop", bg.StopMovingOrSizing)

	bg:SetFrameStrata("HIGH");
	bg:SetSize(20,20);
	bg:SetPoint("TOPRIGHT",-88,-10);
	t = bg:CreateTexture(nil, "BACKGROUND");
	t:SetTexture("Interface/AddOns/ExiWoW/media/icons/genders.blp");
	t:SetVertexColor(1,0.5,1);
	t:SetTexCoord(0,0.25,0,1);
	t:SetAlpha(0.75);
	t:SetAllPoints(bg);
	bg.genderTexture = t;
	ExiWoW.Frames.targetHasExiWoWFrame = bg;
	bg:Hide();

	--[[
	t = ol:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
	t:SetAllPoints(ol)
	t:SetJustifyH("CENTER")
	t:SetJustifyV("MIDDLE")
	t:SetTextColor(0.75,0.5,0.75,1)
	t:SetText(floor(ExiWoW.ME.excitement*100))
]]
end
