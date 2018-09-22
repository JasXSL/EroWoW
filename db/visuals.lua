-- NPC Libraries (Don't forget to make NPC Name conditions out of these)
local appName, internal = ...;
local require = internal.require;

-- Library for Conditions --
function internal.build.visuals()

	--local NPC = require("NPC");
	--local Database = require("Database");
	local ext = internal.ext;
	-- /dump ExiWoW.require("Visual").get("heavyPain"):trigger()
	ext:addVisual({
		id="heavyPain",
		image="red_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.75;
			if delta > duration then
				return true;
			end
			local alpha = (sin(GetTime()*1000)+1)/8+0.75;
			if self.hold then
				return alpha;
			end
			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration)*0.75;
		end
	});

	-- /dump ExiWoW.require("Visual").get("frost"):trigger()
	ext:addVisual({
		id="frost",
		image="frost_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.75;
			if delta > duration then
				return true;
			end
			if self.hold then return 1 end
			return min(1,max(0,ExiWoW.Easing.outInQuart(delta, 1, -1, duration)));
		end
	});
	-- /run ExiWoW.require("Visual").get("lightning"):trigger()
	ext:addVisual({
		id="lightning",
		image="lightning_border.tga",
		update = function(self)
			local delta = GetTime()-self.timeTriggered;
			local duration = 0.5;
			if delta > duration then
				return true;
			end

			local alpha = (sin(GetTime()*3000)+1)/8+0.75;
			if self.hold then
				return alpha;
			end
			return alpha*min(1,max(0,ExiWoW.Easing.outInBounce(delta, 1, -1, duration)))*(0.5+(duration-delta)/2);
		end
	});
	-- /run ExiWoW.require("Visual").get("heavyExcitement"):trigger()
	-- /run ExiWoW.require("Visual").get("heavyExcitement"):stop()
	ext:addVisual({
		id="heavyExcitement",
		image="cloudy_fade_border.tga",
		create = function(self)

			self.frame.bg:SetVertexColor(1,0.5,1);

			self.frame.hearts = {};
			local positions = {
				{pos="topleft", offset={100+random()*50,-100+random()*100}, scale=random()*0.5+0.5},
				{pos="bottomleft", offset={400+random()*50,300+random()*100}, scale=random()*0.5+0.5},
				{pos="bottomright", offset={-200-random()*50,300+random()*100}, scale=random()*0.5+0.5},
				{pos="topright", offset={-300+random()*150,-200+random()*200}, scale=random()*0.5+0.5},
			};

			for i=0,8 do
				table.insert(positions, {
					pos = "center",
					offset ={0,0},
					scale = 1
				});
			end

			for _,v in pairs(positions) do
				local h = CreateFrame("Frame", nil, self.frame);
				h:SetWidth(150*v.scale);
				h:SetHeight(300*v.scale);
				h:SetPoint(v.pos, v.offset[1], v.offset[2]);
				h.texture = h:CreateTexture(nil, "BACKGROUND");

				h.texture:SetTexture("Interface/AddOns/ExiWoW/media/borders/heart_anim.tga");
				h.texture:SetAllPoints(h);
				h.texture:SetBlendMode("ADD");
				table.insert(self.frame.hearts, h);
				AnimateTexCoords(h.texture, 1024, 256, 64, 128, 32, random(), 0.015);
			end

		end,
		start = function(self)
			for i,v in pairs(self.frame.hearts) do
				if i > 4 then
					v:SetPoint("center",
						random()*1600-800,
						random()*1000-500
					);
					local rand = (random()*0.25+0.25);
					v:SetWidth(150*rand);
					v:SetHeight(300*rand);
					v:SetAlpha(random()*0.75+0.25);
				end
			end
		end,
		update = function(self, elapsed)
			local delta = GetTime()-self.timeTriggered;
			local duration = 1;
			for _,v in pairs(self.frame.hearts) do
				AnimateTexCoords(v.texture, 1024, 256, 64, 128, 32, elapsed, 0.015);
			end

			local alpha = (sin(GetTime()*1000)+1)/4+0.25;
			if self.hold then
				return alpha;
			end

			if delta > duration then
				return true;
			end

			return alpha*ExiWoW.Easing.outQuad(delta, 1, -1, duration);

		end
	});

end