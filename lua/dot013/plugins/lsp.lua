local lsps = {
	["cssls"] = {},
	["eslint"] = {},
	["denols"] = {},
	["lua_ls"] = {
		on_init = function(client)
			if client.workspace_folders then
				local path = client.workspace_folders[1].name
				if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
					return
				end
			end

			client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
				runtime = {
					version = "LuaJIT",
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
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},
	["gopls"] = {},
	["html"] = {},
	["htmx"] = {},
	["jsonls"] = {},
	["nil_ls"] = {},
	["tailwindcss"] = {},
	["templ"] = {},
	["ts_ls"] = {},
	["rust_analyzer"] = {},
}

return {
	-- Language Server Protocol (LSP) configuration
	{
		"nvim-lspconfig",
		after = function()
			local lsp = require("lspconfig")
			for k, v in pairs(lsps) do
				v.capabilities = require("blink.cmp").get_lsp_capabilities(v.capabilities)
				lsp[k].setup(v)
			end
		end,
	},
}
