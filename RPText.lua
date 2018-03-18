EroWoW.RPText = {}
EroWoW.RPText.__index = EroWoW.RPText;
EroWoW.RPText.Lib = {}

EroWoW.RPText.Req = {}
EroWoW.RPText.Req.__index = EroWoW.RPText.Req;

-- The syntax of these are %S<type> for sender %T<type> for receiver. If no extra type is specified, it gets name
local TAG_SENDER_NAME = "%S";
local TAG_RECEIVER_NAME = "%T";
local TAG_SUFFIXES = {
	GROIN = "groin",
	PENIS = "penis",
	VAGINA = "vagina",
	BREASTS = "breasts",
	BUTT = "butt",
	RACE = "race",
	CLASS = "class",
	-- These are converted into somewhat applicable pronouns, him->her->their etc 
	HIM = "him",
	HIS = "his",
	HE = "he"
}

-- RPText CLASS
function EroWoW.RPText:new(data)
	local self = {}
	setmetatable(self, EroWoW.RPText);

	self.id = data.id or "";			-- Generally matches an Action ID
	self.text_sender = data.text_sender or false; 		-- RP Text
	self.text_receiver = data.text_receiver or ""; 		-- RP Text
	self.requirements = type(data.requirements) == "table" and data.requirements or {};
	self.sound = data.sound;					-- Play this sound when sending or receiving this
	self.fn = data.fn or nil;					-- Only supported for NPC/Spell events. Actions should use the action system instead

	return self
end

function EroWoW.RPText:validate(sender, receiver)

	for k,v in pairs(self.requirements) do
		if not v:validate(sender, receiver) then return false end	
	end
	return true

end

function EroWoW.RPText:convert(text, sender, receiver)

	
	-- Do the suffixes
	for k,v in pairs(TAG_SUFFIXES) do
		text = string.gsub(text, "%%S"..v, EroWoW.RPText:getSynonym(v, sender))
		text = string.gsub(text, "%%T"..v, EroWoW.RPText:getSynonym(v, receiver))
	end

	-- Default names must go last because they're subsets
	text = string.gsub(text, "%%S", sender:getName())
	text = string.gsub(text, "%%T", receiver:getName())

	return text;

end




