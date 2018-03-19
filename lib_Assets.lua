-- Library of common reusable assets
ExiWoW.LibAssets = {}
-- When used in rp texts, they need to be prefixed with SPELL_
function ExiWoW.LibAssets:spellKitToRP(...)
	local kits = {...}
	local out = {}
	for k,kit in pairs(kits) do
		local input = ExiWoW.LibAssets.spell_kits[kit];
		for i,v in pairs(input) do
			local tx = "SPELL_"..i;
			out[tx] = true
		end
	end
	return out;
end

print("Building spell kits")
-- Spell kits
ExiWoW.LibAssets.spell_kits = {}
local sk = ExiWoW.LibAssets.spell_kits;
	sk.ice = {}											-- Ice/Cold
	sk.ice_common = {}
	sk.electric = {};										-- Electric shocks
	sk.electric_common = {};
	sk.basilisk = {};										-- Basilisk stare stuns
	
	-- Ice
	sk.ice_common["Chilled"]=true;
	sk.ice["Frostbolt"]=true;
 
	-- Electric
	sk.electric_common["Lightning Shield"] = true
	sk.electric["Stormstrike"] = true
	sk.electric["Lightning Bolt"] = true
	sk.electric["Chain Lightning"] = true
	
	
	

	-- Basilisk freeze
	sk.basilisk["Crystal Gaze"] = true
	sk.basilisk["Petrifying Blast"] = true
	
	

