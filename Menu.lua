EroWoW.Menu = {}
EroWoW.Menu.open = true -- Set to false when done debugging. Setting to false by default will have it visible by default
EroWoW.Menu.FRAME = false

-- Action page
local BUTTON_ROWS = 4;
local BUTTON_COLS = 8;
local BUTTON_MARG = 1.1;

function EroWoW.Menu:toggle()

	EroWoW.Menu.open = not EroWoW.Menu.open


	if EroWoW.Menu.open then
		EroWoW.Menu.FRAME:Show();
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN );
	else
		EroWoW.Menu.FRAME:Hide();
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE );
	end



end





-- Refresh spells --
function EroWoW.Menu:refreshSpellsPage()

	local i = 0;
	for k,v in pairs(EroWoW.Action.LIB) do

		-- Make sure it's acceptable
		if 
			v:validateFiltering("player", true) and
			not v.hidden and
			v.learned
		then

			local f = _G["EroWoWActionButton_"..i]

			f:SetScript("OnMouseUp", function (self, button)
				if IsShiftKeyDown() then
					v.favorite = not v.favorite;
					EroWoW.Action:libSort();
					EroWoW.Menu:refreshSpellsPage()
				else
					EroWoW.Action:useOnTarget(v.id, "target")
				end
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
			end)

			f.icon:SetTexture("Interface/Icons/"..v.texture);
			--ab.cooldown = CreateFrame("Cooldown", nil, ab, "CooldownFrameTemplate");

			local started, duration = v:getCooldown();
			f.cooldown:SetCooldown(started, duration);

			if v.favorite then 
				f.star:Show();
			else
				f.star:Hide();
			end
			-- Generate tooltip
			f:SetScript("OnEnter", function(self)
				v:onTooltip(self);
			end);
			f:SetScript("Onleave", function() 
				v:onTooltip();
			end);

			f:Show();
			i = i+1;

		end

	end

	for n=i,BUTTON_ROWS*BUTTON_COLS-1 do
		local f = _G["EroWoWActionButton_"..i]
		f:Hide();
	end

end





-- BUILD --
function EroWoW.Menu:ini()

	--EroWoWSettingsFrame:Hide()
	-- EroWoWSettingsFrameTab1 -- First tab
	-- EroWoWSettingsFrameTab2 -- Second tab
	local f = EroWoWSettingsFrame;
	EroWoW.Menu.FRAME = f;
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)

	PanelTemplates_SetNumTabs(f, 2);
    PanelTemplates_SetTab(f, 1);

	if not EroWoW.Menu.open then
		f:Hide();
	end

	f = EroWoWSettingsFrame_page_actions;
	for row=0,BUTTON_ROWS-1 do
		for col=0,BUTTON_COLS-1 do

			local ab = CreateFrame("Button", "EroWoWActionButton_"..tostring(col+row*col), f, "ActionButtonTemplate");
			ab:SetAttribute("type", "action");
			ab:SetAttribute("action", 1);
			ab:SetPoint("TOPLEFT", 23+col*50*BUTTON_MARG, -50-row*50*BUTTON_MARG);
			ab:SetSize(50,50);
			ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)
			ab:Hide();

			local s = CreateFrame("Frame", nil, ab);
			ab.star = s;
			s:SetPoint("TOPLEFT", -5,5);
			s:SetSize(16,16);
			local tx = s:CreateTexture(nil, "OVERLAY");
			tx:SetTexture("Interface/COMMON/ReputationStar");
			tx:SetTexCoord(0,0.5,0,0.5)
			tx:SetAllPoints();
			s:Hide();

		end
	end

	EroWoWSettingsFrame_close:SetScript("OnMouseUp", function (self, button)
		EroWoW.Menu:toggle();
	end)


	EroWoWSettingsFrameTab1:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(EroWoW.Menu.FRAME, 1);
		EroWoWSettingsFrame_page_actions:Show();
		EroWoWSettingsFrame_page_settings:Hide();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)

	EroWoWSettingsFrameTab2:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(EroWoW.Menu.FRAME, 2);
		EroWoWSettingsFrame_page_settings:Show();
		EroWoWSettingsFrame_page_actions:Hide();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)


end


