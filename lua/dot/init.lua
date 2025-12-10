vim.g.mapleader = " "
vim.g.maplocalleader = " "

---- Plugins
require("dot.plugins")

-- Filetype plugins
vim.o.filetype = "on"

-- Terminal
vim.o.termguicolors = true -- True colors
vim.g.have_nerd_font = true

---- Appearance

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "80"

-- Indentation
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.breakindent = true
vim.o.list = true
vim.opt.listchars = { tab = "│ ", trail = ".", nbsp = "␣" }

----

-- Mouse support
vim.o.mouse = "a"

-- Save undo history
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.inccommand = "split"

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.completeopt = "menuone,noselect"

-- Confirm on exit
vim.o.confirm = true

-- Diagnostics
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

