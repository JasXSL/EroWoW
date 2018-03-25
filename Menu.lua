local appName, internal = ...

ExiWoW.Menu = {}
ExiWoW.Menu.open = false -- Set to false when done debugging. Setting to false by default will have it visible by default
ExiWoW.Menu.FRAME = false
ExiWoW.Menu.globalSettings = nil
ExiWoW.Menu.lootQueue = {}		-- {{name=name, icon=icon}}

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

			local name = _G["ExiWoWActionButton_"..i.."Name"];
			if v.charges and v.charges ~= math.huge then
				name:SetText(v.charges)
			else
				name:SetText("")
			end

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
		local f = _G["ExiWoWActionButton_"..n]
		f:Hide();
	end

end


-- Refresh Underwear --
function ExiWoW.Menu:refreshUnderwearPage()

	local i = 0;
	local unlocked = ExiWoW.ME.underwear_ids
	table.sort(unlocked, function(a, b)
		if a.fav and not b.fav then return true
		elseif not a.fav and b.fav then return false
		end

		local obja = ExiWoW.Underwear:get(a.id)
		local objb = ExiWoW.Underwear:get(b.id)
		return obja.name < objb.name;
	end)

	for k,v in pairs(unlocked) do

		local item = v.id
		local fav = v.fav
		local obj = ExiWoW.Underwear:get(item)
		-- Make sure it's acceptable
		if obj then

			local f = _G["ExiWoWUnderwearButton_"..i]

			f:SetScript("OnMouseUp", function (self, button)
				if IsShiftKeyDown() then
					v.fav = not v.fav;
					ExiWoW.Menu:refreshUnderwearPage()
				else
					ExiWoW.ME:useUnderwear(item)
				end
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
			end)

			f.icon:SetTexture("Interface/Icons/"..obj.icon);

			if fav then 
				f.star:Show();
			else
				f.star:Hide();
			end

			if item == ExiWoW.ME.underwear_worn then
				f:LockHighlight()
			else
				f:UnlockHighlight()
			end

			-- Generate tooltip
			f:SetScript("OnEnter", function(frame)
				obj:onTooltip(frame);
			end);
			f:SetScript("Onleave", function() 
				obj:onTooltip();
			end);

			f:Show();
			i = i+1;

		end

	end

	for n=i,BUTTON_ROWS*BUTTON_COLS-1 do
		local f = _G["ExiWoWUnderwearButton_"..n]
		f:Hide();
	end

end


