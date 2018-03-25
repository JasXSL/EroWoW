ExiWoW.Event = {}
ExiWoW.Event.index = 0
ExiWoW.Event.bindings = {}		-- {id={event:(str)event, callback:(str)callback}...}

ExiWoW.Event.Types = {
	EXADD = "EXADD",									-- Excitement has been added (float)val
	EXADD_DEFAULT = "EXADD_DEFAULT",					-- Excitement add default
	EXADD_CRIT = "EXADD_CRIT",							-- Excitement add crit
	EXADD_M_DEFAULT = "EXADD_M_DEFAULT",				-- Excitement add masochistic default
	EXADD_M_CRIT = "EXADD_M_CRIT",						-- Excitement add masochistic crit
	
	INVADD = "INVADD",									-- type, id, quant - Inventory has been added
	
	ACTION_CAST = "ACTION_USED",						-- Todo
	ACTION_FAIL = "ACTION_FAIL",
	ACTION_SUCCESS = "ACTION_SUCCESS",
	ACTION_SENT = "ACTION_SENT",

	ACTION_UNDERWEAR_EQUIP = "ACTION_UNDERWEAR_EQUIP",			-- Character underwear equipped
	ACTION_UNDERWEAR_UNEQUIP = "ACTION_UNDERWEAR_UNEQUIP",		-- Character underwear unequipped
	ACTION_SETTING_CHANGE = "ACTION_SETTING_CHANGE",			-- Character settings have been changed

}


function ExiWoW.Event:on(event, callback)
	if type(callback) ~= "function" then print("Callback in event binding is not a function, got", type(callback)); return false end
	if not ExiWoW.Event.Types[event] then print("Event not found", event); return false end
	
	ExiWoW.Event.index = ExiWoW.Event.index + 1;
	ExiWoW.Event.bindings[index] = {event=event, callback=callback}
	return ExiWoW.Event.index
end

function ExiWoW.Event:off(id)
	ExiWoW.Event.bindings[id] = nil
end

function ExiWoW.Event:raise(evt, data)
	for _,v in ExiWoW.Event.bindings do
		v.callback(data)
	end
end


