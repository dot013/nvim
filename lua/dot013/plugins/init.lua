return {
	{ import = "dot013.plugins.appearance" },
	{ import = "dot013.plugins.debugger" },
	{ import = "dot013.plugins.formatting" },
	{ import = "dot013.plugins.ide" },
	{ import = "dot013.plugins.integrations" },
	{ import = "dot013.plugins.lsp" },
	{ import = "dot013.plugins.navigation" },
	{ import = "dot013.plugins.treesitter" },

	-- Global Dependencies
	{ "plenary.nvim", dep_of = { "telescope.nvim", "harpoon" } },
}
