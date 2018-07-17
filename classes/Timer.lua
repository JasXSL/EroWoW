local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Timer = {}
	Timer.id = 0;		-- Increased whenever you set a timer
	Timer.timers = {};	-- {id:int id, started:nr started, duration: nr duration, times:int nr, callback: fn callback}
	Timer.time = GetTime();

	function Timer.ini()

		local a = nil;
		local f = CreateFrame("Frame",nil,UIParent);

		f:SetScript("OnUpdate", Timer.onUpdate);

	end

	function Timer.onUpdate()
		Timer.time = GetTime();
		local t = Timer.time;

		for k,v in pairs(Timer.timers) do

			-- Timer timed out
			if v.started+v.duration <= t then

				local times = tonumber(v.times) - 1;
				local dur = v.duration;
				local callback = v.callback;

				if times < 1 then
					Timer.timers[k] = nil -- Remove timer
				else
					Timer.timers[k].times = times;
					Timer.timers[k].started = t;
				end

				if type(v.callback) == "function" then
					v.callback();
				end

			end

		end
	end




	-- Use math.huge for infinite times
	function Timer.set(callback, seconds, times)

		if type(callback) ~= "function" then
			print("Can't set timer, callback invalid", callback);
			return false
		end

		local t = {
			id = Timer.getNewId(),
			started = Timer.time,
			duration = seconds or 1,
			times = times or 1,
			callback = callback
		};
		table.insert(Timer.timers, t);
		return t.id;

	end

	function Timer.clear(id)
		for k,v in pairs(Timer.timers) do
			if v.id == id then
				Timer.timers[k] = nil;
				return;
			end
		end
	end

	-- Fetches an id for the timer
	function Timer.getNewId()
		Timer.id = Timer.id+1;
		return Timer.id;
	end

export(
	"Timer", 
	Timer,
	{
		set = Timer.set,
		clear = Timer.clear
	}
)
