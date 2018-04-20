ExiWoW.RPText = {}
ExiWoW.RPText.__index = ExiWoW.RPText;
ExiWoW.RPText.Lib = {}

ExiWoW.RPText.Req = {}
ExiWoW.RPText.Req.__index = ExiWoW.RPText.Req;

ExiWoW.RPText.DEBUG = false

-- The syntax of these are %S<type> for sender %T<type> for receiver. If no extra type is specified, it gets name
local TAG_SENDER_NAME = "%S";
local TAG_RECEIVER_NAME = "%T";
local TAG_SUFFIXES = {
	GROIN = "groin",
	GENITALS = "genitals",		-- Automatically picks one based on your gender
	PENIS = "penis",
	VAGINA = "vagina",
	BREASTS = "breasts",
	BREAST = "breast",			-- Singular version
	BUTT = "butt",
	BUTTCHEEK = "buttcheek", 	-- Singular version
	RACETAG = "rtag",			-- Fuzzy for worgen and pandas, automatically included in breast(s), butt(cheek)
	RACE = "race",
	CLASS = "class",
	UNDERWEAR = "undies",		-- Underwear name
	BULGE = "bulge",			-- Bulge, package, junk etc
	-- These are converted into somewhat applicable pronouns, him->her->their etc 
	HIM = "him",
	HIS = "his",
	HE = "he",
}
-- Prevents issues, longer ones should be first
local TAG_SUFFIX_ORDER = {}
for k,v in pairs(TAG_SUFFIXES) do
	table.insert(TAG_SUFFIX_ORDER, v)
end
table.sort(TAG_SUFFIX_ORDER, function(a,b)
	if string.len(a) > string.len(b) then return true end
	return false
end)

-- These are generic tags you can use
local TAG_GENERIC = {
	LEFTRIGHT = "leftright",			-- Returns left or right
	HARDEN = "harden",					-- Synonym for harden
	-- Only available from spells
	SPELL = "spell",					-- Name of spell that was cast
	-- Only available with an item condition
	ITEM = "item",						-- Name of last item validated with the condition
}

-- RPText CLASS
function ExiWoW.RPText:new(data)
	local self = {}
	setmetatable(self, ExiWoW.RPText);

	self.id = data.id or "";			-- Generally matches an Action ID. Gets converted into a table with {id = true}
	self.text_sender = data.text_sender or false; 		-- RP Text
	self.text_receiver = data.text_receiver or ""; 		-- RP Text
	self.text_bystander = data.text_bystander or false;	-- RP Text for bystanders
	self.requirements = type(data.requirements) == "table" and data.requirements or {};
	self.sound = data.sound;					-- Play this sound when sending or receiving this
	self.fn = data.fn or nil;					-- Only supported for NPC/Spell events. Actions should use the action system instead
	self.is_chat = data.is_chat or false		-- Makes the RP text display with chat colors instead. Set text_bystander to any non-false value to make it a say. Otherwise it's a whisper
	
	-- Automatic
	self.item = ""								-- Populated automatically when you use an item condition, contains the last valid item name

	if type(self.id) ~= "table" and self.id ~= "" then
		local id = {};
		id[self.id] = true;
		self.id = id;
	end

	return self
end

function ExiWoW.RPText:validate(sender, receiver, spelldata, spellType)

	local se = self;
	function validateThese(input, noOr)

		for k,v in pairs(input) do

			-- Validate a sub
			local success = true
			if v[1] ~= nil then 
				success = validateThese(v)	-- We must go deeper
			else
				success = v:validate(sender, receiver, spelldata, spellType) -- This entry was a condition
				if v.type == ExiWoW.RPText.Req.Types.RTYPE_HAS_INVENTORY and success then
					se.item = success;
				end
			end

			if success and not noOr then 
				return true
			elseif not success and noOr then
				return false
			end
		end
		return noOr

	end

	if not validateThese(self.requirements, true) then 
		return false 
	end
	return true

end

function ExiWoW.RPText:convert(text, sender, receiver, spelldata, item)

	-- Do the suffixes
	for k,v in pairs(TAG_SUFFIX_ORDER) do
		text = string.gsub(text, "%%S"..v, ExiWoW.RPText:getSynonym(v, sender, spelldata))
		text = string.gsub(text, "%%T"..v, ExiWoW.RPText:getSynonym(v, receiver, spelldata))
	end

	if item then 
		text = string.gsub(text, "%%"..TAG_GENERIC.ITEM, item)
	end

	for k,v in pairs(TAG_GENERIC) do
		text = string.gsub(text, "%%"..v, ExiWoW.RPText:getSynonym(v, receiver, spelldata))
	end
	
	

	-- Default names must go last because they're subsets
	text = string.gsub(text, "%%S", sender:getName())
	text = string.gsub(text, "%%T", receiver:getName())

	return text;

