ExiWoW.Timer = {}
ExiWoW.Timer.id = 0;		-- Increased whenever you set a timer
ExiWoW.Timer.timers = {};	-- {id:int id, started:nr started, duration: nr duration, times:int nr, callback: fn callback}
ExiWoW.Timer.time = 0;

function ExiWoW.Timer.ini()

	local a = nil

	local f = CreateFrame("Frame",nil,UIParent);
	f:SetScript("OnUpdate", function(self, sinceLastUpdate)
		ExiWoW.Timer.time = ExiWoW.Timer.time+sinceLastUpdate;
		local t = ExiWoW.Timer.time;

		for k,v in pairs(ExiWoW.Timer.timers) do

			-- Timer timed out
			if v.started+v.duration <= t then

				local times = tonumber(v.times) - 1;
				local dur = v.duration;
				local callback = v.callback;

				if times < 1 then
					ExiWoW.Timer.timers[k] = nil -- Remove timer
				else
					ExiWoW.Timer.timers[k].times = times;
					ExiWoW.Timer.timers[k].started = t;
				end

				if type(v.callback) == "function" then
					v:callback();
				end

			end

		end

	end);

end






-- Use math.huge for infinite times
function ExiWoW.Timer:set(callback, seconds, times)

	local t = {
		id = ExiWoW.getNewId(),
		started = ExiWoW.Timer.time,
		duration = seconds or 1,
		times = times or 1,
		callback = callback
	};
	table.insert(ExiWoW.Timer.timers, t);
	return t.id;

end

function ExiWoW.Timer:clear(id)
	for k,v in pairs(ExiWoW.Timer.timers) do
		if v.id == id then
			ExiWoW.Timer.timers[k] = nil;
			return;
		end
	end
end

-- Fetches an id for the timer
function ExiWoW:getNewId()
	ExiWoW.Timer.id = ExiWoW.Timer.id+1;
	return ExiWoW.Timer.id;
end
