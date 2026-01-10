vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

---- Plugins
require("dot.plugins")

require("dot.commands")
require("dot.keymaps")

-- Theme
vim.cmd.colorscheme("catppuccin")

require("nvim-treesitter.configs").setup({
	auto_install = false,
	highlight = { enable = true },
	indent = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<c-space>",
			node_incremental = "<c-space>",
			scope_incremental = "<c-s>",
			node_decremental = "<M-space>",
		},
	},
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["aa"] = "@parameter.outer",
				["ia"] = "@parameter.inner",
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},
	textsubjects = {
		enable = true,
		prev_selection = ",",
		keymaps = {
			["."] = "textsubjects-smart",
			[";"] = "textsubjects-container-outer",
			["i;"] = "textsubjects-container-inner",
		},
	},
	swap = {
		enable = true,
		swap_next = {
			["<leader>a"] = "@parameter.inner",
		},
		swap_previous = {
			["<leader>A"] = "@parameter.inner",
		},
	},
	playground = {
		enable = true,
		disable = {},
		updatetime = 25,
		persist_queries = false,
		keybindings = {
			toggle_query_editor = "o",
			toggle_hl_groups = "i",
			toggle_injected_languages = "t",
			toggle_anonymous_nodes = "a",
			toggle_language_display = "I",
			focus_language = "f",
			unfocus_language = "F",
			update = "R",
			goto_node = "<cr>",
			show_help = "?",
		},
	},
	query_linter = {
		enable = true,
		use_virtual_text = true,
		lint_events = { "BugWrite", "CursorHold" },
	},
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("dot-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("dot-lsp-attach-autocmds", { clear = true }),
	callback = function(e)
		local client = vim.lsp.get_client_by_id(e.data.client_id)

		-- Highlight references of word under cursor when it rests for a little while
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, e.buf) then
			local highlight_augroup = vim.api.nvim_create_augroup("dot-lsp-highlight", { clear = false })

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = e.buf,
				callback = vim.lsp.buf.document_highlight,
				group = highlight_augroup,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = e.buf,
				callback = vim.lsp.buf.clear_references,
				group = highlight_augroup,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				callback = function(e2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "dot-lsp-attach-autocmds", buffer = e2.buf })
				end,
				group = vim.api.nvim_create_augroup("dot-lsp-detach-autocmds", { clear = true }),
			})
		end

		-- Toggle inlay hints
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, e.buf) then
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = e.buf }))
			end, { desc = "LSP: [T]oggle Inlay [H]ints" })
		end
	end,
})
