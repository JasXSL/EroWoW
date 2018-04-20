local appName, internal = ...
local export = internal.Module.export;
local require = internal.require;

Extension = {}
Extension.LIB = {}
Extension.__index = Extension;

local RPText, Action, SpellBinding, Effect, Underwear, Database;


	function Extension:ini()
		Database = require("Database")
		RPText = require("RPText")
		Action = require("Action")
		SpellBinding = require("SpellBinding")
		Effect = require("Effect")
		Underwear = require("Underwear")
	end

	function Extension:new(data, isRoot)
		local self = {}
		setmetatable(self, Extension); 
		if type(data) ~= "table" or type(data.id) ~= "string" or (data.id == "ROOT" and not isRoot) then
			print("Unable to import extension, data or id missing")
			return false;
		end

		local function importTable(t)
			if type(t) ~= "table" then return {} end
			return t
		end

		self.id = data.id

		-- Import RP
		self.rpTexts = importTable(data.rpTexts)

		-- Import actions
		self.actions = importTable(data.actions)

		-- Import SpellBindings
		self.spellBindings = importTable(data.spellBindings)

		-- Effects
		self.effects = importTable(data.effects)

		-- Underwear
		self.underwear = importTable(data.underwear)

		return self
	end

	-- Exports to a JSON string for the user
	function Extension:export()
		if self.id == nil then return false end
		-- Todo:export
	end

	-- These functions lets you add by generic objects
	function Extension:addRpText(data)
		table.insert(self.rpTexts, RPText:new(data))
	end
	Extension.addRPText = Extension.addRpText;

	function Extension:addAction(data)
		table.insert(self.actions, Action:new(data))
	end
	function Extension:addSpellBinding(data)
		table.insert(self.spellBindings, SpellBinding:new(data))
	end
	
	function Extension:addEffect(data)
		table.insert(self.effects, Effect:new(data))
	end
	function Extension:addUnderwear(data)
		table.insert(self.underwear, Underwear:new(data))
	end
	


	-- STATIC --

	-- Updates asset indexes --
	function Extension.index()

		-- Reset libraries
		Database.clearTables("RPText", "Action", "SpellBinding", "Effect", "Underwear")

		for k,v in pairs(Extension.LIB) do
			
			Database.add("RPText", v.rpTexts);
			Database.add("Action", v.actions);
			Database.add("SpellBinding", v.spellBindings);
			Database.add("Effect", v.effects);
			Database.add("Underwear", v.underwear);

		end
		

		local UI = require("UI")
		local Action = require("Action")

		-- Update the HUD
		Action.sort()
		UI.underwearPage.update()
		UI.actionPage.update()
		

	end

	function Extension.exportAll()
		local out = {}
		for k,v in pairs(Extension.LIB) do
			local exp = v:export()
			if exp then 
				table.insert(out, exp)
			end
		end
	end


	function Extension.import(data, isRoot)
		local ex = Extension:new(data, isRoot);
		if ex then
			Extension.LIB[ex.id] = ex
			Extension:index()
			if ex.id ~= "ROOT" then
				print("-- Using: ", ex.id, "["..#ex.spellBindings.." bindings]")
			end
			if ExiWoW.loaded then ExiWoW.Menu:refreshAll(); end
			return ex
		end
	end

	-- Import from text --
	function Extension.importFromText(text)
		-- Todo: Figure out a way to import with custom functions
	end

	function Extension.remove(id)
		Extension.LIB[id] = nil
		Extension.index();
	end



export("Extension", Extension,
	{
		import = Extension.import
	},
	{
		index = Extension.index,
		remove = Extension.remove
	}
)
