local lsps = {
	["cssls"] = {},
	["emmet_language_server"] = {
		filetypes = require("lspconfig.configs.emmet_language_server").default_config.filetypes,
	},
	["eslint"] = {},
	["denols"] = {},
	["lemminx"] = {
		filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "xhtml" },
	},
	["lua_ls"] = {
		on_init = function(client)
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					version = "LuaJIT",
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
					},
				},
			})
		end,
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},
	["gopls"] = {},
	["golangci_lint_ls"] = function()
		if vim.fn.executable("golangci-list") == 1 then
			return {}
		else
			return nil
		end
	end,
	["html"] = {},
	["htmx"] = {},
	["jsonls"] = {},
	["nil_ls"] = {
		cmd = { "nil" },
		filetypes = { "nix" },
		single_file_support = true,
		root_dir = nil,
	},
	["marksman"] = {},
	["ts_ls"] = {},
	["rust_analyzer"] = {},
}

return {
	-- Language Server Protocol (LSP) configuration
	{
		"nvim-lspconfig",
		after = function()
			local blink = require("blink.cmp")
			for server, config in pairs(lsps) do
				if type(config) == "function" then
					config = config()
				end

				if config == nil then
					return
				end

				-- config.capabilities = blink.get_lsp_capabilities(config.capabilities)

				vim.lsp.enable(server)
				if next(config) ~= nil then
					vim.lsp.config(server, config)
				end
			end

			vim.diagnostic.config({
				virtual_text = true,
			})
		end,
	},

	-- Emmet integration
	{
		"nvim-emmet",
		ft = lsps["emmet_language_server"].filetypes,
		keys = {
			{
				"<leader>we",
				":lua require('nvim-emmet').wrap_with_abbreviation()<cr>",
				desc = "[Emmet] Wrap with emmet abbreviation",
				mode = { "n", "v" },
			},
		},
	},

	-- Quickfix list and diagnostics
	{
		"trouble.nvim",
		cmd = { "Trouble" },
		keys = {
			{
				"<leader>t",
				"<cmd>Trouble diagnostics toggle severity=vim.diagnostic.severity.ERROR<cr>",
				desc = "[Trouble] Buffer diagnostics",
			},
			{
				"<leader>la",
				"<cmd>Trouble lsp toggle focus=false win.position=right win.type=split<cr>",
				desc = "[Trouble] All LSP Definitions & references",
			},
			{
				"<leader>s",
				"<cmd>Trouble symbols toggle focus=false win.position=right win.type=split<cr>",
				desc = "[Trouble] Symbols",
			},
			{
				"<leader>q",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "[Trouble] Quickfix list",
			},
		},
		after = function()
			require("trouble").setup()
		end,
	},
}
