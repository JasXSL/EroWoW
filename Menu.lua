EroWoW.Menu = {}
EroWoW.Menu.open = false -- Set to false when done debugging. Setting to false by default will have it visible by default
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
	--EroWoWSettingsFrame_page_settings:Show();
	--EroWoWSettingsFrame_page_actions:Hide();

	if not EroWoW.Menu.open then
		f:Hide();
	end

	-- Build actions page
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



	-- Build settings frame --
	f = EroWoWSettingsFrame_page_settings;

	local psize = EroWoW.ME:getPenisSize();
	local tsize = EroWoW.ME:getBreastSize();
	local bsize = EroWoW.ME:getButtSize();
	local vsize = EroWoW.ME:getVaginaSize();
	
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
	local sl = CreateFrame("Slider", "EroWoWSettingsFrame_page_settings_masochism", f, "OptionsSliderTemplate")
	sl:SetWidth(200)
	sl:SetHeight(20)
	sl:SetPoint("TOP", 0, -50);
	sl:SetOrientation('HORIZONTAL')
	sl.tooltipText = "Affects amount of arousal you gain from taking hits or masochistic actions and spells.";
	getglobal(sl:GetName()..'Low'):SetText('0');
	getglobal(sl:GetName()..'High'):SetText('100');
	getglobal(sl:GetName()..'Text'):SetText('Masochism');
	sl:SetMinMaxValues(0, 100)
	sl:SetValue(math.floor(EroWoW.ME.masochism*100))
	sl:SetValueStep(1)
	sl:SetObeyStepOnDrag(true)
	sl:Show();
	sl:SetScript("OnValueChanged", function(self,arg1) 
		EroWoW.ME.masochism = arg1/100;
		EroWoW.LS.masochism = EroWoW.ME.masochism;
	end)

	-- Penis size slider
	item = item+1
	sl = CreateFrame("Slider", "EroWoWSettingsFrame_page_settings_penis_size", f, "OptionsSliderTemplate")
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
		EroWoW.ME.penis_size = arg1;
		EroWoW.LS.penis_size = EroWoW.ME.penis_size;
	end)

	-- Breast size slider
	item = item+1
	sl = CreateFrame("Slider", "EroWoWSettingsFrame_page_settings_breast_size", f, "OptionsSliderTemplate")
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
		EroWoW.ME.breast_size = arg1;
		EroWoW.LS.breast_size = EroWoW.ME.breast_size;
	end)

	-- Butt size
	item = item+1
	sl = CreateFrame("Slider", "EroWoWSettingsFrame_page_settings_butt_size", f, "OptionsSliderTemplate")
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
		EroWoW.ME.butt_size = arg1;
		EroWoW.LS.butt_size = EroWoW.ME.butt_size;
	end)

	-- Toggle vagina
	item = item+1
	sl = CreateFrame("Slider", "EroWoWSettingsFrame_page_settings_vagina_size", f, "OptionsSliderTemplate")
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
		EroWoW.ME.vagina_size = arg1;
		EroWoW.LS.vagina_size = EroWoW.ME.vagina_size;
	end)

	

	

	-- Bind events
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


