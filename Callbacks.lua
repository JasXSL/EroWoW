-- Callback system
EroWoW.Callbacks = {};		
EroWoW.Callbacks.WAITING = {}; -- {id:str token, timer:int timer, callback:fn callback}
-- Adds a callback listener and returns the callback token
function EroWoW.Callbacks:add(fn)
	local token = string.gsub("xxxxxxxx", '[x]', function (c)
		local out = string.format('%x', math.random(0, 0xf))
		return out
	end)
	
	-- Give it 1 sec
	local timer = EroWoW.Timer:set(function()
		EroWoW.Callbacks:trigger(token, false);
	end, 1);
	
	table.insert(EroWoW.Callbacks.WAITING, {
		callback = fn,
		id = token,
		timer = timer
	});
	

	return token;
end

function EroWoW.Callbacks:remove(token)
	for k,v in pairs(EroWoW.Callbacks.WAITING) do
		if v.id == token then
			EroWoW.Timer:clear(v.timer);
			EroWoW.Callbacks.WAITING[k] = nil;
			return;
		end
	end
end

function EroWoW.Callbacks:trigger(token, success, args)
	for k,v in pairs(EroWoW.Callbacks.WAITING) do
		if v.id == token then
			if type(v.callback) == "function" then
				v:callback(success, args);
			end
			EroWoW.Callbacks:remove(token);
			return;
		end
	end
end