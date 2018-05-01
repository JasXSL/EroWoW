local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local RPText, Character, Tools, Database, Action, Event, Talkbox, Underwear, UI;

local Quest = {};
Quest.progress = {};		-- Pointer to localStorage, can be modified directly, but don't overwrite it
--[[ 
	{id={
		completed=true/false,
		active=true/false,
		objectives={
			id={
				current_num=nr,
			}
		}
	}}
]]
Quest.__index = Quest;

	function Quest.ini()
		RPText = require("RPText");
		Character = require("Character");
		Tools = require("Tools");
		Database = require("Database");
		Action = require("Action");
		Event = require("Event");
		Talkbox = require("Talkbox");
		Underwear = require("Underwear");
		UI = require("UI");
		Quest.progress = localStorage.quests;
	end

	function Quest:new(data)
		local self = {}
		setmetatable(self, Quest);

		self.id = data.id;
		self.name = data.name;
		self.objectives = data.objectives or {};		-- You can wrap objectives in {} to create packages
		self.completed = data.completed or false;
		self.rewards = data.rewards or {};				-- Use reward object
		
		self.journal_entry = data.journal_entry or "";
		self.questgiver = data.questgiver or 0;			-- displayInfo in Talkbox
		self.questfinisher = data.questfinisher or self.questgiver;
		self.active = data.active or false;				-- Picked up
		
		self.listeners = {};							-- Event listeners, these are added when a quest is loaded and not completed or active, unloaded when a quest is picked up

		self.start_text = data.start_text or {};		-- Paragraphs for the initializing talkbox
		self.start_events = data.start_events or {};	-- Events to listen to {event=function} to start the quest

		self.end_journal = data.end_journal or "Claim your reward";
		self.end_text = data.end_text or {};			-- Paragraphs for the outro talkbox
		self.end_events = data.end_events or nil;		-- Events to listen to to finish the quest. If nil, it's an auto handin anywhere
		
	
		if type(self.start_text) ~= "table" then
			self.start_text = {self.start_text};
		end

		if not self.id then print("Error, a quest is missing id:", self.id); end
		
		for k,v in pairs(self.objectives) do
			if type(v) ~= "table" then print("Invalid objective in quest", self.id) end
			if not v[1] then 
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
		return false
	end

	-- This doesn't require a specific place to hand in
	function Quest:isDetachedHandin()
		return not self.end_events;
	end
	function Quest:isReadyToHandIn()
		return not self:getCurrentObjectives();
	end

	function Quest:onObjectiveUpdated(objective)
		UI.quests.update();
		self:rebindObjectives();
		if self:isReadyToHandIn() then
			--self.completed = true;
			self:initialize();	-- Re-initialize quest with event bindings
		end
		self:save();
	end

	-- Rebinds objectives
	function Quest:rebindObjectives()
		for k,v in pairs(self.objectives) do
			for _,o in pairs(v) do
				o:onObjectiveDisable();
			end
		end
		local active = self:getCurrentObjectives();
		if active then
			for _,o in pairs(active) do
				o:onObjectiveEnable();
			end
		end
	end

	function Quest:offer()
		local q = self;
		local rewards = {};
		for _,r in pairs(self.rewards) do
			table.insert(rewards, r:getTalkboxData());
		end
		local talkbox = Talkbox:new({
			id = self.id,
			lines = self.start_text,
			displayInfo = self.questgiver,
			title = self.name,
			rewards = rewards,
			onComplete = function(self) 
				PlaySound(618, "Dialog");
				q.active = true;
				q:save();
				UI.quests.update();
				for _,evt in pairs(q.listeners) do
					Event.off(evt);
				end
				q:initialize();
				RPText.print("Quest accepted: "..self.name);
			end
		});
		PlaySound(23404, "Dialog");
		UI.talkbox.set(talkbox);
	end

	function Quest:handIn()
		local q = self;
		local rewards = {};
		for _,r in pairs(self.rewards) do
			table.insert(rewards, r:getTalkboxData());
		end
		local talkbox = Talkbox:new({
			id = self.id,
			lines = self.end_text,
			displayInfo = self.questfinisher,
			title = self.name,
			rewards = rewards,
			onComplete = function(self) 
				q:collectReward();
			end
		});
		PlaySound(23404, "Dialog");
		UI.talkbox.set(talkbox);
	end

	function Quest:collectReward()

		for _,reward in pairs(self.rewards) do
			ExiWoW.ME:addItem(reward.type, reward.id, reward.quant);
		end

		PlaySound(878, "Dialog");
		self.completed = true;
		self:save();
		UI.quests.update();
		self:initialize(); -- Wipes event bindings
	end

	-- /run ExiWoW.require("Quest").get("SHOCKTACLE"):reset();
	function Quest:reset()
		Quest.progress[self.id] = nil;
	end

	function Quest:save()
		local objectives = {};
		for _,v in pairs(self.objectives) do
			for _,o in pairs(v) do
				objectives[o.id] = o:export();
			end
		end
		local out = {
			completed = self.completed,
			objectives = objectives,
			active = self.active,
		};
		Quest.progress[self.id] = out;
	end

	function Quest:getObjective(id)
		for _,v in pairs(self.objectives) do
			for _,o in pairs(v) do
				if o.id == id then
					return o;
				end
			end
		end
	end

	function Quest:onPickupEvt(data, event)
		if not self.start_events[event] then return end
		if self.start_events[event](self, data) then
			self:offer();
		end
	end

	function Quest:onHandinEvt(data, event)
		if not self.end_events[event] then return end
		if self.end_events[event](self, data) then
			self:handIn();
		end
	end

	function Quest:load(data)
		if data.completed then
			self.completed = data.completed;
		end
		if data.active then
			self.active = data.active;
		end
		if type(data.objectives) == "table" then
			for id,o in pairs(data.objectives) do
				local obj = self:getObjective(id);
				if obj then
					obj:load(o);
				end
			end
		end
	end

	-- Run whenever a quest is initialized (after load)
	function Quest:initialize()
		-- Unbind just in case
		for _,l in pairs(self.listeners) do
			Event.off(l);
		end
		self.listeners = {};

		if not self.completed and not self.active then
			-- Bind events
			local se = self;
			for evt,fn in pairs(self.start_events) do
				table.insert(self.listeners, Event.on(evt, function(...)
					se:onPickupEvt(...);
				end));
			end
		elseif not self.completed and self:isReadyToHandIn() then
			if not self:isDetachedHandin() then
				for evt,fn in self.end_events do
					table.insert(self.listeners, Event.on(evt, function(...)
						se:onHandinEvt(...);
					end));
				end
			else
				self:handIn();
			end
		elseif self.active then 
			self:rebindObjectives();
		end

	end

	-- A little bit different to the others in that it returns only the function, not the Func object
	function Quest.get(id)
		return Database.getID("Quest", id);
	end

	-- Loads progress
	function Quest.loadFromStorage()
		local all = Database.filter("Quest");
		for _,q in pairs(all) do
			if Quest.progress[q.id] then
				q:load(Quest.progress[q.id]);
			end
			q:initialize();
		end
	end

	function Quest.getActive()
		local out = {};
		local all = Database.filter("Quest");
		for _,v in pairs(all) do
			if v.active and not v.completed then
				table.insert(out, v);
			end
		end
		return out;
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
		self.onObjectiveEnable = data.onObjectiveEnable or function() end		-- Raised when objective is activated
		self.onObjectiveDisable = data.onObjectiveDisable or function() end	-- Raised when objective is completed or disabled
		self.current_num = 0;
		self.quest = nil;
		self.data = data.data or {};							-- Any custom data

		return self;
	end

	function Objective:export()
		return {
			current_num = self.current_num
		};
	end

	function Objective:load(data)
		if data.current_num then self.current_num = data.current_num end
	end

	function Objective:setQuest(quest)
		self.quest = quest;
	end

	-- Adds to objective
	function Objective:add(num)
		num = num or 1;
		self.current_num = self.current_num+num;
		if self.current_num > self.num then
			self.current_num = self.num;
			RPText.print(self.name.." completed", true);
		else
			RPText.print(self.name.." "..self.current_num.."/"..self.num, true);
		end
		self.quest:onObjectiveUpdated(self);
	end













