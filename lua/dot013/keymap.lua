vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete to void" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Delete to void" })

vim.keymap.set("n", "<leader>w\\", "<cmd>:vsplit<cr>", { desc = "Split the windows vertically" })
vim.keymap.set("n", "<leader>w/", "<cmd>:split<cr>", { desc = "Split the windows horizontally" })

vim.keymap.set("n", "s=", "z=", { desc = "Suggest spelling currection" })
vim.keymap.set("n", "st", function()
	vim.o.spell = not vim.o.spell
end, { desc = "Toggle spelling correction" })

vim.keymap.set("n", "<leader>ee", vim.diagnostic.open_float, { desc = "Open diagnostics" })

-- ------

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(e)
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { desc = "[LSP] Rename", buffer = e.buf })
		vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { desc = "[LSP] Code action", buffer = e.buf })

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[LSP] Go to definition", buffer = e.buf })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "[LSP] Go to declaration", buffer = e.buf })
		vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "[LSP] Go to implementation", buffer = e.buf })
		vim.keymap.set(
			"n",
			"<leader>D",
			vim.lsp.buf.type_definition,
			{ desc = "[LSP] Go to type definition", buffer = e.buf }
		)
	end,
	group = vim.api.nvim_create_augroup("dot013_group", {}),
})

