require("dot013.options")
require("dot013.tweaks")
require("dot013.grip")

vim.g.lze = {
	--@type fun(name: string)
	load = vim.cmd.packadd,
	--@type boolean
	verbose = true,
}

require("lze").load("dot013.plugins")

require("dot013.keymap")
