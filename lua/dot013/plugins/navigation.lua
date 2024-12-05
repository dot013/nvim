return {
	{
		"telescope.nvim",
		cmd = {
			"Telescope",
		},
		dep_of = { "harpoon2" },
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

	{
		"harpoon2",
		keys = (function()
			local h = nil
			local function harpoon()
				if h == nil then
					h = require("harpoon")
					h:setup()
				end
				return h
			end
			local function toggle_telescope(harpoon_files)
				local telescopeConf = require("telescope.config").values
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end
				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({ results = file_paths }),
						previewer = telescopeConf.file_previewer({}),
						sorter = telescopeConf.generic_sorter({}),
					})
					:find()
			end

			return {
				{
					"<leader>w",
					function()
						harpoon():list():add()
					end,
					"[Harpoon] Append to list",
				},
				{
					"<C-e>",
					function()
						toggle_telescope(harpoon():list())
					end,
					"[Harpoon] Open quick menu",
				},
				{
					"<C-E>",
					function()
						harpoon().ui:toggle_quick_menu(harpoon():list())
					end,
					"[Harpoon] Open quick edit menu",
				},
				{
					"<C-p>",
					function()
						harpoon():list():prev()
					end,
					"[Harpoon] Jump to previous item",
				},
				{
					"<C-n>",
					function()
						harpoon():list():next()
					end,
					"[Harpoon] Jump to next item",
				},
			}
		end)(),
	},
}
