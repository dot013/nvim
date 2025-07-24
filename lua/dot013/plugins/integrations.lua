return {
	{
		"aw-watcher.nvim",
		after = function()
			require("aw_watcher").setup({
				aw_server = {
					host = "100.69.8.56",
					port = 5600,
				}
			})
		end
	}
}
