return {
	{
		"aw-watcher.nvim",
		after = function()
			require("aw_watcher").setup({})
		end
	}
}
