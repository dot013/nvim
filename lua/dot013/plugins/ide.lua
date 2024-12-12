return {
	-- Auto saving on file save
	{
		"auto-save.nvim",
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
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
	},

	-- Session restore, enabled automatically in git repos
	{
		"auto-session",
		lazy = not require("dot013.utils").is_in_cwd(".git"),
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
		after = function()
			require("auto-session").setup()
		end,
	},

	-- Completion
	{
		"blink-cmp",
		event = "InsertEnter",
		dep_of = { "nvim-lspconfig" },
		after = function()
			require("blink.cmp").setup({
				keymap = {
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
					["<C-e>"] = { "hide", "fallback" },

					["<CR>"] = { "accept", "fallback" },

					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },

					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },
				},
				snippets = {
					expand = function(snippet)
						require("luasnip").lsp_expand(snippet)
					end,
					active = function(filter)
						if filter and filter.direction then
							require("luasnip").jumpable(filter.direction)
						end
						return require("luasnip").in_snippet()
					end,
					jump = function(direction)
						require("luasnip").jump(direction)
					end,
				},
				sources = {
					default = {
						"lsp",
						"path",
						"snippets",
						"buffer",
					},
				},
				completion = {
					list = {
						selection = "auto_insert",
					},
					menu = {
						draw = {
							padding = { 1, 0 },
							columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
							components = {
								kind_icon = { width = { fill = true } },
							},
						},
					},
					documentation = {
						auto_show = true,
					},
				},
			})
		end,
	},
	{
		"luasnip",
		dep_of = { "blink-cmp" },
		after = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip").setup()
		end,
	},
	{ "friendly-snippets", dep_of = { "luasnip" } },

	-- Environment variables and secrets hidding
	{
		"cloak.nvim",
		ft = { "sh" },
		cmd = {
			"CloakDisable",
			"CloakEnable",
			"CloakToggle",
		},
		after = function()
			require("cloak").setup()
		end,
	},

	-- Smart comments
	{
		"comment.nvim",
		after = function()
			require("Comment").setup({
				mappings = {
					basic = true,
					extra = true,
				},
			})
		end,
	},

	-- Git integration, enabled just in git repos
	{
		"gitsigns.nvim",
		cmd = "Gitsigns",
		keys = {
			{
				"<leader>gt",
				":Gitsigns toggle_current_line_blame<cr>",
				desc = "[Git] Toggle line blame",
			},
		},
		enabled = require("dot013.utils").is_in_cwd(".git"),
		lazy = not require("dot013.utils").is_in_cwd(".git"),
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
	},

	-- Auto closing pairs
	{
		"nvim-autopairs",
		event = "InsertEnter",
		after = function()
			require("nvim-autopairs").setup()
		end,
	},

	-- Auto closing and renaming tags
	{
		"nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		after = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},

	-- Automatic buffer options and .editorconfig support
	{
		"vim-sleuth",
		event = { "BufReadPre", "BufNewFile" },
	},

	-- File explorer
	{
		-- (Probably can be replaced by local functions in the config)
		"tfm.nvim",
		enabled = vim.fn.executable("yazi"),
		cmd = { "Ex", "Tfm", "TfmSplit", "TfmVsplit", "TfmTabedit" },
		keys = {
			{ "<leader>e", ":Tfm<cr>", desc = "[TFM] Open file manager" },
		},
		after = function()
			require("tfm").setup({
				file_manager = "yazi",
				replace_netrw = true,
				enable_cmds = true,
			})
		end,
	},
}
