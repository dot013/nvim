return {
	{ import = "dot013.plugins.appearance" },
	{ import = "dot013.plugins.navigation" },

	-- Global Dependencies
	{ "plenary.nvim", dep_of = { "telescope.nvim", "harpoon" } },
}
