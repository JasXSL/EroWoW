EroWoW.Timer = {}
EroWoW.Timer.id = 0;		-- Increased whenever you set a timer
EroWoW.Timer.timers = {};	-- {id:int id, started:nr started, duration: nr duration, times:int nr, callback: fn callback}
EroWoW.Timer.time = 0;

function EroWoW.Timer.ini()

	local a = nil

	local f = CreateFrame("Frame",nil,UIParent);
	f:SetScript("OnUpdate", function(self, sinceLastUpdate)
		EroWoW.Timer.time = EroWoW.Timer.time+sinceLastUpdate;
		local t = EroWoW.Timer.time;

		for k,v in pairs(EroWoW.Timer.timers) do

			-- Timer timed out
			if v.started+v.duration <= t then

				local times = tonumber(v.times) - 1;
				local dur = v.duration;
				local callback = v.callback;

				if times < 1 then
					EroWoW.Timer.timers[k] = nil -- Remove timer
				else
					EroWoW.Timer.timers[k].times = times;
					EroWoW.Timer.timers[k].started = t;
				end

				if type(v.callback) == "function" then
					v:callback();
				end

			end

		end

	end);

end






-- Use math.huge for infinite times
function EroWoW.Timer:set(callback, seconds, times)

	local t = {
		id = EroWoW.getNewId(),
		started = EroWoW.Timer.time,
		duration = seconds or 1,
		times = times or 1,
		callback = callback
	};
	table.insert(EroWoW.Timer.timers, t);
	return t.id;

end

function EroWoW.Timer:clear(id)
	for k,v in pairs(EroWoW.Timer.timers) do
		if v.id == id then
			EroWoW.Timer.timers[k] = nil;
			return;
		end
	end
end

-- Fetches an id for the timer
function EroWoW:getNewId()
	EroWoW.Timer.id = EroWoW.Timer.id+1;
	return EroWoW.Timer.id;
end