end

-- Converts and outputs text_receiver and audio, as well as triggering fn if applicable
function ExiWoW.RPText:convertAndReceive(sender, receiver, noSound, spell, customFunction)

	local text = self.text_receiver;
	if customFunction then text = customFunction(text) end
	local text = ExiWoW.RPText:convert(text, sender, receiver, spell, self.item);

	local bystander = self.text_bystander
	if not self.is_chat then
		ExiWoW.RPText:print(text)
	else
		ExiWoW.RPText:npcSpeak(text, nil, self.text_bystander == false);
		if self.text_bystander ~= false then
			bystander = self.text_receiver
		end
	end

	
	if bystander then
		ExiWoW:sendBystanderText(
			ExiWoW.RPText:convert(bystander, sender, receiver, spell, self.item),
			self.is_chat
		)
	end

	if type(self.fn) == "function" then
		self:fn(sender, receiver);
	end

	if self.sound and not noSound then
		PlaySound(self.sound, "SFX");
	end

end



-- STATIC
-- Returns an ExiWoW.RPText object
function ExiWoW.RPText:get(id, sender, receiver, spelldata, spellType)

	local viable = {};
	local isSelfCast = UnitIsUnit(sender:getName(), receiver:getName())
	
	for k,v in pairs(ExiWoW.RPText.Lib) do

		if ExiWoW:multiSearch(id, v.id) then

			local valid = v:validate(sender, receiver, spelldata, spellType)
			--print(v.id, id, v:validate(sender, receiver), v.text_sender)
			if 
				valid and 
				(
					(not v.text_sender and isSelfCast) or
					((v.text_sender or sender.type ~= "player") and not isSelfCast) -- NPC spells don't have text_sender, so they need to be put here
				)
			then
				table.insert(viable, v)
			end

		end
		

	end

	-- Pick a random element
	if next(viable) == nil then
		return false;
	end

	item = viable[math.random( #viable )]
	return item;

end

-- Same as above but triggers as well
function ExiWoW.RPText:trigger(id, sender, receiver, spelldata, spellType)
	local text = ExiWoW.RPText:get(id, sender, receiver, spelldata, spellType)
	if text then 
		text:convertAndReceive(sender, receiver, false) 
		return text
	end
	return false
end



function ExiWoW.RPText:getSynonym(tag, target, spelldata)

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
			tags = {"large", "big", "sizeable"}
		end

		if next(tags) == nil or math.random() < 0.5 then 
			return "" 
		end	
		return tags[math.random(#tags)].." "
		
	end

	local function getRaceTag()
		if math.random() < 0.5 then return "" end
		local tags = {}
		if string.lower(target.race) == "worgen" or string.lower(target.race) == "pandaren" then
			tags = {"fuzzy", "furry"}
		end
		if next(tags) ~= nil then
			return tags[math.random(#tags)].." "
		end
		return "";
	end

	local getRandom = function(...)
		local input = {...}
		return input[math.random(#input)]
	end

	local name = "";
	if target then name = target:getName(); end
	
	-- Generic tags
	if tag == TAG_GENERIC.LEFTRIGHT then
		if math.random() < 0.5 then return "left" end
		return "right"
	elseif tag == TAG_GENERIC.SPELL then
		if type(spelldata) == "table" and spelldata.name then return spelldata.name end
		return "spell"
	elseif tag == TAG_GENERIC.HARDEN then
		return getRandom("harden", "stiffen")
	end

	if tag == TAG_SUFFIXES.GENITALS then
		tag = TAG_SUFFIXES.GROIN		-- Default to groin
		local r = {}
		if target:getVaginaSize() ~= false then table.insert(r, TAG_SUFFIXES.VAGINA) end
		if target:getPenisSize() ~= false then table.insert(r, TAG_SUFFIXES.PENIS) end
		if #r > 0 then
			tag = r[math.random(#r)]
		end
	end

	-- Specific tags
	if tag == TAG_SUFFIXES.PENIS then
		return getSizeTag(target:getPenisSize())..getRandom("penis", "dick", "member", "cock", "manhood")
	elseif tag == TAG_SUFFIXES.GROIN then
		return getRandom("groin", "crotch")
	elseif tag == TAG_SUFFIXES.BULGE then
		return getRandom("bulge", "package", "junk")
	elseif tag == TAG_SUFFIXES.VAGINA then
		return getRandom("vagina", "pussy", "cunt")
	elseif tag == TAG_SUFFIXES.BREASTS then
		local out = getSizeTag(target:getBreastSize())..getRaceTag()..getRandom("boobs", "tits", "breasts", "knockers");
		return out
	elseif tag == TAG_SUFFIXES.RACETAG then
		return getRaceTag()
	elseif tag == TAG_SUFFIXES.BUTT then
		return getSizeTag(target:getButtSize())..getRandom("butt", "rear", "rump", "backside", "bottom")
	elseif tag == TAG_SUFFIXES.BREAST then
		return getSizeTag(target:getBreastSize())..getRandom("boob", "tit", "breast")
	elseif tag == TAG_SUFFIXES.BUTTCHEEK then
		return getSizeTag(target:getButtSize()).."buttcheek"
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
	elseif tag == TAG_SUFFIXES.UNDERWEAR then
		local und = target:getUnderwear();
		if not und then return "underwear" end
		local out = ""
		if math.random() < 0.5 and und.color then out = out..und.color.." "; end
		out = out..string.lower(und.name);
		return out
	elseif tag == TAG_SUFFIXES.HE then
		if target:isMale() then return "he" 
		elseif target:isFemale() then return "she"
		else return "they"
		end
	end

	return "";

end

function ExiWoW.RPText:print(text)
	-- 0.95686274509,0.49019607843,0.25490196078
	ChatFrame1:AddMessage(text, 0.737, 0.6, 0.980);
	--f47d41
	UIErrorsFrame:AddMessage(text, 1, 0.8, 1, 53, 6);
end

-- You can either do (sender,text) or (text)
function ExiWoW.RPText:npcSpeak(sender, text, isWhisper)
	if text then
		sender = sender.." says: "..text;
	end	
	local color = {0.95294117647, 0.94901960784, 0.59607843137}
	if isWhisper then
		color = {1.0,0.49,1.0}
	end
	ChatFrame1:AddMessage(sender, color[1], color[2], color[3]);
	UIErrorsFrame:AddMessage(sender, color[1], color[2], color[3], 53, 6);
end


-- Req CLASS --
-- Ranges are usually 0 = tiny, 1 = small, 2 = average, 3 = large, 4 = huge
ExiWoW.RPText.Req.Types = {
	RTYPE_HAS_PENIS = "has_penis",				-- These explain themselves
	RTYPE_HAS_VAGINA = "has_vagina",
	RTYPE_HAS_BREASTS = "has_breasts",
	RTYPE_PENIS_GREATER = "penis_greater",		-- (int)size :: Penis greater than size.
	RTYPE_BREASTS_GREATER = "breasts_greater",	-- (int)size :: Breasts greater than size.
	RTYPE_BUTT_GREATER = "butt_greater",			-- (int)size :: Butt greater than size.
	RTYPE_RACE = "race",							-- {raceEN=true, raceEn=true...} Table of races that are accepted. Example: {Gnome=true, HighmountainTauren=true}
	RTYPE_CLASS = "class",							-- {englishClass=true, englishClass=true...} Table of classes that are accepted. Example: {DEATHKNIGHT=true, MONK=true}
	RTYPE_TYPE = "type",							-- {typeOne=true, typeTwo=true...} For players this is always "player", otherwise refer to the type of NPC, such as "Humanoid"
	RTYPE_NAME = "name",							-- {nameOne=true, nameTwo=true...} Primairly useful for NPCs
	RTYPE_RANDOM = "rand",							-- {chance=0-1} 1 = 100%
	RTYPE_HAS_AURA = "aura",						-- {{name=name, caster=casterName}...} Player has one or more of these auras
	RTYPE_HAS_INVENTORY = "inv",					-- {{name=name, quant=min_quant}}
	RTYPE_UNDIES = "undies",						-- false = none, true = req, {name=true, name2=true...} = limit by name
	-- The following will only validate from spells received --
	RTYPE_CRIT = "crit",						-- Spell was a critical hit
	RTYPE_DETRIMENTAL = "detrimental",			-- Spell was detrimental
	RTYPE_SPELL_ADD = "spell_add",				-- Spell was just added
	RTYPE_SPELL_REM = "spell_rem",				-- Spell was just removed
	RTYPE_SPELL_TICK = "spell_tick",			-- Spell was ticking
	RTYPE_EQUIPMENT = "equipment",				-- {slot=(int)equipmentSlot(http://wowwiki.wikia.com/wiki/InventorySlotId), type="Plate/Mail/Leather/Cloth"}
	RTYPE_MELEE = "swing",						-- "Spell" was a melee swing

	-- These are primarily used for whisper texts
	RTYPE_REQUIRE_MALE = "req_male",			-- Allow male must be checked in settings
	RTYPE_REQUIRE_FEMALE = "req_female",		-- Allow female must be checked in settings
	RTYPE_REQUIRE_OTHER = "req_other"			-- Allow other must be checked in settings
}



function ExiWoW.RPText.Req:new(data)
	local self = {}
	setmetatable(self, ExiWoW.RPText.Req);

	self.type = data.type or false;									-- RTYPE_*
	self.sender = data.sender or false;								-- Validate against sender							-- 
	self.data = type(data.data) == "table" and data.data or {};		-- See RTYPE_*
	self.inverse = false;											-- Returns false if it DOES validate

	return self
end

function ExiWoW.RPText.Req:validate(sender, receiver, spelldata, spelltype)
	
	
	-- Todo: Validate a requirement
	local t = self.type;
	local targ = receiver;
	if self.sender then targ = sender end
	local data = self.data;
	local inverse = self.inverse;
	local name = targ:getName();
	local ty = ExiWoW.RPText.Req.Types;
	local ch = ExiWoW.ME;

	-- Try to find errors
	local out = false
	if t == ty.RTYPE_HAS_PENIS then
		out = targ:getPenisSize() ~= false;
	elseif t == ty.RTYPE_HAS_VAGINA then 
		out = targ:getVaginaSize() ~= false;
	elseif t == ty.RTYPE_HAS_BREASTS then 
		out = targ:getBreastSize() ~= false;
	elseif t == ty.RTYPE_NAME then
		out = ExiWoW:multiSearch(name, data)
	elseif t == ty.RTYPE_PENIS_GREATER then 
		out = targ:getPenisSize() ~= false and targ:getPenisSize() > data[1];
	elseif t == ty.RTYPE_BREASTS_GREATER then 
		out = targ:getBreastSize() ~= false and targ:getBreastSize() > data[1];
	elseif t == ty.RTYPE_BUTT_GREATER then 
		out = targ:getButtSize() > data[1];
	elseif t == ty.RTYPE_RACE then 
		out = ExiWoW:multiSearch(targ.race, data)
	elseif t == ty.RTYPE_CLASS then 
		out = ExiWoW:multiSearch(targ.class, data)
	elseif t == ty.RTYPE_TYPE then 
		out = ExiWoW:multiSearch(targ.type, data)
	elseif t == ty.RTYPE_CRIT then
		out = type(spelldata) == "table" and spelldata.crit;
	elseif t == ty.RTYPE_DETRIMENTAL then
		out = type(spelldata) == "table" and spelldata.harmful;
	elseif t == ty.RTYPE_MELEE then
		out = spelltype == ty.RTYPE_MELEE
	elseif t == ty.RTYPE_SPELL_ADD then
		out = spelltype == ty.RTYPE_SPELL_ADD;
	elseif t == ty.RTYPE_SPELL_REM then
		out = spelltype == ty.RTYPE_SPELL_REM;
	elseif t == ty.RTYPE_SPELL_TICK then
		out = spelltype == ty.RTYPE_SPELL_TICK;
	elseif t == ty.RTYPE_RANDOM then
		out = math.random() < data.chance;
	elseif t == ty.RTYPE_HAS_AURA then
		out = ExiWoW.Character:hasAura(data);
	elseif t == ty.RTYPE_HAS_INVENTORY then
		out = ExiWoW.Character:hasInventory(data);
	elseif t == ty.RTYPE_REQUIRE_MALE then
		out = ExiWoWGlobalStorage.taunt_male == true
	elseif t == ty.RTYPE_REQUIRE_FEMALE then
		out = ExiWoWGlobalStorage.taunt_female == true
	elseif t == ty.RTYPE_REQUIRE_OTHER then
		out = ExiWoWGlobalStorage.taunt_other == true
	elseif t == ty.RTYPE_EQUIPMENT then
		local unit = false
		if targ == ExiWoW.ME then unit = "player" 
		elseif targ == ExiWoW.TARGET then unit = "target"
		end
		-- /dump GetItemInfo(GetInventoryItemID("player", 7))
		if unit then 
			local id = GetInventoryItemID(unit, data.slot)
			if not id then 
				out = false
			else
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
					GetItemInfo(id)
				out = itemType == "Armor" and (data.type ~= nil and data.type == itemSubType)
			end
			out = ExiWoW.Character:hasInventory(data);
		end
	elseif t == ty.RTYPE_UNDIES then
		local und = targ:getUnderwear();
		out = 
			(data[1] == false and und == false) or
			(data[1] == true and und ~= false) or
			data[und.id]
	else print("Unknown validation type", t)
	end

	if ExiWoW.RPText.DEBUG and not out then print("Failed on", t, ExiWoW.json.encode(data)) end

	if inverse then out = not out end
	return out; 
	

end


