-- Callback system
ExiWoW.Callbacks = {};		
ExiWoW.Callbacks.WAITING = {}; -- {id:str token, timer:int timer, callback:fn callback}
-- Adds a callback listener and returns the callback token
function ExiWoW.Callbacks:add(fn)
	local token = ExiWoW.Callbacks:generateToken();
	
	-- Give it 1 sec
	local timer = ExiWoW.Timer:set(function()
		ExiWoW.Callbacks:trigger(token, false);
	end, 1);
	
	table.insert(ExiWoW.Callbacks.WAITING, {
		callback = fn,
		id = token,
		timer = timer
	});
	

	return token;
end

function ExiWoW.Callbacks:remove(token)
	for k,v in pairs(ExiWoW.Callbacks.WAITING) do
		if v.id == token then
			ExiWoW.Timer:clear(v.timer);
			ExiWoW.Callbacks.WAITING[k] = nil;
			return;
		end
	end
end

function ExiWoW.Callbacks:generateToken()
	local token = string.gsub("xxxxxx", '[x]', function (c)
		local out = string.format('%x', math.random(0, 0xf))
		return out
	end)
	return token;
end

function ExiWoW.Callbacks:trigger(token, success, args, sender)
	for k,v in pairs(ExiWoW.Callbacks.WAITING) do
		if v.id == token then
			if type(v.callback) == "function" then
				v:callback(success, args, sender);
			end
			ExiWoW.Callbacks:remove(token);
			return;
		end
	end
end