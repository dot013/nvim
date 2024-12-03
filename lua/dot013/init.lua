require("dot013.options")

vim.g.lze = {
	--@type fun(name: string)
	load = vim.cmd.packadd,
	--@type boolean
	verbose = true,
}

require("lze").load("dot013.plugins")
