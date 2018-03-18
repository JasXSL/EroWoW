EroWoW.Extension = {}
EroWoW.Extension.__index = EroWoW.Extension;
EroWoW.Extension.LIB = {};						-- name => EroWoW.Extension

function EroWoW.Extension:new(data, isRoot)
	local self = {}
	setmetatable(self, EroWoW.Character); 
	if type(data) ~= "table" or type(data.id) ~= "string" or (data.id == "ROOT" and not isRoot) then
		print("Unable to import extension, data or id missing")
		return false;
	end

	local function importTable(t)
		if type(t) ~= table then return {} end
		return t
	end

	self.id = data.id

	-- Import RP
	self.rpTexts = importTable(data.rpTexts)

	-- Import actions
	self.actions = importTable(data.actions)

	-- Import SpellBindings
	self.spellBindings = importTable(data.spellBindings)

	return self
end

-- Exports to a JSON string for the user
function EroWoW.Extension:export()
	if self.id == nil then return false end
	-- Todo:export
end



-- STATIC --

-- Updates asset indexes --
function EroWoW.Extension:index()

	local function TableConcat(t1,t2)
		for i=1,#t2 do
			t1[#t1+1] = t2[i]
		end
		return t1
	end

	-- Reset libraries
	EroWoW.RPText.Lib = {}
	EroWoW.SpellBinding.Lib = {}
	EroWoW.Action.LIB = {}
	
	for k,v in pairs(EroWoW.Extension.LIB) do
		EroWoW.RPText.Lib = TableConcat(EroWoW.RPText.Lib, v.rpTexts);
		EroWoW.Action.LIB = TableConcat(EroWoW.Action.LIB, v.actions);
		EroWoW.SpellBinding.Lib = TableConcat(EroWoW.SpellBinding.Lib, v.spellBindings);
	end
end

function EroWoW.Extension:exportAll()
	local out = {}
	for k,v in pairs(EroWoW.Extension.LIB) do
		local exp = v:export()
		if exp then 
			table.insert(out, exp)
		end
	end
end

function EroWoW.Extension:import(data, isRoot)
	local ex = EroWoW.Extension:new(data, isRoot);
	if ex then
		EroWoW.Extension.LIB[ex.id] = ex
		return ex
	end
	
end

-- Import from text --
function EroWoW.Extension:importFromText(text)
	-- Todo: Figure out a way to import with custom functions
end

function EroWoW.Extension:remove(id)
	EroWoW.Extension.LIB[id] = nil
end
