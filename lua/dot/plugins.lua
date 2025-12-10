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

	-- Formatting
	{
		"conform.nvim",
		after = function()
			local function js_fmt(bufnr)
				local f = {}

				if require("conform").get_formatter_info("prettierd", bufnr).available then
					table.insert(f, "prettierd")
				elseif require("conform").get_formatter_info("prettier", bufnr).available then
					table.insert(f, "prettier")
				end

				if require("conform").get_formatter_info("eslint_d", bufnr).available then
					table.insert(f, "eslint_d")
				end

				if
					require("conform").get_formatter_info("deno_fmt", bufnr).available
					and (
						require("dot013.utils").is_in_cwd("deno.json")
						or require("dot013.utils").is_in_cwd("deno.jsonc")
					)
				then
					table.insert(f, "deno_fmt")
				end

				return f
			end
			require("conform").setup({
				formatters_by_ft = {
					-- Simple formatters
					lua = { "stylua" },
					nix = { "alejandra", stop_after_first = true },
					rust = { "rustfmt", lsp_format = "fallback" },
					sh = { "shellharden", "shfmt" },
					xml = { "xmllint", "xmltidy" },
					xhtml = { "xmllint", "xmltidy" },
					markdown = { "mdfmt" },

					html = { "prettierd", "prettier", stop_after_first = true },
					css = { "prettierd", "prettier", stop_after_first = true },
					scss = { "prettierd", "prettier", stop_after_first = true },
					less = { "prettierd", "prettier", stop_after_first = true },
					yaml = { "prettierd", "prettier", stop_after_first = true },

					gdscript = { "gdformat" },
					-- Golang's formatters used by priority
					go = function(bufnr)
						local f = {}

						if require("conform").get_formatter_info("gofumpt", bufnr).available then
							table.insert(f, "gofumpt")
						else
							table.insert(f, "gofmt")
						end

						if require("conform").get_formatter_info("golines", bufnr).available then
							table.insert(f, "golines")
						elseif require("conform").get_formatter_info("goimports", bufnr).available then
							table.insert(f, "goimports")
						end

						return f
					end,
					templ = { "templ" },

					-- JavaScript's ecosystem
					javascript = js_fmt,
					javascriptreact = js_fmt,
					typescript = js_fmt,
					typescriptreact = js_fmt,
					json = function(bufnr)
						local fmts = js_fmt(bufnr)
						if fmts then
							return fmts
						end
						return { "jq" }
					end,

					-- Fallback for any filetype
					["*"] = { "codespell" },
					["_"] = { "trim_whitespace" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
				formatters = {
					mdfmt = {
						command = "mdfmt",
					},
					xmltidy = {
						inherit = false,
						-- Uses HTML Tidy
						command = "tidy",
						args = { "-xml", "-indent", "yes", "2", "-wrap", "100", "-" },
					},
					--[[ nixcmdfmt = {
						inherit = false,
						stdin = false,
						cwd = require("conform.util").root_file({ "flake.nix" }),
						require_cwd = true,
						command = "nix",
						args = { "fmt", "$FILENAME" },
					}, ]]
				},
			})
		end,
		on_require = "conform",
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
		lazy = not (#(vim.fs.root(0, ".git") or 0) > 0),
	},

	-- Formatting
	{
		"guess-indent.nvim",
		after = function()
			require("guess-indent").setup()
		end,
		cmd = "GuessIndent",
		event = "BufEnter",
	},

	-- Treesitter
	{
		"nvim-treesitter",
		dep_of = "indent-blankline.nvim",
		on_require = "nvim-treesitter",
	},
	{ "nvim-treesitter-textobjects", dep_of = "nvim-treesitter" },
	{ "nvim-treesitter-textsubjects", dep_of = "nvim-treesitter" },

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

	-- Git signs
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
		lazy = not (#vim.fs.root(0, ".git") > 0),
	},
})
