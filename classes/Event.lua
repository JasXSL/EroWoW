local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Event = {}
	Event.index = 0
	Event.bindings = {}		-- {id={event:(str)event, callback:(str)callback}...}

	Event.Types = {
		LOADED = "LOADED",									-- ExiWoW loaded
		EXADD = "EXADD",									-- {amount=amount, set=set, multiplyMasochism=multiplyMasochism} Excitement has been added or subtracted
		EXADD_DEFAULT = "EXADD_DEFAULT",					-- {vh=triggerVhProgram} Excitement add default
		EXADD_CRIT = "EXADD_CRIT",							-- {vh=triggerVhProgram} Excitement add crit
		EXADD_M_DEFAULT = "EXADD_M_DEFAULT",				-- {vh=triggerVhProgram} Excitement add masochistic default
		EXADD_M_CRIT = "EXADD_M_CRIT",						-- {vh=triggerVhProgram} Excitement add masochistic crit
		
		INVADD = "INVADD",									-- {type=type, name=name, quant=quant} - Inventory has been added
		
		ACTION_USED = "ACTION_USED",						-- {id=actionID, target=target, args=args, success=success} -- Target responded
		ACTION_INTERRUPTED = "ACTION_INTERRUPTED",			-- {id=actionID, target=target}
		ACTION_SENT = "ACTION_SENT",						-- {id=id, target=target} - Action sent to target

		ACTION_UNDERWEAR_EQUIP = "ACTION_UNDERWEAR_EQUIP",			-- {id=id}
		ACTION_UNDERWEAR_UNEQUIP = "ACTION_UNDERWEAR_UNEQUIP",		-- {id=id}
		ACTION_SETTING_CHANGE = "ACTION_SETTING_CHANGE",			-- void

	}


	function Event.on(event, callback)
		if type(callback) ~= "function" then print("Callback in event binding is not a function, got", type(callback)); return false end
		if not Event.Types[event] then print("Event not found", event); return false end
		Event.index = Event.index + 1;
		Event.bindings[Event.index] = {event=event, callback=callback}
		return Event.index
	end

	function Event.off(id)
		Event.bindings[id] = nil
	end

	function Event.raise(evt, data)
		for _,v in pairs(Event.bindings) do
			if v.event == evt then
				v.callback(data)
			end
		end
	end


export(
	"Event", 
	Event,
	{
		on = Event.on,
		off = Event.off,
		Types = Event.Types
	},
	{
		raise = Event.raise
	}
)
