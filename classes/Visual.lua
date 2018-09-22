
local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Tools, Database, Timer;

-- /dump ExiWoW.require("Visual").get("heavyPain"):trigger()
local Visual = {};
Visual.__index = Visual;

	function Visual.ini()
		Tools = require("Tools");
		Database = require("Database");
	end

	function Visual:new(data)
		local self = {}
		setmetatable(self, Visual);

		self.id = data.id;
		self.image = data.image;
		self.frame = nil;
		self.onFrameCreated = data.create;
		self.onFrameUpdate = data.update;						-- Required, otherwise it uses the template function below. Return true when the animation is done
		self.onStart = data.start;
		self.timeTriggered = GetTime();
		self.timer = nil;
		self.blend = data.blend;

		if type(self.onFrameUpdate) ~= "function" then
			self.onFrameUpdate = function()
				local delta = GetTime()-self.timeTriggered;
				local alpha = max(0,1-delta);
				if alpha == 0 then
					return true;
				end
				return alpha;
			end
		end

		return self
	end

	function Visual:build()
		if not self.frame then
			self.frame = CreateFrame("Frame", nil, UIParent);
			self.frame:SetAllPoints();
			self.frame:SetFrameStrata("BACKGROUND");
			local t = self.frame:CreateTexture(nil, "BACKGROUND");
			self.frame.bg = t;
			t:SetTexture("Interface/AddOns/ExiWoW/media/borders/"..self.image);
			t:SetAllPoints(self.frame);
			t:SetBlendMode(self.blend and self.blend or "ADD");
			self.frame:Hide();
			if type(self.onFrameCreated) == "function" then
				self:onFrameCreated();
			end
		end
	end

	function Visual:trigger()
		self:build();

		self.frame:SetAlpha(0);
		self.frame:Show();

		if type(self.onStart) == "function" then 
			self:onStart();
		end
		self.timeTriggered = GetTime();
		self.frame:SetScript("OnUpdate", function(frame, elapsed)
			local update = self:onFrameUpdate(elapsed);
			if type(update) ~= "number" then
				self.frame:SetScript("OnUpdate", nil);
				self.frame:Hide();
			else
				self.frame:SetAlpha(update);
			end
		end);
	end

	-- Force stops a visual
	function Visual:stop()
		self.frame:SetScript("OnUpdate", nil);
		self.frame:Hide();
	end

	-- Request from database
	function Visual.get(id)
		return Database.getID("Visual", id);
	end




export(
	"Visual", 
	Visual,
	-- Pub
	{
		new = Visual.new,
		get = Visual.get,
	},
	-- Pvt
	{}
)