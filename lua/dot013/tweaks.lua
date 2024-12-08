-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Move when highlighted
vim.keymap.set("n", "J", "mzJ`z")

-- Make cursor stay in place when using J
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Just to be sure
vim.keymap.set("n", "<C-c>", "<Esc>")
-- Don't press Q
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { desc = "Nop", silent = true })

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
