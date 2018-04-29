local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;

local Quest = {};
Quest.__index = Quest;

	function Quest.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function Quest:new(data)
		local self = {}
		setmetatable(self, Quest);

		self.id = data.id;

		if not self.id then print("Error, a quest is missing id:", self.id); end
		
		return self
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Quest.get(id)
		return Database.getID("Quest", id);
	end

export(
	"Quest", 
	Quest,
	{
		get = Quest.get,
		new = Quest.new
	},
	{}
)