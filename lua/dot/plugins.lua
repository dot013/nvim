-- Plugins
local lze = require("lze")

lze.register_handlers(require("lzextras").lsp)
lze.load({
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
})
