local M = {}

M.is_in_cwd = function(name)
	local cwd = vim.fn.getcwd()
	local cwdContent = vim.split(vim.fn.glob(cwd .. "/*"), "\n", { trimempty = true })
	local hiddenCwdContent = vim.split(vim.fn.glob(cwd .. "/.*"), "\n", { trimempty = true })

	for _, f in pairs(hiddenCwdContent) do
		table.insert(cwdContent, f)
	end

	local fullName = cwd .. "/" .. name

	for _, f in pairs(cwdContent) do
		if f == fullName then
			return true
		end
	end

	return false
end

return M
