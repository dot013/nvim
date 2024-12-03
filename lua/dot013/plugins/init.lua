return {
	{
		"plenary.nvim",
		dep_of = {
			"telescope.nvim",
		},
	},
	{
		"telescope-fzf-native.nvim",
		dep_of = {
			"telescope.nvim"
		},
	},
	{
		"telescope.nvim",
		cmd = {
			"Telescope",
		},
		keys = {
			{ "<leader><space>", function() return require("telescope.builtin").buffers end, "Find existing buffers" },
			{
				"/",
				function() return require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					windblend = 10,
					previewer = false,
				})) end,
				"Find in current buffer"
			},
			{ "fr", ":lua require('telescope.builtin').oldfiles()<cr>", "Find recent files" },
			{ "ff", "<cmd>Telescope find_files<cr>", "Find files" },
			{ "fw", ":lua require('telescope.builtin').grep_string()<cr>", "Find word" },
			{ "<leader>fw", "<cmd>Telescope live_grep<cr>","Find word in all files" },
			{ "gf", ":lua require('telescope.builtin').git_files()<cr>", "Git files" },
			{ "fs", ":lua require('telescope.builtin').resume()<cr>", "Resume search" },
		},
		after = function ()
			require("telescope").setup()
			require("telescope").load_extension("fzf")
		end,
	}
}
