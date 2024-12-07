local function js_fmt(bufnr)
	local f = {}

	if require("conform").get_formatter_info("prettierd", bufnr).available then
		table.insert(f, "prettierd")
	elseif require("conform").get_formatter_info("prettier", bufnr).available then
		table.insert(f, "prettier")
	end

	if require("conform").get_formatter_info("eslint_d", bufnr).available then
		table.insert(f, "eslint_d")
	end

	if require("conform").get_formatter_info("deno_fmt", bufnr).available then
		table.insert(f, "deno_fmt")
	end

	return f
end

local formatters_by_ft = {
	["lua"] = { "stylua" },
	["nix"] = { "alejandra" },
	["rust"] = { "rustfmt", lsp_format = "fallback" },

	["go"] = function(bufnr)
		local f = {}

		if require("conform").get_formatter_info("gofumpt", bufnr).available then
			table.insert(f, "gofumpt")
		else
			table.insert(f, "gofmt")
		end

		if require("conform").get_formatter_info("golines", bufnr).available then
			table.insert(f, "golines")
		elseif require("conform").get_formatter_info("goimports", bufnr).available then
			table.insert(f, "goimports")
		end

		return f
	end,

	["javascript"] = js_fmt,
	["javascriptreact"] = js_fmt,
	["typescript"] = js_fmt,
	["typescriptreact"] = js_fmt,
	["json"] = function(bufnr)
		return { table.unpack(js_fmt(bufnr)), "jq" }
	end,

	["*"] = { "codespell" },
	["_"] = { "trim_whitespace" },
}

-- go = {
-- 	function()
-- 		if vim.fn.executable("gofumpt") == 1 then
-- 			return require("formatter.filetypes.go").gofumpt()
-- 		end
-- 		return require("formatter.filetypes.go").gofmt()
-- 	end,
-- 	function()
-- 		if vim.fn.executable("golines") == 1 then
-- 			return require("formatter.filetypes.go").golines()
-- 		elseif vim.fn.executable("goimports") == 1 then
-- 			return require("formatter.filetypes.go").goimports()
-- 		end
-- 		return nil
-- 	end,
-- },
return {
	"conform.nvim",
	ft = (function()
		local fts = {}
		for k, _ in pairs(formatters_by_ft) do
			table.insert(fts, k)
		end
		return fts
	end)(),
	after = function()
		require("conform").setup({
			formatters_by_ft = formatters_by_ft,
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
	end,
}