-- STATIC
-- Returns an EroWoW.RPText object
function EroWoW.RPText:get(id, sender, receiver)

	local viable = {};
	local isSelfCast = UnitIsUnit(sender:getName(), receiver:getName())
	

	for k,v in pairs(EroWoW.RPText.Lib) do
		--print(v.id, id, v:validate(sender, receiver), v.text_sender)
		if
			v.id == id and v:validate(sender, receiver) and 
			(
				(not v.text_sender and isSelfCast) or
				((v.text_sender or sender.type ~= "player") and not isSelfCast) -- NPC spells don't have text_sender, so they need to be put here
			)
		then
			table.insert(viable, v)
		end
	end

	-- Pick a random element
	if next(viable) == nil then
		return false;
	end

	item = viable[math.random( #viable )]
	return item;

end

function EroWoW.RPText:getSynonym(tag, target, isReceiver)

	local getSizeTag = function(size)

		if type(size) ~= "number" then 
			return "" 
		end

		local tags = {"huge", "enormous", "giant"};
		if size < 1 then 
			tags = {"tiny", "miniscule", "puny"}
		elseif size < 2 then 
			tags = {"lesser", "smallish", "undersize"} 
		elseif size < 3 then 
			tags = {}
		elseif size < 4 then 
			tags = {"large", "hefty", "big", "impressive"}
		end

		if next(tags) == nil or math.random(2)==1 then 
			return "" 
		end	
		return tags[math.random(#tags)].." "
		
	end

	local getRandom = function(...)
		local input = {...}
		return input[math.random(#input)]
	end

	local name = target:getName();

	if tag == TAG_SUFFIXES.PENIS then
		return getSizeTag(target:getPenisSize())..getRandom("penis", "dick", "member", "cock", "manhood")
	elseif tag == TAG_SUFFIXES.GROIN then
		return getRandom("groin", "crotch")
	elseif tag == TAG_SUFFIXES.VAGINA then
		return getRandom("vagina", "pussy", "cunt", "beaver")
	elseif tag == TAG_SUFFIXES.BREASTS then
		return getSizeTag(target:getBreastSize())..getRandom("boobs", "tits", "breasts", "knockers")
	elseif tag == TAG_SUFFIXES.BUTT then
		return getSizeTag(target:getButtSize())..getRandom("butt", "rear", "rump", "backside", "bottom")
	elseif tag == TAG_SUFFIXES.RACE then
		return string.lower(target.race)
	elseif tag == TAG_SUFFIXES.CLASS then
		return string.lower(target.class)
	elseif tag == TAG_SUFFIXES.HIM then
		if target:isMale() then return "him"
		elseif target:isFemale() then return "her"
		else return "them"
		end
	elseif tag == TAG_SUFFIXES.HIS then
		if target:isMale() then return "his" 
		elseif target:isFemale() then return "her"
		else return "their"
		end
	elseif tag == TAG_SUFFIXES.HE then
		if target:isMale() then return "he" 
		elseif target:isFemale() then return "she"
		else return "they"
		end
	end

	return "";

end

function EroWoW.RPText:print(text)
	ChatFrame2:AddMessage(text, 1,0.8,1);
	UIErrorsFrame:AddMessage(text, 1, 0.8, 1, 53, 6);
end



-- Req CLASS --
-- Ranges are usually 0 = tiny, 1 = small, 2 = average, 3 = large, 4 = huge
EroWoW.RPText.Req.Types = {
RTYPE_HAS_PENIS = "has_penis",				-- These explain themselves
RTYPE_HAS_VAGINA = "has_vagina",
RTYPE_HAS_BREASTS = "has_breasts",
RTYPE_PENIS_GREATER = "penis_greater",		-- (int)size :: Penis greater than size.
RTYPE_BREASTS_GREATER = "breasts_greater",	-- (int)size :: Breasts greater than size.
RTYPE_BUTT_GREATER = "butt_greater",			-- (int)size :: Butt greater than size.
RTYPE_RACE = "race",							-- {raceEN=true, raceEn=true...} Table of races that are accepted. Example: {Gnome=true, HighmountainTauren=true}
RTYPE_CLASS = "class",						-- {englishClass=true, englishClass=true...} Table of classes that are accepted. Example: {DEATHKNIGHT=true, MONK=true}
RTYPE_TYPE = "type"							-- {typeOne=true, typeTwo=true...} For players this is always "player", otherwise refer to the type of NPC, such as "Humanoid"
}



function EroWoW.RPText.Req:new(data)
	local self = {}
	setmetatable(self, EroWoW.RPText.Req);

	self.type = data.type or false;									-- RTYPE_*
	self.sender = data.sender or false;								-- Validate against sender							-- 
	self.data = type(data.data) == "table" and data.data or {};		-- See RTYPE_*
	self.inverse = false;											-- Returns false if it DOES validate

	return self
end

function EroWoW.RPText.Req:validate(sender, receiver)
	
	
	-- Todo: Validate a requirement
	local t = self.type;
	local targ = receiver;
	if self.sender then targ = sender end
	local data = self.data;
	local inverse = self.inverse;
	local name = targ:getName();

	local ty = EroWoW.RPText.Req.Types;

	-- Try to find errors
	local out = false
	if t == ty.RTYPE_HAS_PENIS then
		out = targ:getPenisSize() ~= false;
	elseif t == ty.RTYPE_HAS_VAGINA then 
		out = targ:getVaginaSize() ~= false;
	elseif t == ty.RTYPE_HAS_BREASTS then 
		out = targ:getBreastSize() ~= false;
	elseif t == ty.RTYPE_PENIS_GREATER then 
		out = targ:getPenisSize() ~= false and targ:getPenisSize() > data[1];
	elseif t == ty.RTYPE_BREASTS_GREATER then 
		out = targ:getBreastSize() ~= false and targ:getBreastSize() > data[1];
	elseif t == ty.RTYPE_BUTT_GREATER then 
		out = targ:getButtSize() > data[1];
	elseif t == ty.RTYPE_RACE then 
		out = targ.race ~= nil and data[targ.race] ~= nil;
	elseif t == ty.RTYPE_CLASS then 
		out = targ.class ~= nil and data[targ.class] ~= nil;
	elseif t == ty.RTYPE_TYPE then 
		out = targ.type ~= nil and data[targ.type] ~= nil;
	else print("Unknown validation type", t)
	end

	if inverse then out = not out end
	return out; 
	

end


