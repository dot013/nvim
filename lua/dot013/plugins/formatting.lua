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

	if
		require("conform").get_formatter_info("deno_fmt", bufnr).available
		and (require("dot013.utils").is_in_cwd("deno.json") or require("dot013.utils").is_in_cwd("deno.jsonc"))
	then
		table.insert(f, "deno_fmt")
	end

	return f
end

return {
	-- Formatters support
	{
		"conform.nvim",
		event = { "InsertLeave", "TextChanged" },
		after = function()
			require("conform").setup({
				formatters_by_ft = {
					-- Simple formatters
					lua = { "stylua" },
					nix = { --[[ "nixcmdfmt", ]] "alejandra", stop_after_first = true },
					rust = { "rustfmt", lsp_format = "fallback" },
					sh = { "shellharden", "shfmt" },
					xml = { "xmllint", "xmltidy" },
					xhtml = { "xmllint", "xmltidy" },
					markdown = { "mdfmt" },

					html = { "prettierd", "prettier", stop_after_first = true },
					css = { "prettierd", "prettier", stop_after_first = true },
					yaml = { "prettierd", "prettier", stop_after_first = true },

					-- Golang's formatters used by priority
					go = function(bufnr)
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
					templ = { "templ" },

					-- JavaScript's ecosystem
					javascript = js_fmt,
					javascriptreact = js_fmt,
					typescript = js_fmt,
					typescriptreact = js_fmt,
					json = function(bufnr)
						local fmts = js_fmt(bufnr)
						if fmts then
							return fmts
						end
						return { "jq" }
					end,

					-- Fallback for any filetype
					["*"] = { "codespell" },
					["_"] = { "trim_whitespace" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
				formatters = {
					mdfmt = {
						command = "mdfmt",
					},
					xmltidy = {
						inherit = false,
						-- Uses HTML Tidy
						command = "tidy",
						args = { "-xml", "-indent", "yes", "2", "-wrap", "100", "-" },
					},
					--[[ nixcmdfmt = {
						inherit = false,
						stdin = false,
						cwd = require("conform.util").root_file({ "flake.nix" }),
						require_cwd = true,
						command = "nix",
						args = { "fmt", "$FILENAME" },
					}, ]]
				},
			})
		end,
	},
}
