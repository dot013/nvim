return {
	{
		"blink-cmp",
		event = "InsertEnter",
		dep_of = { "nvim-lspconfig" },
		after = function()
			require("blink.cmp").setup({
				completion = {
					list = {
						selection = "auto_insert",
					},
				},
				documentation = {
					auto_show = true,
				},
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
					completion = {
						enabled_providers = {
							"lsp",
							"path",
							"snippets",
							"buffer",
						},
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
}