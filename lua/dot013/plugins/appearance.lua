return {
	-- Frappurccino/Catppuccin theme
	{
		"catppuccin-nvim",
		priority = 1000,
		after = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Status bar
	{
		"lualine.nvim",
		priority = 1000,
		after = function()
			require("lualine").setup({
				options = {
					icons_enabled = false,
					theme = "catppuccin",
					component_separators = "|",
					section_separators = "",
				},
			})
		end,
	},
	{ "nvim-web-devicons", dep_of = { "lualine.nvim" } },

	-- Visual indentation
	{
		"indent-blankline.nvim",
		priority = 1000,
		after = function()
			require("ibl").setup()
		end,
	},
}
