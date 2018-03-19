ExiWoW.Menu = {}
ExiWoW.Menu.open = false -- Set to false when done debugging. Setting to false by default will have it visible by default
ExiWoW.Menu.FRAME = false

-- Action page
local BUTTON_ROWS = 4;
local BUTTON_COLS = 8;
local BUTTON_MARG = 1.1;

function ExiWoW.Menu:toggle()

	ExiWoW.Menu.open = not ExiWoW.Menu.open


	if ExiWoW.Menu.open then
		ExiWoW.Menu.FRAME:Show();
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN );
	else
		ExiWoW.Menu.FRAME:Hide();
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE );
	end



end





-- Refresh spells --
function ExiWoW.Menu:refreshSpellsPage()

	local i = 0;
	for k,v in pairs(ExiWoW.Action.LIB) do

		-- Make sure it's acceptable
		if 
			v:validateFiltering("player", true) and
			not v.hidden and
			v.learned
		then

			local f = _G["ExiWoWActionButton_"..i]

			f:SetScript("OnMouseUp", function (self, button)
				if IsShiftKeyDown() then
					v.favorite = not v.favorite;
					ExiWoW.Action:libSort();
					ExiWoW.Menu:refreshSpellsPage()
				else
					ExiWoW.Action:useOnTarget(v.id, "target")
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
		local f = _G["ExiWoWActionButton_"..i]
		f:Hide();
	end

end





-- BUILD --
function ExiWoW.Menu:ini()

	--ExiWoWSettingsFrame:Hide()
	-- ExiWoWSettingsFrameTab1 -- First tab
	-- ExiWoWSettingsFrameTab2 -- Second tab
	local f = ExiWoWSettingsFrame;
	ExiWoW.Menu.FRAME = f;
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)

	PanelTemplates_SetNumTabs(f, 2);
	PanelTemplates_SetTab(f, 1);
	--ExiWoWSettingsFrame_page_settings:Show();
	--ExiWoWSettingsFrame_page_actions:Hide();

	if not ExiWoW.Menu.open then
		f:Hide();
	end

	-- Build actions page
	f = ExiWoWSettingsFrame_page_actions;
	for row=0,BUTTON_ROWS-1 do
		for col=0,BUTTON_COLS-1 do

			local ab = CreateFrame("Button", "ExiWoWActionButton_"..tostring(col+row*col), f, "ActionButtonTemplate");
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



	-- Build settings frame --
	f = ExiWoWSettingsFrame_page_settings;

	local psize = ExiWoW.ME:getPenisSize();
	local tsize = ExiWoW.ME:getBreastSize();
	local bsize = ExiWoW.ME:getButtSize();
	local vsize = ExiWoW.ME:getVaginaSize();
	
	if psize == false then psize = -1 end
	if tsize == false then tsize = -1 end
	if vsize == false then vsize = -1 end
	psize = psize+1;
	tsize = tsize+1;
	vsize = vsize+1;
	
	local top = -50;
	local spacing = -40;

	-- Masochism slider
	local item = 0
	local sl = CreateFrame("Slider", "ExiWoWSettingsFrame_page_settings_masochism", f, "OptionsSliderTemplate")
	sl:SetWidth(200)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, -50);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "Affects amount of excitement you gain from taking hits or masochistic actions and spells.";
	getglobal(sl:GetName()..'Low'):SetText('0');
	getglobal(sl:GetName()..'High'):SetText('100');
	getglobal(sl:GetName()..'Text'):SetText('Masochism');
	sl:SetMinMaxValues(0, 100)
	sl:SetValue(math.floor(ExiWoW.ME.masochism*100))
	sl:SetValueStep(1)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		ExiWoW.ME.masochism = arg1/100;
		ExiWoW.LS.masochism = ExiWoW.ME.masochism;
	end)

	-- Penis size slider
	item = item+1
	sl = CreateFrame("Slider", "ExiWoWSettingsFrame_page_settings_penis_size", f, "OptionsSliderTemplate")
	sl:SetWidth(200)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, top+spacing*item);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "How well endowed is your character?";
	getglobal(sl:GetName()..'Text'):SetText('Penis Size');
	getglobal(sl:GetName()..'Low'):SetText('Off');
	getglobal(sl:GetName()..'High'):SetText('Huge');
	sl:SetMinMaxValues(0, 5)
	sl:SetValueStep(1)
	sl:SetValue(psize)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.penis_size = arg1;
		ExiWoW.LS.penis_size = ExiWoW.ME.penis_size;
	end)

	-- Breast size slider
	item = item+1
	sl = CreateFrame("Slider", "ExiWoWSettingsFrame_page_settings_breast_size", f, "OptionsSliderTemplate")
	sl:SetWidth(200)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, top+spacing*item);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "How large are your breasts?";
	getglobal(sl:GetName()..'Text'):SetText('Breast Size');
	getglobal(sl:GetName()..'Low'):SetText('Off');
	getglobal(sl:GetName()..'High'):SetText('Huge');
	sl:SetMinMaxValues(0, 5)
	sl:SetValueStep(1)
	sl:SetValue(tsize)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.breast_size = arg1;
		ExiWoW.LS.breast_size = ExiWoW.ME.breast_size;
	end)

	-- Butt size
	item = item+1
	sl = CreateFrame("Slider", "ExiWoWSettingsFrame_page_settings_butt_size", f, "OptionsSliderTemplate")
	sl:SetWidth(200)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, top+spacing*item);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "How large is your butt?";
	getglobal(sl:GetName()..'Text'):SetText('Butt Size');
	getglobal(sl:GetName()..'Low'):SetText('Tiny');
	getglobal(sl:GetName()..'High'):SetText('Huge');
	sl:SetMinMaxValues(0, 4)
	sl:SetValueStep(1)
	sl:SetValue(bsize)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		ExiWoW.ME.butt_size = arg1;
		ExiWoW.LS.butt_size = ExiWoW.ME.butt_size;
	end)

	-- Toggle vagina
	item = item+1
	sl = CreateFrame("Slider", "ExiWoWSettingsFrame_page_settings_vagina_size", f, "OptionsSliderTemplate")
	sl:SetWidth(60)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, top+spacing*item);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "Vagina";
	getglobal(sl:GetName()..'Text'):SetText('Toggle character vagina');
	getglobal(sl:GetName()..'Low'):SetText('Off');
	getglobal(sl:GetName()..'High'):SetText('On');
	sl:SetMinMaxValues(0, 1)
	sl:SetValueStep(1)
	sl:SetValue(vsize)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.vagina_size = arg1;
		ExiWoW.LS.vagina_size = ExiWoW.ME.vagina_size;
	end)

	

	

	-- Bind events
	ExiWoWSettingsFrame_close:SetScript("OnMouseUp", function (self, button)
		ExiWoW.Menu:toggle();
	end)


	ExiWoWSettingsFrameTab1:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(ExiWoW.Menu.FRAME, 1);
		ExiWoWSettingsFrame_page_actions:Show();
		ExiWoWSettingsFrame_page_settings:Hide();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)

	ExiWoWSettingsFrameTab2:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(ExiWoW.Menu.FRAME, 2);
		ExiWoWSettingsFrame_page_settings:Show();
		ExiWoWSettingsFrame_page_actions:Hide();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)


end


