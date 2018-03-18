--[[
	/console scriptErrors 1

	TODO:
	- Genital settings
	- Is there a way to measure height in WoW?

	- Add settings toggles
		- Masochism: Translate 1% of damage taken into n% arousal (between 1-5)
		- Genital sliders and checkboxes
	- Add in more abilities
	- Add pagination if you manage to fill up the whole first page
	- Add global settings
		- Use VH Connector
	- Add VH connector
	- Custom text import packages via JSON import
	- Common spell on player tracker (like root tickle etc)
	- Alt click = create macro
	 
	 
]]

EroWoW = {};
EroWoW.APP_NAME = "EroWoW"
EroWoW.R = nil					-- Root extension

-- Targets
EroWoW.ME = nil					-- My character
EroWoW.TARGET = nil				-- Target character, do not use in actions
EroWoW.CAST_TARGET = nil		-- Cast target character, use this in actions


-- GlobalStorage defaults
local gDefaults = {
	vh = true,
	swing_text_freq = 0.15,		-- Percent chance of a swing triggering a special text
	spell_text_freq = 0.3,		-- Percent chance of spell damage triggering a special text
};
-- LocalStorage defaults
local lDefaults = {
	penis_size = false,
	vagina_size = false,
	breast_size = false,
	masochism = 0.25,			-- Value between 0 and 1
	abilities = {}
};

-- Constants
EroWoW.GENITALS_PENIS = 1;
EroWoW.GENITALS_VAGINA = 2;
EroWoW.GENITALS_BREASTS = 4;

-- Register main frame
EroWoW.MAIN = CreateFrame("Frame")
EroWoW.MAIN:RegisterEvent("ADDON_LOADED");
EroWoW.MAIN:RegisterEvent("PLAYER_LOGOUT");
EroWoW.MAIN:RegisterEvent("CHAT_MSG_ADDON")
EroWoW.MAIN:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	EroWoW:onEvent(self, event, prefix, message, channel, sender)
end)

-- Initializer --
function EroWoW:ini()

	--EroWoW.Menu.ini();
	EroWoW.R = EroWoW.Extension:import({id="ROOT"}, true);	-- Build the main extension for assets

	-- Add character
	EroWoW.ME = EroWoW.Character:new();

	EroWoW.ME.penis_size = EroWoW.LS.penis_size;
	EroWoW.ME.vagina_size = EroWoW.LS.vagina_size;
	EroWoW.ME.breast_size = EroWoW.LS.breast_size;
	EroWoW.ME.masochism = EroWoW.LS.masochism;

	-- Initialize timer and character
	EroWoW.Timer.ini();
	EroWoW.Character:ini()
	EroWoW.Menu:ini();

	-- Action slash command
	SLASH_EWACT1 = '/ewact'
	function SlashCmdList.EWACT(msg, editbox) EroWoW.Action:useOnTarget(msg, "target") end
	SLASH_EWRESET1 = '/ewreset'
	function SlashCmdList.EWRESET(msg, editbox) EroWoW:resetSettings() end

	EroWoW.Action:ini()

	-- Build libraries
	EroWoW.RPText:buildLibrary()
	EroWoW.Action:buildLibrary()
	EroWoW.Extension:index() -- Update the built libraries

	-- Bind listener
	RegisterAddonMessagePrefix(EroWoW.APP_NAME.."_act")		-- Sends an action	 {cb:cbToken, id:action_id, data:(var)data}
	RegisterAddonMessagePrefix(EroWoW.APP_NAME.."_cb")		-- Receive a callback {cb:cbToken, success:(bool)success, data:(var)data}
	

	print("EroWoW online!");
end



-- Reset settings
function EroWoW:resetSettings()
	local s = EroWoW.GS;
	for k,v in pairs(gDefaults) do s[k] = v end
	s = EroWoW.LS;
	for k,v in pairs(lDefaults) do s[k] = v end
	print("Settings reset")
end


	-- Primary event handler --
	-- Handles addon commands and loading --
