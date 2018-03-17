EroWoW.RPText.Lib = {}
local req = EroWoW.RPText.Req;


-- Fondle --
table.insert(EroWoW.RPText.LIB, EroWoW.RPText:new({
	id = "FONDLE",
	text = "",
	requirements = {
		req:new({
			type = RTYPE_HAS_BREASTS,
			sender = false,
			data = {},
			inverse = false
		})
	}
}))

