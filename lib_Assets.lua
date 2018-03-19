-- Library of common reusable assets
EroWoW.LibAssets = {}
-- When used in rp texts, they need to be prefixed with SPELL_
function EroWoW.LibAssets:spellKitToRP(...)
	local kits = {...}
	local out = {}
	for k,kit in pairs(kits) do
		local input = EroWoW.LibAssets.spell_kits[kit];
		for i,v in pairs(input) do
			local tx = "SPELL_"..i;
			out[tx] = true
		end
	end
	return out;
end

print("Building spell kits")
-- Spell kits
EroWoW.LibAssets.spell_kits = {}
local sk = EroWoW.LibAssets.spell_kits;
	sk.ice = {}											-- Ice/Cold
	sk.electric = {};										-- Electric shocks
	sk.electric_common = {};
	sk.basilisk = {};										-- Basilisk stare stuns
	
	-- Ice
	sk.ice["Chilled"]=true;
	sk.ice["Frostbolt"]=true;
 
	-- Electric
	sk.electric_common["Lightning Shield"] = true
	sk.electric["Stormstrike"] = true
	sk.electric["Lightning Bolt"] = true
	
	
	

	-- Basilisk freeze
	sk.basilisk["Crystal Gaze"] = true
	
	