function ExiWoW.Menu:hideAllTabs()
	ExiWoWSettingsFrame_page_settings:Hide();
	ExiWoWSettingsFrame_page_actions:Hide();
	ExiWoWSettingsFrame_page_underwear:Hide();	
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

	PanelTemplates_SetNumTabs(f, 3);
	PanelTemplates_SetTab(f, 1);
	ExiWoW.Menu:toggle()
	--ExiWoWSettingsFrame_page_settings:Show();
	--ExiWoWSettingsFrame_page_actions:Hide();

	if not ExiWoW.Menu.open then
		f:Hide();
	end

	-- Build actions page
	f = ExiWoWSettingsFrame_page_actions;
	for row=0,BUTTON_ROWS-1 do
		for col=0,BUTTON_COLS-1 do

			local ab = CreateFrame("Button", "ExiWoWActionButton_"..tostring(col+row*BUTTON_COLS), f, "ActionButtonTemplate");
			ab:SetAttribute("type", "action");
			ab:SetAttribute("action", 1);
			ab:SetPoint("TOPLEFT", 23+col*50*BUTTON_MARG, -50-row*50*BUTTON_MARG);
			ab:SetSize(50,50);
			ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)
			ab:Hide();

			ab.Name:SetPoint("TOPRIGHT", 8,-30)
			ab.Name:SetFontObject("GameFontHighlight");

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


	-- Build underwear page
	f = ExiWoWSettingsFrame_page_underwear;
	for row=0,BUTTON_ROWS-1 do
		for col=0,BUTTON_COLS-1 do

			local ab = CreateFrame("Button", "ExiWoWUnderwearButton_"..tostring(col+row*BUTTON_COLS), f, "ActionButtonTemplate");
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

		
	local top = -50;
	local spacing = -40;
	local left = 30

	local function createSlider(id, parent, point, x,y, low, high, label, min,max, step, tooltip, callback, width, height)
		
		if not width then width = 200 end
		if not height then height = 20 end
		local sl = CreateFrame("Slider", id, parent, "OptionsSliderTemplate")
		sl:SetWidth(width)
		sl:SetHeight(height)
		sl:SetPoint(point, x, y);
		sl:SetOrientation('HORIZONTAL')
		sl.tooltipText = tooltip;
		getglobal(sl:GetName()..'Low'):SetText(low);
		getglobal(sl:GetName()..'High'):SetText(high);
		getglobal(sl:GetName()..'Text'):SetText(label);
		sl.baseText = label
		sl:SetMinMaxValues(min, max)
		sl:SetValueStep(step)
		sl:SetObeyStepOnDrag(true)
		sl:Show();
		sl:SetScript("OnValueChanged", callback)

	end

	local function setValueInTitle(self, val)
		getglobal(self:GetName().."Text"):SetText(self.baseText..val);
	end

	-- Masochism slider
	local item = 0
	createSlider("ExiWoWSettingsFrame_page_settings_masochism", f, "TOPLEFT", left, -50, "0", "100", "Masochism", 0, 100, 1, "Affects amount of excitement you gain from taking hits or masochistic actions and spells.", 
	function(self,arg1) 
		ExiWoW.ME.masochism = arg1/100;
		ExiWoWLocalStorage.masochism = ExiWoW.ME.masochism;
	end);

	-- Penis size slider
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_penis_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Male Endowment", 0, 5, 1, "How well endowed is your character?", 
	function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.penis_size = arg1;
		ExiWoWLocalStorage.penis_size = ExiWoW.ME.penis_size;
	end);

	-- Breast size slider
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_breast_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Female Endowment", 0, 5, 1, "How large are your character's breasts?", 
	function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.breast_size = arg1;
		ExiWoWLocalStorage.breast_size = ExiWoW.ME.breast_size;
	end);


	-- Butt size
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_butt_size", f, "TOPLEFT", left, top+spacing*item, "Tiny", "Huge", "Rear Size", 0, 4, 1, "How much junk in the trunk?", 
	function(self,arg1) 
		ExiWoW.ME.butt_size = arg1;
		ExiWoWLocalStorage.butt_size = ExiWoW.ME.butt_size;
	end);

	-- Toggle vagina
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_vagina_size", f, "TOPLEFT", left+40, top+spacing*item, "Off", "On", "Female Genitalia", 0, 1, 1, "Does your character have female genitalia?", 
	function(self,arg1) 
		arg1 = arg1-1;
		if arg1 == -1 then arg1 = false end
		ExiWoW.ME.vagina_size = arg1;
		ExiWoWLocalStorage.vagina_size = ExiWoW.ME.vagina_size;
	end, 60);

	-- Tank mode
	item = item+1
	local checkbutton = CreateFrame("CheckButton",  "ExiWoWSettingsFrame_page_settings_tank_mode", f, "ChatConfigCheckButtonTemplate");
	checkbutton.tooltip = "Adds a small chance of crit texts to trigger from normal hits. Useful on tanks since they can't be critically hit.";
	checkbutton:SetPoint("TOPLEFT", left, top+spacing*item);
	getglobal(checkbutton:GetName() .. 'Text'):SetText("Tank Mode");
	checkbutton:SetScript("OnClick", function(self)
		ExiWoWLocalStorage.tank_mode = self:GetChecked();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end)


	-- Right side
	item = 0
	createSlider("ExiWoWSettingsFrame_page_settings_muscle_tone", f, "TOPRIGHT", -left, top+spacing*item, "Scrawny", "Bodybuilder", "Muscle Tone", 0, 10, 1, "How muscular are you compared to your race/class average?", 
	function(self, arg1)
		ExiWoW.ME.muscle_tone = arg1;
		ExiWoWLocalStorage.muscle_tone = ExiWoW.ME.muscle_tone;
	end)
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_fat", f, "TOPRIGHT", -left, top+spacing*item, "Emaciated", "Obese", "Body Fat", 0, 10, 1, "How fat are you compared to your race/class average?", 
	function(self, arg1)
		ExiWoW.ME.fat = arg1;
		ExiWoWLocalStorage.fat = ExiWoW.ME.fat;
	end)
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_intelligence", f, "TOPRIGHT", -left, top+spacing*item, "Dumb", "Scholarly", "Intelligence", 0, 10, 1, "How smart are you compared to your race/class average when it comes to solving problems?", 
	function(self, arg1)
		ExiWoW.ME.intelligence = arg1;
		ExiWoWLocalStorage.intelligence = ExiWoW.ME.intelligence;
	end)
	item = item+1
	createSlider("ExiWoWSettingsFrame_page_settings_wisdom", f, "TOPRIGHT", -left, top+spacing*item, "Gullible", "Astute", "Wisdom", 0, 10, 1, "What social skills does your character possess?", 
	function(self, arg1)
		ExiWoW.ME.wisdom = arg1;
		ExiWoWLocalStorage.wisdom = ExiWoW.ME.wisdom;
	end)
	
	
	
	
	ExiWoW.Menu.drawLocalSettings();
	

	-- Bind events
	ExiWoWSettingsFrame_close:SetScript("OnMouseUp", function (self, button)
		ExiWoW.Menu:toggle();
	end)


	ExiWoWSettingsFrameTab1:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(ExiWoW.Menu.FRAME, 1);
		ExiWoW.Menu:hideAllTabs();
		ExiWoWSettingsFrame_page_actions:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)

	ExiWoWSettingsFrameTab2:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(ExiWoW.Menu.FRAME, 2);
		ExiWoW.Menu:hideAllTabs();
		ExiWoWSettingsFrame_page_underwear:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)
	ExiWoWSettingsFrameTab3:SetScript("OnMouseUp", function (self, button)
		PanelTemplates_SetTab(ExiWoW.Menu.FRAME, 3);
		ExiWoW.Menu:hideAllTabs();
		ExiWoWSettingsFrame_page_settings:Show();
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	end)





	-- Global settings
	local panel = CreateFrame("Frame", appName.."_globalConf", UIParent)
	ExiWoW.Menu.globalSettings = panel
	panel.name = "ExiWoW"
	InterfaceOptions_AddCategory(panel)

	local gPadding = 30;
	local gBottom = 40;

	-- Create the buttons
	local function createCheckbutton(suffix, parent, attach, x_loc, y_loc, displayname, tooltip)
		local checkbutton = CreateFrame("CheckButton", appName .. "_globalConf_"..suffix, parent, "ChatConfigCheckButtonTemplate");
		checkbutton.tooltip = tooltip;
		checkbutton:SetPoint(attach, x_loc, y_loc);
		getglobal(checkbutton:GetName() .. 'Text'):SetText(displayname);
		return checkbutton;
	end

	local n = 0;
	createCheckbutton("enable_in_dungeons", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable in Dungeons", "Some actions may still be disabled in dungeons due to API restrictions");
	n = n+1;
	createCheckbutton("enable_public", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Public", "Allows ANYONE to use actions on you.\n(Some functionality may still be restricted by the API)");

	local prefix = appName.."_globalConf_";
	n = 0
	createSlider(prefix.."takehit_rp_rate", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "1", "60", "Hit Text Limit", 1, 60, 1, "Sets minimum time in seconds between RP texts received from being affected by an attack or spell.", function(self, val)
		setValueInTitle(self, " ("..val..")");
	end);
	n = n+1
	createSlider(prefix.."spell_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "400%", "Spell RP Text Chance", 0, 4, 0.1, "Sets the chance of a viable spell triggering an RP text.\nThis is multiplied by the spell's internal chance, so even at 100% it's not a guarantee. Default = 100%", function(self, val)
		setValueInTitle(self, " ("..math.floor(val*100).."%)");
	end);
	n = n+1
	createSlider(prefix.."swing_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "100%", "Melee Text Chance", 0, 1, 0.05, "Chance of a text triggering on a melee hit. Crits are 4x this value. Default = 15%", function(self, val)
		setValueInTitle(self, " ("..math.floor(val*100).."%)");
	end);
	
			

	ExiWoW.Menu.drawGlobalSettings();

	panel.okay = function (self) 

		local gs = ExiWoWGlobalStorage;
		local prefix = appName.."_globalConf_";
		gs.takehit_rp_rate = getglobal(prefix.."takehit_rp_rate"):GetValue();
		gs.spell_text_freq = getglobal(prefix.."spell_text_freq"):GetValue();
		gs.swing_text_freq = getglobal(prefix.."swing_text_freq"):GetValue();
		
		gs.enable_in_dungeons = getglobal(prefix.."enable_in_dungeons"):GetChecked();
		gs.enable_public = getglobal(prefix.."enable_public"):GetChecked();

	end;
    panel.cancel = function (self)  ExiWoW.Menu.drawGlobalSettings(); end;
end


hooksecurefunc(LootAlertSystem,"ShowAlert",function()
	
	if #ExiWoW.Menu.lootQueue == 0 then return end
	local lootAlertPool = LootAlertSystem.alertFramePool
	for alertFrame in lootAlertPool:EnumerateActive() do
		if alertFrame.ItemName:GetText() == "Weapon Enhancement Token" then
			local item = ExiWoW.Menu.lootQueue[1]
			local name = item.name
			local icon = item.icon
			--DisplayTableInspectorWindow(alertFrame)
			alertFrame.ItemName:SetText(name)
			alertFrame.hyperlink = ""
			alertFrame:SetScript("OnEnter", function(frame)	end);
			alertFrame:SetScript("Onleave", function() end);
			alertFrame.Icon:SetTexture("Interface/Icons/"..icon);
			table.remove(ExiWoW.Menu.lootQueue, 1)
		end
	end	
end)

function ExiWoW.Menu:drawLoot(name, icon)
	table.insert(ExiWoW.Menu.lootQueue, {name=name, icon=icon})
	PlaySound(50893, "Dialog")
	LootAlertSystem.AddAlert(LootAlertSystem, "|cff1eff00|Hitem:120302::::::::110:::::|h[Weapon Enhancement Token]|h|r", 1, 0, 0, 0, false, false, nil, false, false, true, false);
end

function ExiWoW.Menu.drawLocalSettings()

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

	local me = ExiWoW.ME;
	ExiWoWSettingsFrame_page_settings_masochism:SetValue(math.floor(me.masochism*100));
	ExiWoWSettingsFrame_page_settings_penis_size:SetValue(psize)
	ExiWoWSettingsFrame_page_settings_breast_size:SetValue(tsize)
	ExiWoWSettingsFrame_page_settings_butt_size:SetValue(bsize);
	ExiWoWSettingsFrame_page_settings_vagina_size:SetValue(vsize);
	ExiWoWSettingsFrame_page_settings_fat:SetValue(ExiWoW.ME.fat);
	ExiWoWSettingsFrame_page_settings_muscle_tone:SetValue(ExiWoW.ME.muscle_tone);
	ExiWoWSettingsFrame_page_settings_intelligence:SetValue(ExiWoW.ME.intelligence);
	ExiWoWSettingsFrame_page_settings_wisdom:SetValue(ExiWoW.ME.wisdom);
	
	
	ExiWoWSettingsFrame_page_settings_tank_mode:SetChecked(ExiWoWLocalStorage.tank_mode);

	
end


function ExiWoW.Menu.drawGlobalSettings()

	local panel = ExiWoW.Menu.globalSettings
	local gs = ExiWoWGlobalStorage;
	
	
	local prefix = appName.."_globalConf_";
	getglobal(prefix.."takehit_rp_rate"):SetValue(gs.takehit_rp_rate);
	getglobal(prefix.."spell_text_freq"):SetValue(gs.spell_text_freq);
	getglobal(prefix.."swing_text_freq"):SetValue(gs.swing_text_freq);
	
	getglobal(prefix.."enable_in_dungeons"):SetChecked(gs.enable_in_dungeons);
	getglobal(prefix.."enable_public"):SetChecked(gs.enable_public);
	
	

	

end
