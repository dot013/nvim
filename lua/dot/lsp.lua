---@type lze.PluginSpec[] | { lsp: vim.lsp.Config }[]
return {
	-- Language Server Providers
	{
		"clangd",
		lsp = { filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
	},
	{
		"cssls",
		lsp = { filetypes = { "css", "scss", "less" } },
	},
	{
		"denols",
		lsp = {
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
		},
	},
	{
		"docker-language-server",
		lsp = {
			filetypes = {
				"dockerfile",
				"yaml.docker-compose",
			},
		},
	},
	{
		"emmet_language_server",
		lsp = {
			filetypes = {
				"astro",
				"css",
				"eruby",
				"html",
				"htmlangular",
				"htmldjango",
				"javascriptreact",
				"less",
				"pug",
				"sass",
				"scss",
				"svelte",
				"templ",
				"typescriptreact",
				"vue",
			},
		},
	},
	{
		"eslint",
		lsp = {
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
				"svelte",
				"astro",
				"htmlangular",
			},
		},
	},
	{
		"golangci_lint_ls",
		lsp = {
			filetypes = { "go", "gomod" },
		},
	},
	{
		"gopls",
		lsp = {
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
		},
	},
	{
		"html",
		lsp = {
			filetypes = { "html", "templ" },
		},
	},
	{
		"htmx",
		filetypes = {
			-- html
			"aspnetcorerazor",
			"astro",
			"astro-markdown",
			"blade",
			"clojure",
			"django-html",
			"htmldjango",
			"edge",
			"eelixir", -- vim ft
			"elixir",
			"ejs",
			"erb",
			"eruby", -- vim ft
			"gohtml",
			"gohtmltmpl",
			"haml",
			"handlebars",
			"hbs",
			"html",
			"htmlangular",
			"html-eex",
			"heex",
			"jade",
			"leaf",
			"liquid",
			"markdown",
			"mdx",
			"mustache",
			"njk",
			"nunjucks",
			"php",
			"razor",
			"slim",
			"twig",
			-- js
			"javascript",
			"javascriptreact",
			"reason",
			"rescript",
			"typescript",
			"typescriptreact",
			-- mixed
			"vue",
			"svelte",
			"templ",
		},
	},
	{
		"jsonls",
		lsp = {
			filetypes = { "json", "jsonc" },
		},
	},
	{
		"lemminx",
		lsp = {
			filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "xhtml" },
		},
	},
	{
		"ltex",
		lsp = {
			settings = {
				enable = true,
			},
		},
	},
	{
		"lua_ls",
		lsp = {
			filetypes = { "lua" },
			on_attach = function(client)
				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config") and vim.loop.fs_stat(path .. "/.luarc.json")
						or vim.loop.fs_stat(path .. "/.luarc.jsonc")
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
						},
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				})
			end,
			settings = {
				Lua = {
					codeLens = { enable = true },
					hint = { enable = true, semicolon = "Disable" },
					telemetry = { enabled = false },
				},
			},
		},
	},
	{
		"marksman",
		lsp = {
			filetypes = { "markdown", "markdown.mdx" },
		},
	},
	{
		"nil_ls",
		lsp = {
			filetypes = { "nix" },
			single_file_support = true,
		},
	},
	{
		"rust_analyzer",
		lsp = {
			filetypes = { "rust" },
			settings = {
				["rust_analyzer"] = {
					diagnostics = {
						enable = true,
					},
				},
			},
		},
	},
	{
		"tailwindcss",
		lsp = {
			filetypes = {
				-- html
				"aspnetcorerazor",
				"astro",
				"astro-markdown",
				"blade",
				"clojure",
				"django-html",
				"htmldjango",
				"edge",
				"eelixir", -- vim ft
				"elixir",
				"ejs",
				"erb",
				"eruby", -- vim ft
				"gohtml",
				"gohtmltmpl",
				"haml",
				"handlebars",
				"hbs",
				"html",
				"htmlangular",
				"html-eex",
				"heex",
				"jade",
				"leaf",
				"liquid",
				"markdown",
				"mdx",
				"mustache",
				"njk",
				"nunjucks",
				"php",
				"razor",
				"slim",
				"twig",
				-- css
				"css",
				"less",
				"postcss",
				"sass",
				"scss",
				"stylus",
				"sugarss",
				-- js
				"javascript",
				"javascriptreact",
				"reason",
				"rescript",
				"typescript",
				"typescriptreact",
				-- mixed
				"vue",
				"svelte",
				"templ",
			},
		},
	},
	{
		"ts_ls",
		lsp = {
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
		},
	},
}

--[[ local M = {}

M.opts = {
	keymaps = require("dot.keymaps"),
	augroup = vim.api.nvim_create_augroup("dot_group_lsp", {}),
}

function M.setup(opts)
	M.opts = vim.tbl_extend("force", M.opts, opts or {})

	local keymaps = M.opts.keymaps

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(e)
			keymaps.mapn("<leader>r", vim.lsp.buf.rename, { desc = "(LSP) [r]ename", buffer = e.buf })
			keymaps.mapn("<leader>a", vim.lsp.buf.code_action, { desc = "(LSP) Code [a]ction", buffer = e.buf })

			keymaps.mapn("gd", vim.lsp.buf.definition, { desc = "(LSP) [g]o to [d]efinition", buffer = e.buf })
			keymaps.mapn("gD", vim.lsp.buf.declaration, { desc = "(LSP) [g]o to [D]efinition", buffer = e.buf })
			keymaps.mapn("gI", vim.lsp.buf.implementation, { desc = "(LSP) [g]o to [I]mplementation", buffer = e.buf })
			keymaps.mapn("gt", vim.lsp.buf.type_definition, {
				desc = "(LSP) [g]o to [t]ype definition",
				buffer = e.buf,
			})
		end,
		group = M.opts.augroup,
	})
end

function M.setup(name) end ]]
