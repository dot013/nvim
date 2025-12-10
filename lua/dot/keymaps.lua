vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

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

		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("grr", ":lua require('telescope.builtin').lsp_references<cr>", "[G]oto [R]eferences")
		map("gri", ":lua require('telescope.builtin').lsp_implementations<cr>", "[G]oto [I]mplementation")
		map("grd", ":lua require('telescope.builtin').lsp_definitions", "[G]oto [D]efinition")
		map("grt", ":lua require('telescope.builtin').lsp_type_definitions", "[G]oto [T]ype Definition")
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("gO", ":lua require('telescope.builtin').lsp_document_symbols", "[O]pen Document Symbols")
		map("gW", ":lua require('telescope.builtin').lsp_dynamic_workspace_symbols", "Open [W]orkspace Symbols")
	end,
	group = vim.api.nvim_create_augroup("dot-lsp-attach-keymaps", { clear = true }),
})

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-l>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>w", ":lua require('harpoon'):list():add()<cr>", { desc = "Harpoon: Add file to list" })
vim.keymap.set("n", "<leader>e", ":lua require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())<cr>", {
	desc = "Harpoon: Add file to list",
})

vim.keymap.set(
	"n",
	"<C-e>",
	vim.fn.executable("yazi") and require("dot.tfm").open or ":Ex",
	{ desc = "Open file manager" }
)

-- Fuzzy find
vim.keymap.set("n", "ff", ":lua require('telescope.builtin').find_files()<cr>", { desc = "Telescope: [F]ind [F]iles" })
vim.keymap.set("n", "fw", ":lua require('telescope.builtin').live_grep()<cr>", { desc = "Telescope: [F]ind [W]ord" })
vim.keymap.set("n", "/", ":lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>", {
	desc = "Telescope: Find in current buffer",
})
