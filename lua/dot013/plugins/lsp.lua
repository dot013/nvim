local lsps = {
	["cssls"] = {},
	["emmet_language_server"] = {
		filetypes = require("lspconfig.configs.emmet_language_server").default_config.filetypes,
	},
	["eslint"] = {},
	["denols"] = {},
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
	["golangci_lint_ls"] = {},
	["html"] = {},
	-- ["htmx"] = {}, # BORKED: blink.cmp stops working whtn htmx-lsp is attached https://github.com/Saghen/blink.cmp/issues/825
	["jsonls"] = {},
	["nil_ls"] = {
		cmd = { "nil" },
		filetypes = { "nix" },
		single_file_support = true,
		root_dir = nil,
	},
	["ts_ls"] = {},
	["rust_analyzer"] = {},
}

return {
	-- Language Server Protocol (LSP) configuration
	{
		"nvim-lspconfig",
		after = function()
			local lsp = require("lspconfig")
			for k, v in pairs(lsps) do
				if type(v) == "function" then
					v = v()
				end

				if v == nil then
					return
				end

				v.capabilities = require("blink.cmp").get_lsp_capabilities(v.capabilities)

				lsp[k].setup(v)
			end
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
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "[Trouble] Buffer diagnostics",
			},
			{
				"<leader>te",
				"<cmd>Trouble diagnostics toggle filter.buf=0 severity=viimi.diagnostics.severity.ERROR<cr>",
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
