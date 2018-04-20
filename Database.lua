local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Database = {
	tables = {}
};

function Database.add(tble, value)
	if type(value) ~= "table" then
		value = {value};
	end
	if type(Database.tables[tble]) ~= "table" then
		Database.tables[tble] = {};
	end
	
	for _,v in pairs(value) do
		table.insert(Database.tables[tble], v);
	end
end



function Database.sort(tble, fn)
	local tb = Database.tables[tble];
	if type(tb) ~= "table" then return false end
	table.sort(tb, fn);
	return true;
end

function Database.clearTables(...)
	for _,v in pairs({...}) do
		Database.tables[v] = nil;
	end
end

-- Lets you supply one or many filter functions
-- Returns false if none are found
function Database.filter(tble, filters)

	local tb = Database.tables[tble];
	if type(tb) ~= "table" then return false end
	if type(filters) ~= "table" then filters = {} end

	local out = {};
	for _,v in pairs(tb) do
		local success = true;
		for _,f in pairs(filters) do
			if f(v) == false then
				success = false;
				break;
			end
		end
		if success then
			table.insert(out, v)
		end
	end
	return out;
end

export("Database", Database, {}, {
	add = Database.add,
	sort = Database.sort,
	filter = Database.filter,
	clearTables = Database.clearTables
})
