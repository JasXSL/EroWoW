local appName, internal = ...
local require = internal.require;

function internal.build.effects()

	local Func = require("Func");
	local ext = internal.ext;
	
	--
	ext:addEffect({
		id = "MORTAS_ARACHNID_SCEPTER",
		detrimental = true,
		duration = 15,
		ticking = 1,
		max_stacks = 1,
		texture = "Interface/Icons/trade_archaeology_nerubianspiderscepter",
		name = "Spider Hex",
		description = "You feel as if hundreds of little spiders are skittering across your body!",
		onAdd = function()
			Func.get("toggleVibHubProgram")("SMALL_TICKLE_RANDOM", 15);
			PlaySound(5694, "SFX");
			DoEmote("GIGGLE", "player");
		end,
		onRemove = function()
			Func.get("toggleVibHubProgram")("SMALL_TICKLE_RANDOM");
		end,
		onTick = function()
			ExiWoW.ME:addExcitement(0.025);
		end
	});


end