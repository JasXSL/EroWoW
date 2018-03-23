-- Library of common reusable assets
ExiWoW.LibAssets = {}
local req = ExiWoW.RPText.Req;	-- RPText requirement constructor
local ty = req.Types;			-- Local filter types

-- When used in rp texts, they need to be prefixed with SPELL_
function ExiWoW.LibAssets.spellKitToRP(...)
	local kits = {...}
	local out = {}
	for k,kit in pairs(kits) do
		local input = ExiWoW.LibAssets.spell_kits[kit];
		for i,v in pairs(input) do
			out[i] = true
		end
	end
	return out;
end


