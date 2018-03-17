EroWoW.RPText = {}
EroWoW.RPText.__index = EroWoW.RPText;

EroWoW.RPText.Req = {}
EroWoW.RPText.Req.__index = EroWoW.RPText.Req;




local TAG_SENDER_NAME = "%S";
local TAG_RECEIVER_NAME = "%T";
local TAG_PENIS = "%penis";
local TAG_VAGINA = "%vagina";
local TAG_BREASTS = "%breasts";
local TAG_BUTT = "%butt";
local TAG_SENDER_RACE = "%Srace"
local TAG_RECEIVER_RACE = "%Rrace"


-- RPText CLASS
function EroWoW.RPText:new(data)
	local self = {}
	setmetatable(self, EroWoW.RPText);

	self.id = data.id or "";			-- Generally matches an Action ID
	self.text = data.text or ""; 		-- RP Text
	self.requirements = type(data.requirements) == "table" and data.requirements or {};

	return self
end

function EroWoW.RPText:validate(sender, receiver)

	-- Todo: Validate genitals

end

function EroWoW.RPText:convert(sender, receiver)

	-- Todo: Convert the text

end




-- Req CLASS --
-- Ranges are usually 0 = tiny, 1 = small, 2 = average, 3 = large, 4 = huge
local RTYPE_HAS_PENIS = "has_penis";				-- These explain themselves
local RTYPE_HAS_VAGINA = "has_vagina";
local RTYPE_HAS_BREASTS = "has_breasts";
local RTYPE_PENIS_GREATER = "penis_greater";		-- (int)size :: Penis greater than size.
local RTYPE_BREASTS_GREATER = "breasts_greater";	-- (int)size :: Breasts greater than size.
local RTYPE_BUTT_GREATER = "butt_greater";			-- (int)size :: Butt greater than size.
local RTYPE_RACE = "race";							-- Uses english race name
local RTYPE_CLASS = "class";						-- Uses english class name



function EroWoW.RPText.Req:new(data)
	local self = {}
	setmetatable(self, EroWoW.RPText.Req);

	self.type = data.type or false;									-- RTYPE_*
	self.sender = data.target or false;								-- Validate against sender							-- 
	self.data = type(data.data) == "table" and data.data or {};		-- See RTYPE_*
	self.inverse = false;											-- Returns false if it DOES validate

	return self
end

function EroWoW.RPText.Req:validate(sender, receiver)
	
	-- Todo: Validate a requirement

end


