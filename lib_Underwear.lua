
function ExiWoW.Underwear:buildLibrary()
	local lib = ExiWoW.Underwear.Lib;
	local uw = ExiWoW.Underwear;
	table.insert(lib, uw:new({
		id = "DEFAULT",
		name = "Linen Underwear",
		icon = "Inv_misc_desecrated_clothpants",
		description = "A basic pair of linen underwear.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "LEATHER_THONG",
		name = "Leather Thong",
		icon = "6or_garrison_hangingleather",
		description = "A leather thong.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "ORCISH_BRIEFS",
		name = "Orcish Briefs",
		icon = "item_savageleatherhide",
		description = "Orcish briefs made of haphazardly stitched together pieces of hide.",
		tags = {},
	}));

end

