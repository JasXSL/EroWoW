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
		self.name = data.name;
		print(type(data.objectives), #data.objectives);
		self.objectives = data.objectives or {};		-- You can wrap objectives in {} to create packages
		self.conditions = data.conditions or {};
		self.completed = data.completed or false;
		self.rewards = data.rewards or {};
		self.description = data.description or "";

		if not self.id then print("Error, a quest is missing id:", self.id); end
		
		for k,v in pairs(self.objectives) do
			if type(v) ~= "table" then print("Invalid objective in quest", self.id) end
			if not v[0] then 
				v = {v};
				self.objectives[k] = v;
			end
			for _,o in pairs(v) do
				o:setQuest(self);
			end
		end


		return self
	end

	function Quest:getCurrentObjectives()
		for _,v in pairs(self.objectives) do
			for _,o in pairs(v) do
				if o.current_num < o.num then
					return v;
				end
			end
		end
		return {}
	end

	function Quest:onObjectiveUpdated(objective)
		print("Objective updated");
	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Quest.get(id)
		return Database.getID("Quest", id);
	end





local Objective = {};
Objective.__index = Objective;
	function Objective:new(data)
		local self = {};
		setmetatable(self, Objective);
		self.id = data.id;
		self.name = data.name;
		self.num = data.num or 1;				-- Num of name to do to complete it
		self.optional = data.optional or false;
		self.onObjectiveEnable = function() end		-- Raised when objective is activated
		self.onObjectiveDisable = function() end	-- Raised when objective is completed or disabled
		self.current_num = 0;
		self.quest = nil;

		return self;
	end

	function Objective:setQuest(quest)
		self.quest = quest;
	end

	-- Adds to objective
	function Objective:add(num)
		num = num or 1;
		self.current_num = self.current_num+num;
		self.quest:onObjectiveUpdated(self);
	end



export(
	"Quest", 
	Quest,
	{
		get = Quest.get,
		new = Quest.new,
		Objective = Objective
	},
	{}
)