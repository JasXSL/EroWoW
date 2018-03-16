--[[
	 /console scriptErrors 1

	 TODO:
	 - Sort abilities on favorite, priority, name (so rest and detect can have higher priorities)
	 - Allow ability favorites by shift clicking
	 - Disrobe should remove random piece of clothing
	 - Add settings
		 - Masochism: Translate 1% of damage taken into n% arousal (between 1-5)
		 - Genitals: Should default to player sex
	 - Store CD data on file
	 - Add in more abilities
	 - Add pagination if you manage to fill up the whole first page
	 - Add global settings
		 - Use VH Connector
	 - Add VH connector
	 - Common spell on player tracker (like root tickle etc)
	 
]]

EroWoW = {};
EroWoW.APP_NAME = "EroWoW"
EroWoW.ME = nil					-- My character
EroWoW.PARTY = {};				-- Party characters (TODO)

-- Register main frame
EroWoW.MAIN = CreateFrame("Frame")
EroWoW.MAIN:RegisterEvent("ADDON_LOADED");
EroWoW.MAIN:RegisterEvent("CHAT_MSG_ADDON")
EroWoW.MAIN:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	EroWoW:onEvent(self, event, prefix, message, channel, sender)
end)

-- Initializer --
function EroWoW:ini()

	--EroWoW.Menu.ini();

	-- Add character
	EroWoW.ME = EroWoW.Character:new("player");

	-- Initialize timer and character
	EroWoW.Timer.ini();
	EroWoW.Character:ini()
	EroWoW.Menu:ini();

	-- Action slash command
	SLASH_EWACT1 = '/ewact'
	function SlashCmdList.EWACT(msg, editbox) EroWoW.Action:useOnTarget(msg, "target") end

	-- Build action library
	EroWoW.Action:ini()

	-- Bind listener
	RegisterAddonMessagePrefix(EroWoW.APP_NAME.."_act")		-- Sends an action	 {cb:cbToken, id:action_id, data:(var)data}
	RegisterAddonMessagePrefix(EroWoW.APP_NAME.."_cb")		-- Receive a callback {cb:cbToken, success:(bool)success, data:(var)data}
	

	print("EroWoW online!");
end

	-- Primary event handler --
	-- Handles addon commands and loading --
function EroWoW:onEvent(self, event, prefix, message, channel, sender)


	if event == "ADDON_LOADED" and prefix == EroWoW.APP_NAME then
		EroWoW:ini();
		return
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
			EroWoW.Callbacks:trigger(cb, data.success, data.data);

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
