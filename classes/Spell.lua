local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event, Condition;

-- Spell is a DB entry for a WoW spell
local Spell = {};
Spell.__index = Spell;

	function Spell.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
		Condition = require("Condition");
	end

	-- Used for onTrigger
	Spell.ADD = "ADD";
	Spell.TICK = "TICK";
	Spell.REM = "REM";

	function Spell:new(data)
		local self = {}
		setmetatable(self, Spell);
		
		self.id = data.id;				-- Id is the name of the spell. Can contain a % or table (not set, ex) {"id1", "id2"}
		self.tags = type(data.tags) == "table" and data.tags or {};						-- Text tags of your choosing
		self.conditions = type(data.conditions) == "table" and data.conditions or {};	-- Conditions to run this
		self.onTrigger = data.trigger;			-- Function. Raised with args: str type, casterUnit, victimUnit, casterChar, victimChar
		self.always_trigger = data.always_trigger;	-- Set to true to have events ALWAYS trigger for this one. Otherwise trigger chance is random.
		self.alias = data.alias;						-- Allows you to change the ID when scanning for RP texts bound to this

		if not self.id then print("Spell inserted without an ID"); end

		self.id = Tools.createSet(self.id);

		return self
	end

	-- Adds suffixes
	function Spell:exportTags()
		local out = {};
		for k,v in pairs(self.tags) do
			table.insert(out, "TMPSPELL_"..v);
		end
		return out;
	end


	-- A little bit different to the others in that it returns only the function, not the Func object
	function Spell.get(id)
		return Database.getID("Spell", id);
	end

	

	-- Returns spells and checks conditions
	function Spell.filter(id, ...)
		local out = {}
		local all = Database.filter("Spell");
		for _,v in pairs(all) do
			if Tools.multiSearch(id, v.id) and Condition.all(v.conditions, ...) then
				table.insert(out, v);
			end
		end
		return out;
	end

export(
	"Spell", 
	Spell,
	{
		get = Spell.get,
		new = Spell.new,
		filter = Spell.filter
	},
	{
	}
)