-- Plugins
local lze = require("lze")

lze.register_handlers(require("lzextras").lsp)
lze.load({
	{ "plenary.nvim", dep_of = { "harpoon", "telescope.nvim" } },

	-- Language Server Protocol
	{
		"nvim-lspconfig",
		dep_of = { "godotdev" },
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

	-- Debugger
	{
		"nvim-dap",
		after = function()
			require("dot.debugger")
		end,
		dep_of = { "godotdev.nvim" },
		on_require = { "dap", "dapui" },
	},
	{ "nvim-dap-ui", dep_of = "nvim-dap" },
	{ "nvim-nio", dep_of = "nvim-dap-ui" },

	-- Formatting
	{
		"conform.nvim",
		after = function()
			require("dot.formatting")
		end,
		cmd = { "ConformInfo", "Format" },
		event = { "InsertLeave", "TextChanged" },
	},
	{
		"guess-indent.nvim",
		after = function()
			require("guess-indent").setup()
		end,
		cmd = "GuessIndent",
		event = "BufEnter",
	},

	-- Autocomplete
	{
		"blink-cmp",
		after = function()
			require("blink.cmp").setup({
				completion = {
					list = { selection = { preselect = true, auto_insert = true } },
					menu = {
						draw = {
							padding = { 1, 0 },
							columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
							components = {
								kind_icon = { width = { fill = true } },
							},
						},
					},
					documentation = { auto_show = true },
				},
				fuzzy = { implementation = "prefer_rust" },
				keymap = {
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },

					["<Left>"] = { "hide", "fallback" },
					["<Right>"] = { "accept", "fallback" },
					["<CR>"] = { "accept", "fallback" },

					["<Up>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Down>"] = { "select_next", "snippet_forward", "fallback" },

					["<C-Up>"] = { "scroll_documentation_up", "fallback" },
					["<C-Down>"] = { "scroll_documentation_down", "fallback" },
				},
				sources = {
					default = { "snippets", "lazydev", "lsp", "path", "buffer" },
					providers = {
						lazydev = {
							name = "LazyDev",
							module = "lazydev.integrations.blink",
							score_offset = 100,
						},
					},
				},
			})
		end,
		cmd = "ConformInfo",
		event = "InsertEnter",
		on_require = "blink",
	},
	{ "friendly-snippets", dep_of = "blink-cmp" },
	{
		"nvim-autopairs",
		after = function()
			require("nvim-autopairs").setup()
		end,
		event = "InsertEnter",
	},

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

	-- Quick file switching
	{
		"harpoon2",
		after = function()
			require("harpoon"):setup()
		end,
		on_require = "harpoon",
	},

	-- Auto-saving
	{
		"auto-save.nvim",
		after = function()
			require("auto-save").setup({
				condition = function(buf)
					if vim.bo[buf].filetype == "harpoon" then
						return false
					end
					return true
				end,
			})
		end,
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
	},

	-- Session restore in git repos
	{
		"auto-session",
		after = function()
			require("auto-session").setup()
		end,
		cmd = {
			"SessionSave",
			"SessionRestore",
			"SessionDelete",
			"SessionDisableAutoSave",
			"SessionToggleSave",
			"SessionPurgeOrphaned",
			"SessionSearch",
			"Auutosession",
		},
		lazy = not (#(vim.fs.root(0, ".git") or {}) > 0),
	},

	-- Secrets hiding
	{
		"cloak.nvim",
		after = function()
			require("cloak").setup()
		end,
		cmd = {
			"CloakDisable",
			"CloakEnable",
			"CloakToggle",
		},
		ft = { "sh" },
	},

	-- Treesitter (Syntax Highlighting)
	{
		"nvim-treesitter",
		after = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = require("nvim-treesitter.config").get_installed(),
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
		event = "FileType",
		dep_of = { "godotdev", "indent-blankline.nvim" },
		on_require = "nvim-treesitter",
	},
	-- {
	-- 	"nvim-treesitter-textobjects",
	-- 	after = function()
	-- 		vim.g.no_plugin_maps = false
	-- 	end,
	-- 	dep_of = "nvim-treesitter",
	-- },
	-- { "nvim-treesitter-textsubjects", dep_of = "nvim-treesitter" },

	-- Appearance
	{
		"catppuccin-nvim",
		after = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
			})
		end,
	},
	{
		"indent-blankline.nvim",
		after = function()
			require("ibl").setup()
		end,
		event = "BufEnter",
	},

	-- Git
	{
		"gitsigns.nvim",
		after = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "+" },
					topdelete = { text = "-" },
					changedelete = { text = "~" },
				},
				current_line_blame = false,
				current_line_blame_opts = {
					delay = 0,
				},
			})
		end,
		cmd = "Gitsigns",
		keys = {
			{
				"<leader>gt",
				":Gitsigns toggle_current_line_blame<cr>",
				desc = "[Git] Toggle line blame",
			},
		},
		lazy = not (#(vim.fs.root(0, ".git") or {}) > 0),
	},

	-- Todo comments
	{
		"todo-comments.nvim",
		after = function()
			require("todo-comments").setup()
		end,
	},

	-- Integrations
	{
		"aw-watcher.nvim",
		after = function()
			require("aw_watcher").setup({})
		end,
	},
	{
		"godotdev.nvim",
		after = function()
			require("godotdev").setup({
				autostart_editor_server = true,
			})
		end,
		cmd = { "GodotReconnectLSP", "GodotStartEditorServer" },
		ft = { "gd", "gdscript", "gdshader", "gdscript3" },
		on_require = "godotdev",
	},
})
