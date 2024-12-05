return {
	{
		"telescope.nvim",
		cmd = {
			"Telescope",
		},
		keys = {
			{ "<leader><space>", ":lua require('telescope.builtin').buffers<cr>", "[Telescope] Find existing buffers" },
			{
				"/",
				function()
					return require("telescope.builtin").current_buffer_fuzzy_find(
						require("telescope.themes").get_dropdown({
							windblend = 10,
							previewer = false,
						})
					)
				end,
				"[Telescope] Find in current buffer",
			},
			{ "fr", ":lua require('telescope.builtin').oldfiles()<cr>", "[Telescope] Find recent files" },
			{ "ff", "<cmd>Telescope find_files<cr>", "[Telescope] Find files" },
			{ "fw", ":lua require('telescope.builtin').grep_string()<cr>", "[Telescope] Find word" },
			{ "<leader>fw", "<cmd>Telescope live_grep<cr>", "[Telescope] Find word in all files" },
			{ "gf", ":lua require('telescope.builtin').git_files()<cr>", "[Telescope] Git files" },
			{ "fs", ":lua require('telescope.builtin').resume()<cr>", "[Telescope] Resume search" },
		},
		after = function()
			require("telescope").setup()
			require("telescope").load_extension("fzf")
		end,
	},
	-- Telescope dependencies
	{ "telescope-fzf-native.nvim", dep_of = { "telescope.nvim" } },

}
