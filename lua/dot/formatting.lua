local conform = require("conform")

local prettier = { "prettierd", "prettier", stop_after_first = true }

local function javascript_formatters(bufnr)
	local formatters = {}

	if conform.get_formatter_info("deno_fmt", bufnr).available then
		table.insert(formatters, "deno_fmt")
	end

	if conform.get_formatter_info("prettierd", bufnr).available then
		table.insert(formatters, "prettierd")
	elseif require("conform").get_formatter_info("prettier", bufnr).available then
		table.insert(formatters, "prettier")
	end

	if conform.get_formatter_info("eslint_d", bufnr).available then
		table.insert(formatters, "eslint_d")
	end

	return formatters
end

conform.setup({
	formatters_by_ft = {
		css = prettier,
		gdscript = { "gdformat" },
		go = function(bufnr)
			local formatters = {}

			if conform.get_formatter_info("gofumpt", bufnr).available then
				table.insert(formatters, "gofumpt")
			else
				table.insert(formatters, "gofmt")
			end

			if conform.get_formatter_info("golines", bufnr).available then
				table.insert(formatters, "golines")
			end

			if conform.get_formatter_info("goimports", bufnr).available then
				table.insert(formatters, "gofmt")
			end

			if conform.get_formatter_info("golangci-lint").available then
				table.insert(formatters, "golangci-lint")
			end

			return formatters
		end,
		html = prettier,
		javascript = javascript_formatters,
		javascriptreact = javascript_formatters,
		typescript = javascript_formatters,
		typescriptreact = javascript_formatters,
		json = function(bufnr)
			return #javascript_formatters(bufnr) and javascript_formatters(bufnr) or { "jq" }
		end,
		less = prettier,
		lua = { "stylua" },
		markdownn = { "mdfmt" },
		nix = { "alejandra", stop_after_first = true }, -- TODO: Support nix fmt command when flake.nix formatter is enabled
		rust = { "rustfmt", lsp_format = "fallback" },
		scss = prettier,
		sh = { "shellharden", "shfmt" },
		templ = { "templ" },
		yaml = prettier,
		xhtml = { "xmllint", "xmltidy", stop_after_first = true },
		xml = { "xmllint", "xmltidy", stop_after_first = true },

		["*"] = { "codespell" },
		["_"] = { "trim_whitespace" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formaters = {
		mdfmt = { command = "mdfmt" },
		xmltidy = { inherit = false, command = "tidy", args = { "-xml", "-indent", "yes", "2", "-wrap", "100", "-" } }, -- INFO: Uses HTML Tidy
	},
})