function EroWoW:onEvent(self, event, prefix, message, channel, sender)


	if event == "ADDON_LOADED" and prefix == EroWoW.APP_NAME then
		
		if not EroWoWLocalStorage then EroWoWLocalStorage = {} end
		if not EroWoWGlobalStorage then EroWoWGlobalStorage = {} end
		-- handy shortcuts
		EroWoW.LS = EroWoWLocalStorage;
		EroWoW.GS = EroWoWGlobalStorage;

		-- Loading
		for k,v in pairs(gDefaults) do
			if EroWoWGlobalStorage[k] == nil then EroWoWGlobalStorage[k] = v end
		end
		for k,v in pairs(lDefaults) do
			if EroWoWLocalStorage[k] == nil then EroWoWLocalStorage[k] = v end
		end
		
		-- From here we can initialize
		EroWoW:ini();

		

		-- Load in abilities
		for k,v in pairs(EroWoW.LS.abilities) do
			local abil = EroWoW.Action:get(v.id)
			if abil then abil:import(v) end
		end

		-- Redraw with cooldowns
		EroWoW.Action:libSort();
		EroWoW.Menu:refreshSpellsPage();

	end

	if event == "PLAYER_LOGOUT" then

		-- Saving
		local l = EroWoW.LS;
		l.abilities = {};
		for k,v in pairs(EroWoW.Action.LIB) do
			if not v.hidden then
				table.insert( l.abilities, v:export() )
			end
		end
		
	end

	-- Action received
	if event == "CHAT_MSG_ADDON" then 
		
		if prefix == EroWoW.APP_NAME.."_act" then

			local sname = Ambiguate(sender, "all") 			-- Sender name for use in units
			local data = EroWoW.json.decode(message); 		-- JSON decode message
			local cb = data.cb								-- Callback if exists
			local aID = data.id								-- Action ID
			local success, data = EroWoW.Action:receive(aID, sender, data.data);
			if cb then
				EroWoW:sendCallback(cb, sname, success, data);
			end

		end

		if prefix == EroWoW.APP_NAME.."_cb" then

			local sname = Ambiguate(sender, "all")
			local data = EroWoW.json.decode(message);
			local cb = data.cb
			EroWoW.Callbacks:trigger(cb, data.success, data.data, sender);

		end

	end
end


	-- Communications --
function EroWoW:sendAction(unit, actionID, data, callback)

	local out = {
		id = actionID,
		data = data
	};

	if type(callback) == "function" then
		out.cb = EroWoW.Callbacks:add(callback);
	end
	SendAddonMessage(EroWoW.APP_NAME.."_act", EroWoW.json.encode(out), "WHISPER", unit)
end

function EroWoW:sendCallback(token, unit, success, data)

	local out = {
		cb = token,
		success = success,
		data = data
	};

	SendAddonMessage(EroWoW.APP_NAME.."_cb", EroWoW.json.encode(out), "WHISPER", unit)

end


	-- Tools --
-- Returns false so you can use it as a return value
function EroWoW:reportError(message, ignore)
	if ignore then return false end
	UIErrorsFrame:AddMessage(message, 1.0, 0.0, 0.0, 53, 6);
	return false;
end

function EroWoW:reportNotice(message)
	UIErrorsFrame:AddMessage(message, 0.5, 1.0, 0.5, 53, 6);
	return true;
end

-- Returns an RP name, removing realm name if needed and replacing self with you
function EroWoW:unitRpName(unit)
	unit = Ambiguate(unit, "all")
	if UnitIsUnit(unit, "player") then return "YOU" end
	return unit;
end

-- Removes an equipped item and puts it into inventory if possible
function EroWoW:removeEquipped( slot )

	for i=0,4 do
		local free = GetContainerNumFreeSlots(i);
		if free > 0 then
			PickupInventoryItem(slot)
			if i == 0 then 
				PutItemInBackpack() 
			else
				PutItemInBag(19+i)	
			end
			break
		end
	end

end

function EroWoW:timeFormat(seconds)

	if seconds > 3600 then return tostring(math.ceil(seconds/3600)).." Hr" end
	if seconds > 60 then return tostring(math.ceil(seconds/60)) .. " Min" end
	return tostring(math.ceil(seconds)).." Sec"
end

function EroWoW:Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function EroWoW:itemSlotToname(slot)
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
