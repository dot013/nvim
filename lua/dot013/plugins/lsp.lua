local lsps = {
	["cssls"] = {},
	["emmet_language_server"] = {
		filetypes = {
			"css",
			"eruby",
			"html",
			"javascript",
			"javascriptreact",
			"less",
			"sass",
			"scss",
			"pug",
			"templ",
			"typescriptreact",
		},
		init_options = {
			---@type table<string, string>
			includeLanguages = {},
			--- @type string[]
			excludeLanguages = {},
			--- @type string[]
			extensionsPath = {},
			--- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
			preferences = {},
			--- @type boolean Defaults to `true`
			showAbbreviationSuggestions = true,
			--- @type "always" | "never" Defaults to `"always"`
			showExpandedAbbreviation = "always",
			--- @type boolean Defaults to `false`
			showSuggestionsAsSnippets = false,
			--- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
			syntaxProfiles = {},
			--- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
			variables = {},
		},
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
	["htmx"] = {
		filetypes = { "html" },
	},
	["jsonls"] = {},
	["nil_ls"] = {
		cmd = { "nil" },
		filetypes = { "nix" },
		single_file_support = true,
		root_dir = nil,
	},
	-- ["tailwindcss"] = {},
	["templ"] = function()
		if vim.fn.executable("templ") then
			return {}
		else
			return nil
		end
	end,
	["ts_ls"] = {},
	["rust_analyzer"] = {},
	["unocss"] = function()
		-- local unocss = require("lspconfig.configs")["unocss"]
		return {
			filetypes = {
				"templ",
			},
		}
	end,
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
