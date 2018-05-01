local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event;

local Talkbox = {};
Talkbox.__index = Talkbox;

	function Talkbox.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
	end

	function Talkbox:new(data)
		local self = {}
		setmetatable(self, Talkbox);

		-- Lines of text
		self.id = data.id;
		self.lines = data.lines;				-- Paragraphs
		self.displayInfo = data.displayInfo; 	-- Find the NPC on wowhead, edit source and search for ModelViewer.show, that has the displayid
		self.title = data.title;				-- Title of talkbox
		self.onComplete = data.onComplete;		-- Function to run when completed
		self.rewards = data.rewards;			-- {{name = name, icon=icon, quant=quant}...}

		return self
	end


export(
	"Talkbox", 
	Talkbox
)