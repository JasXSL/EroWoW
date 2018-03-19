ExiWoW.Extension = {}
ExiWoW.Extension.__index = ExiWoW.Extension;
ExiWoW.Extension.LIB = {};						-- name => ExiWoW.Extension

function ExiWoW.Extension:new(data, isRoot)
	local self = {}
	setmetatable(self, ExiWoW.Character); 
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
function ExiWoW.Extension:export()
	if self.id == nil then return false end
	-- Todo:export
end



-- STATIC --

-- Updates asset indexes --
function ExiWoW.Extension:index()

	local function TableConcat(t1,t2)
		for i=1,#t2 do
			t1[#t1+1] = t2[i]
		end
		return t1
	end

	-- Reset libraries
	ExiWoW.RPText.Lib = {}
	ExiWoW.SpellBinding.Lib = {}
	ExiWoW.Action.LIB = {}
	
	for k,v in pairs(ExiWoW.Extension.LIB) do
		ExiWoW.RPText.Lib = TableConcat(ExiWoW.RPText.Lib, v.rpTexts);
		ExiWoW.Action.LIB = TableConcat(ExiWoW.Action.LIB, v.actions);
		ExiWoW.SpellBinding.Lib = TableConcat(ExiWoW.SpellBinding.Lib, v.spellBindings);
	end
end

function ExiWoW.Extension:exportAll()
	local out = {}
	for k,v in pairs(ExiWoW.Extension.LIB) do
		local exp = v:export()
		if exp then 
			table.insert(out, exp)
		end
	end
end

function ExiWoW.Extension:import(data, isRoot)
	local ex = ExiWoW.Extension:new(data, isRoot);
	if ex then
		ExiWoW.Extension.LIB[ex.id] = ex
		return ex
	end
	
end

-- Import from text --
function ExiWoW.Extension:importFromText(text)
	-- Todo: Figure out a way to import with custom functions
end

function ExiWoW.Extension:remove(id)
	ExiWoW.Extension.LIB[id] = nil
end
