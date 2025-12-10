-- Plugins
local lze = require("lze")

lze.register_handlers(require("lzextras").lsp)
lze.load({
	{ "plenary.nvim", dep_of = { "harpoon", "telescope.nvim" } },

	-- Language Server Protocol
	{
		"nvim-lspconfig",
		---@param plugin lze.Plugin
		lsp = function(plugin)
			local config = plugin.lsp or {}

			config["capabilities"] = require("blink.cmp").get_lsp_capabilities(config["capabilities"] or {})

			vim.lsp.config(plugin.name, config)
			vim.lsp.enable(plugin.name)
		end,
	},
	{ "lazydev.nvim", on_require = "lazydev" },
	{ import = "dot.lsp" },
	-- Fuzzy Finding
	{
		"telescope.nvim",
		after = function()
			require("telescope").load_extension("zf-native")
		end,
		cmd = { "Telescope" },
		on_require = "telescope",
	},
	{ "telescope-zf-native.nvim", dep_of = "telescope.nvim" },

	-- File quick switching
	{
		"harpoon2",
		after = function()
			require("harpoon"):setup()
		end,
		on_require = "harpoon",
	},

	-- Auto-saving
})
