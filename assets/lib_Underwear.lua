
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

	table.insert(lib, uw:new({
		id = "KULTIRAS_BOXERS",
		name = "Kul Tiras Boxers",
		icon = "inv_misc_anchor",
		description = "White boxer shorts made of anchor-patterned cotton. Made with gold colored trimmings.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "HIGH_RISING_BIKINI_THONG_PINK",
		name = "High Rising Bikini Thong",
		icon = "inv_belt_cloth_draenei_c_01",
		description = "A pink high rising bikini thong, made out of a stretchy material.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "SKULL_STRAP",
		name = "Skull Strap",
		icon = "inv_helm_laughingskull_01",
		description = "A hollowed out skull with straps attached to it, just about covers your crotch.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "RAZAANI_SOULTHONG",
		name = "Razaani Soulthong",
		icon = "inv_cloth_raidmage_p_01shoulder",
		description = "A thong made of light pink silk wrappings with sparkling soulgems attached around the waist straps.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "FURBOLG_LOINCLOTH",
		name = "Furbolg Loincloth",
		icon = "inv_misc_leatherscrap_16",
		description = "A tattered leather thong with rope straps, usually worn by furbolgs.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "FELCLOTH_PANTIES",
		name = "Felcloth Panties",
		icon = "6or_garrison_clothroof",
		description = "Red panties made of felcloth, with black trimmings.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "LEAF_PANTIES",
		name = "Leaf Panties",
		icon = "ability_druid_flourish",
		description = "Panties made of thick shiny green leaves. Super smooth to the touch.",
		tags = {},
	}));

	table.insert(lib, uw:new({
		id = "WOOLY_SHORTS",
		name = "Wooly Shorts",
		icon = "inv_pants_leather_31red",
		description = "Brown wooly shorts. They're sure to keep you warm!",
		tags = {},
	}));
	
end

