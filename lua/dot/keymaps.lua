vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-l>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>w", ":lua require('harpoon'):list():add()<cr>", { desc = "Harpoon: Add file to list" })
vim.keymap.set("n", "<C-p>", ":lua require('harpoon'):list():prev()<cr>", { desc = "Harpoon: Previous file" })
vim.keymap.set("n", "<C-n>", ":lua require('harpoon'):list():next()<cr>", { desc = "Harpoon: Next file" })
vim.keymap.set("n", "<leader>e", ":lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<cr>", {
	desc = "Harpoon: Add file to list",
})

vim.keymap.set("n", "<C-e>", ":Ex<cr>", { desc = "Open file manager" })

-- Fuzzy find
vim.keymap.set("n", "ff", ":lua require('telescope.builtin').find_files()<cr>", { desc = "Telescope: [F]ind [F]iles" })
vim.keymap.set("n", "fw", ":lua require('telescope.builtin').live_grep()<cr>", { desc = "Telescope: [F]ind [W]ord" })
vim.keymap.set("n", "/", ":lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", {
	desc = "Telescope: Find in current buffer",
})

-- Spelling

vim.keymap.set("n", "s=", "z=", { desc = "Suggest spelling currection" })
vim.keymap.set("n", "st", function()
	vim.o.spell = not vim.o.spell
end, { desc = "Toggle spelling correction" })

-- Language Server Protocol & Actions
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>t", vim.diagnostic.open_float, { desc = "Open diagnostic" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(e)
		---@param lhs string
		---@param rhs string|function
		---@param desc string
		---@param mode string|string[]?
		local function map(lhs, rhs, desc, mode)
			vim.keymap.set(mode or "n", lhs, rhs, { buffer = e.buf, desc = "LSP: " .. desc })
		end

		map("gn", vim.lsp.buf.rename, "Re[n]ame")
		map("ga", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("gr", ":lua require('telescope.builtin').lsp_references()<cr>", "[G]oto [R]eferences")
		map("gi", ":lua require('telescope.builtin').lsp_implementations()<cr>", "[G]oto [I]mplementation")
		map("gd", ":lua require('telescope.builtin').lsp_definitions()<cr>", "[G]oto [D]efinition")
		map("gt", ":lua require('telescope.builtin').lsp_type_definitions()<cr>", "[G]oto [T]ype Definition")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration<cr>")
		map("gO", ":lua require('telescope.builtin').lsp_document_symbols()<cr>", "[O]pen Document Symbols")
		map("gW", ":lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", "Open [W]orkspace Symbols")
	end,
	group = vim.api.nvim_create_augroup("dot-lsp-attach-keymaps", { clear = true }),
})

-- Debugger
vim.keymap.set("n", "<leader>b", ":lua require('dap').toggle_breakpoint()<cr>", {
	desc = "Debugger: Toggle [B]reakpointn",
})
vim.keymap.set("n", "<F5>", ":lua require('dap').continue()<cr>", { desc = "Debugger: Continue debugger" })
vim.keymap.set("n", "<F8>", ":lua require('dap').terminate()<cr>", { desc = "Debugger: Terminate debugger" })
vim.keymap.set("n", "<leader>C", ":lua require('dap').clear_breakpoints()<cr>", {
	desc = "Debugger: Clear all breakpoints",
})
vim.keymap.set("n", "<leader>xu", ":lua require('dapui').toggle()<cr>", { desc = "Debugger: Toggle debugger [U]I" })
vim.keymap.set("n", "<leader>K", ":lua require('dapui').eval(nil, { enter=true })<cr>", {
	desc = "Debugger: Toggle debugger [U]I",
})

-- Tweaks
vim.keymap.set("n", "J", "mzJ`z") -- Move when highlighted
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Make cursor stay in place when jumping
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