local Reward = {};
Reward.__index = Reward;
	function Reward:new(data)
		local self = {};
		setmetatable(self, Reward);
		
		self.type = data.type or "Underwear";
		self.id = data.id;
		self.quant = data.quant or 1;

		if not self.id then print("Error on quest reward creation, ID is not defined") end

		return self;
	end

	-- Creates an object with data for a talkbox reward entry
	function Reward:getTalkboxData()
		local out = {}
		if self.type == "Underwear" then
			local item = Underwear.get(self.id);
			out.name = item.name;
			out.icon = "Interface/Icons/"..item.icon;
		elseif self.type == "Charges" then
			local item = Action.get(self.id);
			out.name = item.name;
			out.icon = "Interface/Icons/"..item.texture;
		end
		out.quant = self.quant;
		return out;
	end

-- /run ExiWoW.require("Quest").get("SHOCKTACLE"):reset();
-- /run ExiWoW.require("Quest").get("SHOCKTACLE"):offer();
-- /run ExiWoW.require("Quest").get("SHOCKTACLE"):getCurrentObjectives()[1]:add(6);
export(
	"Quest", 
	Quest,
	{
		get = Quest.get,
		new = Quest.new,
		Objective = Objective,
		Reward = Reward,
		getActive = Quest.getActive
	},
	{
		loadFromStorage = Quest.loadFromStorage
	}
)