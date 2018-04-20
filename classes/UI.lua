local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

local Action, Underwear, Database, Event, Timer;

UI = {}
	UI.FRAME = false 					-- Page browser for ExiWoW
	UI.open = true 					-- Set to false when done debugging. Setting to false by default will have it visible by default
	UI.lootQueue = {}					-- {{name=name, icon=icon}} - Queue of loot to show when the loot toast pops up


	function UI.ini()

		Action = require("Action");
		Underwear = require("Underwear");
		Database = require("Database");
		Event = require("Event");
		Timer = require("Timer");

	end


	-- Local helper functions
	local function onSettingsChange()
		Event.raise(ACTION_SETTING_CHANGE)
	end

	-- Helpful internal build function
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
		sl:SetScript("OnValueChanged", function(...)
			onSettingsChange()
			callback(...);
		end)

	end

	local function setValueInTitle(self, val)
		getglobal(self:GetName().."Text"):SetText(self.baseText..val);
	end

	function UI.build()
		local f = ExiWoWSettingsFrame;
		UI.FRAME = f;
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", f.StartMoving)
		f:SetScript("OnDragStop", f.StopMovingOrSizing)

		PanelTemplates_SetNumTabs(f, 3);
		PanelTemplates_SetTab(f, 1);
		--ExiWoWSettingsFrame_page_settings:Show();
		--ExiWoWSettingsFrame_page_actions:Hide();

		if not UI.open then
			f:Hide();
		end

		UI.portrait.build();

		-- Build actions page
		UI.actionPage.build();
		-- Build underwear page
		UI.underwearPage.build();


		-- Build settings frame --
		UI.localSettings.build();
		-- Global settings
		UI.globalSettings.build();
		

		hooksecurefunc(LootAlertSystem,"setUpFunction",function()
	
			if #UI.lootQueue == 0 then return end
		
			local scans = {}
			scans["Fanged Green Glaive"] = true
			scans["Large Fang"] = true
			scans["Weapon Enhancement Token"] = true
			scans["Gloves of the Fang"] = true
			scans["Fang of the Pit"] = true
			scans["Golad, Twilight of Aspects"] = true
		
			local lootAlertPool = LootAlertSystem.alertFramePool
			for alertFrame in lootAlertPool:EnumerateActive() do
		
				if scans[alertFrame.ItemName:GetText()] then
					local item = UI.lootQueue[1]
					local name = item.name
					local icon = item.icon
					--DisplayTableInspectorWindow(alertFrame)
					alertFrame.ItemName:SetText(name)
					alertFrame.hyperlink = ""
					alertFrame:SetScript("OnEnter", function(frame)	end);
					alertFrame:SetScript("Onleave", function() end);
					alertFrame.Icon:SetTexture("Interface/Icons/"..icon);
					table.remove(UI.lootQueue, 1)
					if #UI.lootQueue == 0 then return end
				end
			end
			
		
		end)
	end


	-- Main UI functions
	function UI.toggle()
		UI.open = not UI.open
		if UI.open then
			UI.FRAME:Show();
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN );
		else
			UI.FRAME:Hide();
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE );
		end
	end


	-- Creates a macro
	function UI.createMacro(id)
		local action = Action.get(id)
		if not action then return false end
	
		local sub = id:sub(1, 16)
		local found = GetMacroIndexByName(sub);
		if found == 0 then
			local index = CreateMacro(sub, action.texture, "/ewact "..id)
			if not index then 
				print("Unable to create macro, make sure you have empty generic macro slots");
				return false;
			else 
				PickupMacro(index)
			end
		else
			PickupMacro(found)
		end
	end

	-- Refresh all--
	function UI.refreshAll()
		require("Action"):sort();
		UI.actionPage.update();
		UI.underwearPage.update();
		UI.localSettings.update();
		UI.globalSettings.update();
	end

	-- Deactivates all tabs
	function UI.hideAllTabs()
		ExiWoWSettingsFrame_page_settings:Hide();
		ExiWoWSettingsFrame_page_actions:Hide();
		ExiWoWSettingsFrame_page_underwear:Hide();	
	end

	











	-- Portrait
	UI.portrait = {};
	UI.portrait.targetHasExiWoWFrame = nil;			-- Gender display for target
	UI.portrait.excitementBar = false; 				-- Excitement bar frame thing
	UI.portrait.FRAME_WIDTH = 19;
	UI.portrait.FRAME_HEIGHT = 19;
	UI.portrait.PADDING = 7;
	UI.portrait.resting = nil;
	UI.portrait.border = nil;
	

	-- Builds the portrait
	function UI.portrait.build()
		local frameWidth = UI.portrait.FRAME_WIDTH;
		local frameHeight = UI.portrait.FRAME_HEIGHT;
		local padding = UI.portrait.PADDING;

		-- Icon
		local bg = CreateFrame("Button",nil,PlayerFrame); --frameType, frameName, frameParent, frameTemplate   
		bg:SetMovable(true)
		bg:RegisterForDrag("LeftButton")
		bg:SetScript("OnDragStart", bg.StartMoving)
		bg:SetScript("OnDragStop", bg.StopMovingOrSizing)
		
		

		-- Bind events
		bg:RegisterForClicks("AnyUp");
		bg:SetScript("OnClick", function (self, button, down)
			UI:toggle();
		end);

		bg:SetFrameStrata("HIGH");
		bg:SetSize(frameWidth,frameHeight);
		bg:SetPoint("TOPLEFT",80,-5);
		

		local mask = bg:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetPoint("CENTER")

		-- Background
		local t = bg:CreateTexture(nil, "BACKGROUND");
		t:SetColorTexture(0,0,0,0.5);
		t:AddMaskTexture(mask)
		t:SetAllPoints(bg);


		-- Status bar
		local bar = CreateFrame("Frame", nil, bg);
		bar:SetPoint("TOPLEFT")
		bar:SetSize(frameWidth,frameHeight)

		t = bar:CreateTexture(nil, "BORDER");
		t:SetPoint("BOTTOM");
		t:SetSize(frameWidth,frameHeight);
		t:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
		--t:SetHeight(frameHeight*max(self.excitement, 0.00001)); -- Setting to 0 doesn't work
		t:SetRotation(-math.pi/2);
		t:SetVertexColor(1,0.75,1)
		t:AddMaskTexture(mask);
		UI.portrait.portraitExcitementBar = t;
		ExiWoW.ME:updateExcitementDisplay();

		-- Border

		local ol = CreateFrame("Frame", nil, bar);
		ol:SetPoint("TOPLEFT", -padding+1, padding-1)
		ol:SetSize(frameWidth+padding*2,frameHeight+padding*2)
		-- Inner
		t = ol:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface/common/portrait-ring-withbg-highlight");
		t:SetPoint("CENTER", 2);
		t:SetVertexColor(0.75,1,0.75);
		t:SetTexCoord(0.3,0.7,0.3,0.7);
		t:SetAlpha(0);
		t:SetSize(frameWidth,frameHeight);
		UI.portrait.resting = t;

		-- Outer
		
		t = ol:CreateTexture(nil, "ARTWORK");
		t:SetTexture("Interface\\MINIMAP\\MiniMap-TrackingBorder");
		t:SetTexCoord(0.01,0.61,0,0.6);
		t:SetPoint("CENTER", 1,4);
		t:SetAllPoints(ol);
		UI.portrait.border = t;
		
		-- Overlay
		t = ol:CreateTexture(nil, "OVERLAY");
		t:SetTexture("Interface/MINIMAP/UI-Minimap-ZoomButton-Highlight");
		t:SetVertexColor(1,1,0.7);
		t:SetPoint("CENTER", 0,0);
		t:SetBlendMode("ADD");
		t:SetSize(frameWidth+15,frameHeight+15);
		t:SetAlpha(0);
		bg.highlight = t;
		bg:SetScript("OnEnter", function(self) self.highlight:SetAlpha(1) end)
		bg:SetScript("OnLeave", function(self) self.highlight:SetAlpha(0) end)
		

		-- BUILD THE TARGET PORTRAIT --
		bg = CreateFrame("Button",nil,TargetFrame); --frameType, frameName, frameParent, frameTemplate   
		bg:SetMovable(true)
		bg:EnableMouse(true);
		bg:RegisterForDrag("LeftButton")
		bg:SetScript("OnDragStart", bg.StartMoving)
		bg:SetScript("OnDragStop", bg.StopMovingOrSizing)

		bg:SetFrameStrata("HIGH");
		bg:SetSize(20,20);
		bg:SetPoint("TOPRIGHT",-88,-10);
		t = bg:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface/AddOns/ExiWoW/media/icons/genders.blp");
		t:SetVertexColor(1,0.5,1);
		t:SetTexCoord(0,0.25,0,1);
		t:SetAlpha(0.75);
		t:SetAllPoints(bg);
		bg.genderTexture = t;
		UI.portrait.targetHasExiWoWFrame = bg;
		bg:Hide();
	end


	-- Settings for pages with buttons
	UI.buttonPage = {
		ROWS = 4,
		COLS = 8,
		MARG = 1.1,
	}











	-- Build the action page
	UI.actionPage = {}
	function UI.actionPage.build()
		local f = ExiWoWSettingsFrame_page_actions;
		for row=0,UI.buttonPage.ROWS-1 do
			for col=0,UI.buttonPage.COLS-1 do

				local idx = col+row*UI.buttonPage.COLS;
				local ab = CreateFrame("Button", "ExiWoWActionButton_"..tostring(idx), f, "ActionButtonTemplate");
				ab:SetAttribute("type", "action");
				ab:SetAttribute("action", 1);
				ab:SetPoint("TOPLEFT", 23+col*50*UI.buttonPage.MARG, -50-row*50*UI.buttonPage.MARG);
				ab:SetSize(50,50);
				ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)

				local rarity = ab:CreateTexture(nil, "OVERLAY");
				ab.rarity = rarity
				rarity:SetAllPoints()
				rarity:SetTexture("Interface/Common/WhiteIconFrame")

				ab:Hide();

				ab.Name:SetPoint("TOPRIGHT", 8,-30)
				ab.Name:SetFontObject("GameFontHighlight");

				ab:RegisterForDrag("LeftButton");
				ab:SetScript("OnDragStart", function(self)
					local v = UI.actionPage.getAbilityAt(idx+1)
					if v then
						UI.createMacro(v.id)
					end
				end);

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
	end

	function UI.actionPage.getAbilityAt(index)
		local out = 0;
		
		local lib = Database.filter("Action");
		for k,v in pairs(lib) do
			-- Make sure it's acceptable
			if v:validateFiltering("player", true) and
				not v.hidden and
				v.learned
			then
				out = out+1;
				if out == index then return v end
			end
		end
		return false
	end

	function UI.actionPage.update()

		for n=1,UI.buttonPage.ROWS*UI.buttonPage.COLS do
			local f = _G["ExiWoWActionButton_"..(n-1)]
			local v = UI.actionPage.getAbilityAt(n);
			if not v then
				f:Hide();
			else
	
				local name = _G["ExiWoWActionButton_"..(n-1).."Name"];
				if v.charges and v.charges ~= math.huge then
					name:SetText(v.charges)
				else
					name:SetText("")
				end
	
				local rarity = v.rarity-1
				if rarity < 1 then rarity = 1 end
				if rarity >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[rarity] then
					f.rarity:Show();
					f.rarity:SetVertexColor(BAG_ITEM_QUALITY_COLORS[rarity].r, BAG_ITEM_QUALITY_COLORS[rarity].g, BAG_ITEM_QUALITY_COLORS[rarity].b);
				else
					f.rarity:Hide();
				end
	
				f:SetScript("OnMouseUp", function (self, button)
					if IsShiftKeyDown() then
						v.favorite = not v.favorite;
						Action:libSort();
						UI.actionPage.update()
					else
						Action.useOnTarget(v.id, "target")
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
	
			end

		end
	end







	-- Underwear page
	UI.underwearPage = {}
	function UI.underwearPage.build()
		local f = ExiWoWSettingsFrame_page_underwear;
		for row=0,UI.buttonPage.ROWS-1 do
			for col=0,UI.buttonPage.COLS-1 do

				local ab = CreateFrame("Button", "ExiWoWUnderwearButton_"..tostring(col+row*UI.buttonPage.COLS), f, "ActionButtonTemplate");
				ab:SetAttribute("type", "action");
				ab:SetAttribute("action", 1);
				ab:SetPoint("TOPLEFT", 23+col*50*UI.buttonPage.MARG, -50-row*50*UI.buttonPage.MARG);
				ab:SetSize(50,50);
				ab.cooldown:SetSwipeTexture('', 0, 0, 0, 0.75)

				local rarity = ab:CreateTexture(nil, "OVERLAY");
				ab.rarity = rarity
				rarity:SetAllPoints()
				rarity:SetTexture("Interface/Common/WhiteIconFrame")
				
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
	end

	function UI.underwearPage.update()

		local i = 0;
		local unlocked = ExiWoW.ME.underwear_ids;
		local existing = {}
		for k,v in pairs(unlocked) do
			if Underwear.get(v.id) then
				table.insert(existing, v)
			end
		end

		table.sort(existing, function(a, b)
			if a.fav and not b.fav then return true
			elseif not a.fav and b.fav then return false
			end

			local obja = Underwear.get(a.id)
			local objb = Underwear.get(b.id)
			return obja.name < objb.name;
		end)

		for k,v in pairs(existing) do

			local item = v.id
			local fav = v.fav
			local obj = Underwear.get(item)
			-- Make sure it's acceptable
			if obj then

				local f = _G["ExiWoWUnderwearButton_"..i]

				f:SetScript("OnMouseUp", function (self, button)
					if IsShiftKeyDown() then
						v.fav = not v.fav;
						UI:refreshUnderwearPage()
					else
						ExiWoW.ME:useUnderwear(item)
					end
					PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
				end)


				local rarity = obj.rarity-1
				if rarity < 1 then rarity = 1 end
				if rarity >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[rarity] then
					f.rarity:Show();
					f.rarity:SetVertexColor(BAG_ITEM_QUALITY_COLORS[rarity].r, BAG_ITEM_QUALITY_COLORS[rarity].g, BAG_ITEM_QUALITY_COLORS[rarity].b);
				else
					f.rarity:Hide();
				end

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

		for n=i,UI.buttonPage.ROWS*UI.buttonPage.COLS-1 do
			local f = _G["ExiWoWUnderwearButton_"..n]
			f:Hide();
		end
	end





	-- Local actions
	UI.localSettings = {}
	function UI.localSettings.build()
		local f = ExiWoWSettingsFrame_page_settings;
	
		local top = -50;
		local spacing = -40;
		local left = 30
		-- Masochism slider
		local item = 0
		createSlider("ExiWoWSettingsFrame_page_settings_masochism", f, "TOPLEFT", left, -50, "0", "100", "Masochism", 0, 100, 1, "Affects amount of excitement you gain from taking hits or masochistic actions and spells.", 
		function(self,arg1) 
			ExiWoW.ME.masochism = arg1/100;
			localStorage.masochism = ExiWoW.ME.masochism;
		end);

		-- Penis size slider
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_penis_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Male Endowment", 0, 5, 1, "How well endowed is your character?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.penis_size = arg1;
			localStorage.penis_size = ExiWoW.ME.penis_size;
		end);

		-- Breast size slider
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_breast_size", f, "TOPLEFT", left, top+spacing*item, "Off", "Huge", "Female Endowment", 0, 5, 1, "How large are your character's breasts?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.breast_size = arg1;
			localStorage.breast_size = ExiWoW.ME.breast_size;
		end);


		-- Butt size
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_butt_size", f, "TOPLEFT", left, top+spacing*item, "Tiny", "Huge", "Rear Size", 0, 4, 1, "How much junk in the trunk?", 
		function(self,arg1) 
			ExiWoW.ME.butt_size = arg1;
			localStorage.butt_size = ExiWoW.ME.butt_size;
		end);

		-- Toggle vagina
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_vagina_size", f, "TOPLEFT", left+40, top+spacing*item, "Off", "On", "Female Genitalia", 0, 1, 1, "Does your character have female genitalia?", 
		function(self,arg1) 
			arg1 = arg1-1;
			if arg1 == -1 then arg1 = false end
			ExiWoW.ME.vagina_size = arg1;
			localStorage.vagina_size = ExiWoW.ME.vagina_size;
		end, 60);

		-- Tank mode
		item = item+1
		local checkbutton = CreateFrame("CheckButton",  "ExiWoWSettingsFrame_page_settings_tank_mode", f, "ChatConfigCheckButtonTemplate");
		checkbutton.tooltip = "Adds a small chance of crit texts to trigger from normal hits. Useful on tanks since they can't be critically hit.";
		checkbutton:SetPoint("TOPLEFT", left, top+spacing*item);
		getglobal(checkbutton:GetName() .. 'Text'):SetText("Tank Mode");
		checkbutton:SetScript("OnClick", function(self)
			localStorage.tank_mode = self:GetChecked();
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			onSettingsChange()
		end)
		

		-- Right side
		item = 0
		createSlider("ExiWoWSettingsFrame_page_settings_muscle_tone", f, "TOPRIGHT", -left, top+spacing*item, "Scrawny", "Bodybuilder", "Muscle Tone", 0, 10, 1, "How muscular are you compared to your race/class average?", 
		function(self, arg1)
			ExiWoW.ME.muscle_tone = arg1;
			localStorage.muscle_tone = ExiWoW.ME.muscle_tone;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_fat", f, "TOPRIGHT", -left, top+spacing*item, "Emaciated", "Obese", "Body Fat", 0, 10, 1, "How fat are you compared to your race/class average?", 
		function(self, arg1)
			ExiWoW.ME.fat = arg1;
			localStorage.fat = ExiWoW.ME.fat;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_intelligence", f, "TOPRIGHT", -left, top+spacing*item, "Dumb", "Scholarly", "Intelligence", 0, 10, 1, "How smart are you compared to your race/class average when it comes to solving problems?", 
		function(self, arg1)
			ExiWoW.ME.intelligence = arg1;
			localStorage.intelligence = ExiWoW.ME.intelligence;
		end)
		item = item+1
		createSlider("ExiWoWSettingsFrame_page_settings_wisdom", f, "TOPRIGHT", -left, top+spacing*item, "Gullible", "Astute", "Wisdom", 0, 10, 1, "What social skills does your character possess?", 
		function(self, arg1)
			ExiWoW.ME.wisdom = arg1;
			localStorage.wisdom = ExiWoW.ME.wisdom;
		end)
		
		
		
		-- Bind events
		ExiWoWSettingsFrame_close:SetScript("OnMouseUp", function (self, button)
			UI:toggle();
		end)


		ExiWoWSettingsFrameTab1:SetScript("OnMouseUp", function (self, button)
			PanelTemplates_SetTab(UI.FRAME, 1);
			UI:hideAllTabs();
			ExiWoWSettingsFrame_page_actions:Show();
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
		end)

		ExiWoWSettingsFrameTab2:SetScript("OnMouseUp", function (self, button)
			PanelTemplates_SetTab(UI.FRAME, 2);
			UI:hideAllTabs();
			ExiWoWSettingsFrame_page_underwear:Show();
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
		end)
		ExiWoWSettingsFrameTab3:SetScript("OnMouseUp", function (self, button)
			PanelTemplates_SetTab(UI.FRAME, 3);
			UI:hideAllTabs();
			ExiWoWSettingsFrame_page_settings:Show();
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
		end)

	end
	
	function UI.localSettings.update()
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
		
		
		ExiWoWSettingsFrame_page_settings_tank_mode:SetChecked(localStorage.tank_mode);
	end





	-- Loot display
	-- /run UI:drawLoot("TestLoot", "ability_defend", 1)
	-- /run UI:drawLoot("TestLoot2", "ability_hunter_pet_bear", 2)
	-- Rarity starts at 1 which is grey
	-- Rarity starts at 1 which is grey
	function UI.drawLoot(name, icon, rarity)
		if not rarity then rarity = 2 end

		table.insert(UI.lootQueue, {name=name, icon=icon})

		local rarities = {
			"|cff1eff00|Hitem:133963::::::::110:::::|h[w]|h|r",		-- Grey
			"|cff1eff00|Hitem:5637::::::::110:::::|h[w]|h|r",		-- White
			"|cff1eff00|Hitem:120302::::::::110:::::|h[w]|h|r",		-- Green
			"|cff1eff00|Hitem:10413::::::::110:::::|h[w]|h|r",		-- Blue
			"|cff1eff00|Hitem:124367::::::::110:::::|h[w]|h|r",		-- Purple
			"|cff1eff00|Hitem:77949::::::::110:::::|h[w]|h|r"		-- Orange
		}
		PlaySound(50893, "Dialog")

		local function checkItem()
			if GetItemInfo(rarities[rarity]) == nil then
				Timer.set(checkItem, 0.1)
			else
				LootAlertSystem:AddAlert(rarities[rarity], 1, 0, 0, 0, false, false, nil, false, false, true, false);
			end
		end

		checkItem();
		
	end
	
	-- Global settings
	UI.globalSettings = {}
	function UI.globalSettings.build()
		local panel = CreateFrame("Frame", appName.."_globalConf", UIParent)
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
		n = n+1;
		createCheckbutton("taunt_female", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Female Actions", "Turn off to prevent certain actions by females to be used against you.");
		n = n+1;
		createCheckbutton("taunt_male", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Male Actions", "Turn off to prevent certain actions by males to be used against you.");
		n = n+1;
		createCheckbutton("taunt_other", panel, "TOPLEFT", gPadding,-gPadding-gBottom*n, "Enable Other Actions", "Turn off to prevent certain actions by other genders to be used against you.");
		

		local prefix = appName.."_globalConf_";
		n = 0
		createSlider(prefix.."takehit_rp_rate", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "1", "60", "Hit Text Limit", 1, 60, 1, "Sets minimum time in seconds between RP texts received from being affected by an attack or spell.", function(self, val)
			setValueInTitle(self, " ("..val.." sec)");
		end);
		n = n+1
		createSlider(prefix.."spell_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "400%", "Spell RP Text Chance", 0, 4, 0.1, "Sets the chance of a viable spell triggering an RP text.\nThis is multiplied by the spell's internal chance, so even at 100% it's not a guarantee. Default = 100%", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."swing_text_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "100%", "Melee Text Chance", 0, 1, 0.05, "Chance of a text triggering on a melee hit. Crits are 4x this value. Default = 15%", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."taunt_freq", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0%", "100%", "NPC whisper chance", 0, 1, 0.05, "Chance of NPCs whispering you. 0 turns it off.", function(self, val)
			setValueInTitle(self, " ("..math.floor(val*100).."%)");
		end);
		n = n+1
		createSlider(prefix.."taunt_rp_rate", panel, "TOPRIGHT", -gPadding,-gPadding-gBottom*n, "0", "300", "NPC Whisper Limit", 0, 300, 1, "Minimum time between receiving NPC whispers in combat. Default is 30.", function(self, val)
			setValueInTitle(self, " ("..val.." sec)");
		end);
		
				
		panel.okay = function (self) 

			local gs = globalStorage;
			local prefix = appName.."_globalConf_";
			gs.takehit_rp_rate = getglobal(prefix.."takehit_rp_rate"):GetValue();
			gs.spell_text_freq = getglobal(prefix.."spell_text_freq"):GetValue();
			gs.swing_text_freq = getglobal(prefix.."swing_text_freq"):GetValue();
			gs.taunt_freq = getglobal(prefix.."taunt_freq"):GetValue();
			gs.taunt_rp_rate = getglobal(prefix.."taunt_rp_rate"):GetValue();
			
			
			gs.enable_in_dungeons = getglobal(prefix.."enable_in_dungeons"):GetChecked();
			gs.enable_public = getglobal(prefix.."enable_public"):GetChecked();
			gs.taunt_female = getglobal(prefix.."taunt_female"):GetChecked();
			gs.taunt_male = getglobal(prefix.."taunt_male"):GetChecked();
			gs.taunt_other = getglobal(prefix.."taunt_other"):GetChecked();

		end;
		panel.cancel = function (self)  UI.drawGlobalSettings(); end;
	end
	function UI.globalSettings.update()
		local gs = globalStorage;
		local prefix = appName.."_globalConf_";
		getglobal(prefix.."takehit_rp_rate"):SetValue(gs.takehit_rp_rate);
		getglobal(prefix.."spell_text_freq"):SetValue(gs.spell_text_freq);
		getglobal(prefix.."swing_text_freq"):SetValue(gs.swing_text_freq);
		getglobal(prefix.."taunt_freq"):SetValue(gs.taunt_freq);
		getglobal(prefix.."taunt_rp_rate"):SetValue(gs.taunt_rp_rate);
		getglobal(prefix.."enable_in_dungeons"):SetChecked(gs.enable_in_dungeons);
		getglobal(prefix.."enable_public"):SetChecked(gs.enable_public);
		getglobal(prefix.."taunt_female"):SetChecked(gs.taunt_female);
		getglobal(prefix.."taunt_male"):SetChecked(gs.taunt_male);
		getglobal(prefix.."taunt_other"):SetChecked(gs.taunt_other);
	end



export("UI", UI, {}, UI)
	

	
