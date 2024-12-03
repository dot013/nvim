
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.g.loaded_netrw = 1;
-- vim.g.loaded_netrwPlugin = 1;

vim.wo.number = true
vim.o.mouse = "a"

-- True colors
vim.o.termguicolors = true

-- Enable filetype plugins
vim.o.filetype = "on"

-- Enable spell checking by default
vim.o.spell = true

-- Set relative line numbers
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "number"

-- Set indentation
vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
-- vim.o.expandtab = 4;
vim.o.breakindent = true

-- Scroll off
vim.o.scrolloff = 10

-- Line length column
vim.o.colorcolumn = "80"

-- Sync NeoVim and OS clipboards
vim.o.clipboard = "unnamedplus"

-- Highlight search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive search, unless \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.wo.signcolumn = "yes"

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.completeopt = "menuone,noselect"
