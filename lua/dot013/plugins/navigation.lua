return {
	-- File fuzzy finder
	{
		"telescope.nvim",
		cmd = {
			"Telescope",
		},
		dep_of = { "harpoon2" },
		keys = {
			{
				"<leader><space>",
				":lua require('telescope.builtin').buffers()<cr>",
				desc = "[Telescope] Find existing buffers",
			},
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
				desc = "[Telescope] Find in current buffer",
			},
			{ "fr", ":lua require('telescope.builtin').oldfiles()<cr>", desc = "[Telescope] Find recent files" },
			{
				"ff",
				function()
					if require("dot013.utils").is_in_cwd(".git") then
						return require("telescope.builtin").git_files()
					else
						return require("telescope.builtin").find_files()
					end
				end,
				desc = "[Telescope] Git files",
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files({ no_ignore = true, no_ignore_parent = true, hidden = true })
				end,
				desc = "[Telescope] Find files",
			},
			{ "fw", ":lua require('telescope.builtin').grep_string()<cr>", desc = "[Telescope] Find word" },
			{ "<leader>fw", "<cmd>Telescope live_grep<cr>", desc = "[Telescope] Find word in all files" },
			{ "fs", ":lua require('telescope.builtin').resume()<cr>", desc = "[Telescope] Resume search" },
		},
		after = function()
			require("telescope").setup()
			require("telescope").load_extension("fzf")
		end,
	},
	{ "telescope-fzf-native.nvim", dep_of = { "telescope.nvim" } },

	-- File quick switching
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
					desc = "[Harpoon] Append to list",
				},
				{
					"<C-e>",
					function()
						toggle_telescope(harpoon():list())
					end,
					desc = "[Harpoon] Open quick menu",
				},
				{
					"<C-E>",
					function()
						harpoon().ui:toggle_quick_menu(harpoon():list())
					end,
					desc = "[Harpoon] Open quick edit menu",
				},
				{
					"<C-p>",
					function()
						harpoon():list():prev()
					end,
					desc = "[Harpoon] Jump to previous item",
				},
				{
					"<C-n>",
					function()
						harpoon():list():next()
					end,
					desc = "[Harpoon] Jump to next item",
				},
			}
		end)(),
	},

	-- Visual jump marks
	{
		"marks.nvim",
		after = function()
			require("marks").setup({
				refresh_interval = 250,
			})
		end,
	},

	-- Tmux panel jumping
	{
		"tmux.nvim",
		keys = {
			{ "<C-h>", ":lua require('tmux').move_left()<cr>", desc = "[Tmux] Move to left pane" },
			{ "<C-j>", ":lua require('tmux').move_bottom()<cr>", desc = "[Tmux] Move to bottom pane" },
			{ "<C-k>", ":lua require('tmux').move_top()<cr>", desc = "[Tmux] Move to top pane" },
			{ "<C-l>", ":lua require('tmux').move_right()<cr>", desc = "[Tmux] Move to right pane" },
		},
		after = function()
			require("tmux").setup()
		end,
	},
}
