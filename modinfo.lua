-- Your mod's name! This one is simple enough, really.
name = "Item Auto-Fuel Slots"

--Description. You can put special characters here, but I'm not 100% sure how.
description = "Manage your item's fuel like a pro, with AUTOMATION!\nThis mod adds extra slots above most refuelable items, where fuel can be stored and will be automatically consumed as needed by the item.\n\nSlots added for\n * Latern\n * Miner Hat\n * Bone Armor\n * Moggles\n * Shield of Terror\n * Magiluminescence \n * Shadow Thurible \n * Eye Mask \n * Alarming Clock"

-- Your name, you can really put anything here, but I like to put my own username.
author = "Skylarr"

-- Version number, make sure to change this each time you upload via the Mod Tools, or else they get angry.
version = "1.2.0"

-- The Forum URL after the ? and before the &.
forumthread = ""

-- This has been 10 for about as long as I've been modding, though I haven't been modding long.
api_version = 10

-- Compatible with Don't Starve Together, obviously.
dst_compatible = true

-- Not compatible with Don't Starve, or any of it's expansions.
dont_starve_compatible = false 
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- This line forces every connected client to have the mod installed.
all_clients_require_mod = true

-- This line marks that this mod is only needed on the server.
-- server_only_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
-- This is only occasionally useful, and for this mod isn't really useful at all, since it's a simple tweak.
-- However, I filled it in here regardless with whatever info I could think of that would be simply searched.
server_filter_tags = {
	"LFS",
	"Lantern Fuel Slot",
	"Auto-Fuel",
	"Auto Fuel",
	"fuel slot"
}

local null_options = {
	{ description = "", data = 0 }
}

configuration_options = 
{
    {
		name = "UI",
		options = null_options,
		hover = "",
		default = 0,
	},	

	{
		name = "slotsize",
		label = "Slot Size",
		hover = "Changes the size of the extra slots added by this mod. Also effects vanilla items that use the hand slot container.",
		options =
		{
			{description = "Tiny", data = 1},
			{description = "Small", data = 1.25},
			{description = "Normal (Default)", data = 1.5},
		},
		default = 1.5,
	},

    {
		name = "Item Slot Toggles",
		options = null_options,
		hover = "",
		default = 0,
	},	

	{
		name = "lantern",
		label = "Lantern",
		hover = "Enable or disable the Lantern slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "minerhat",
		label = "Miner Hat",
		hover = "Enable or disable the Miner Hat slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "armorskeleton",
		label = "Bone Armor",
		hover = "Enable or disable the Bone Armor slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "molehat",
		label = "Moggles",
		hover = "Enable or disable the Moggles slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "shieldofterror",
		label = "Shield Of Terror",
		hover = "Enable or disable the Shield of Terror slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "yellowamulet",
		label = "Magiluminescence",
		hover = "Enable or disable the Magiluminescence slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

    {
		name = "thurible",
		label = "Shadow Thurible",
		hover = "Enable or disable the Shadow Thurible slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

	{
		name = "eyemaskhat",
		label = "Eye Mask",
		hover = "Enable or disable the Eye Mask slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},

	{
		name = "pocketwatch_weapon",
		label = "Alarming Clock",
		hover = "Enable or disable the Alarming Clock slot added by this mod.",
		options =
		{
			{description = "No", data = false},
			{description = "Yes (Default)", data = true},
		},
		default = true,
	},
}
