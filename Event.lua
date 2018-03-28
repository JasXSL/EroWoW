ExiWoW.Event = {}
ExiWoW.Event.index = 0
ExiWoW.Event.bindings = {}		-- {id={event:(str)event, callback:(str)callback}...}

ExiWoW.Event.Types = {
	LOADED = "LOADED",									-- ExiWoW loaded
	EXADD = "EXADD",									-- {amount=amount, set=set, multiplyMasochism=multiplyMasochism} Excitement has been added or subtracted
	EXADD_DEFAULT = "EXADD_DEFAULT",					-- Excitement add default
	EXADD_CRIT = "EXADD_CRIT",							-- Excitement add crit
	EXADD_M_DEFAULT = "EXADD_M_DEFAULT",				-- Excitement add masochistic default
	EXADD_M_CRIT = "EXADD_M_CRIT",						-- Excitement add masochistic crit
	
	INVADD = "INVADD",									-- {type=type, name=name, quant=quant} - Inventory has been added
	
	ACTION_USED = "ACTION_USED",						-- {id=actionID, target=target, args=args, success=success} -- Target responded
	ACTION_INTERRUPTED = "ACTION_INTERRUPTED",			-- {id=actionID, target=target}
	ACTION_SENT = "ACTION_SENT",						-- {id=id, target=target} - Action sent to target

	ACTION_UNDERWEAR_EQUIP = "ACTION_UNDERWEAR_EQUIP",			-- {id=id}
	ACTION_UNDERWEAR_UNEQUIP = "ACTION_UNDERWEAR_UNEQUIP",		-- {id=id}
	ACTION_SETTING_CHANGE = "ACTION_SETTING_CHANGE",			-- void

}


function ExiWoW.Event:on(event, callback)
	if type(callback) ~= "function" then print("Callback in event binding is not a function, got", type(callback)); return false end
	if not ExiWoW.Event.Types[event] then print("Event not found", event); return false end
	ExiWoW.Event.index = ExiWoW.Event.index + 1;
	ExiWoW.Event.bindings[ExiWoW.Event.index] = {event=event, callback=callback}
	return ExiWoW.Event.index
end

function ExiWoW.Event:off(id)
	ExiWoW.Event.bindings[id] = nil
end

function ExiWoW.Event:raise(evt, data)
	for _,v in pairs(ExiWoW.Event.bindings) do
		if v.event == evt then
			v.callback(data)
		end
	end
end


