-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

local grip_channel = nil
vim.api.nvim_create_user_command("GripStart", function()
	if grip_channel then
		return
	end

	local file = vim.api.nvim_buf_get_name(0)

	local cmd = "go-grip -b false -H 0.0.0.0 " .. file

	grip_channel = vim.fn.jobstart(cmd, {
		stderr_buffered = true,
		on_stderr = function(_, err)
			vim.fn.jobstop(grip_channel)

			local content = table.concat(err, "\n")
			if content:len() > 0 then
				vim.api.nvim_notify("Grip error: " .. content, vim.log.levels.ERROR, {})
			end
		end,
		on_exit = function()
			vim.fn.chanclose(grip_channel)
			grip_channel = nil
		end,
	})
end, {})

vim.api.nvim_create_user_command("GripStop", function()
	if grip_channel then
		vim.fn.jobstop(grip_channel)
	end
end, {})

vim.api.nvim_create_autocmd({ "QuitPre", "BufDelete" }, {
	callback = function()
		if grip_channel then
			vim.fn.jobstop(grip_channel)
		end
	end,
})

-- Move when highlighted
vim.keymap.set("n", "J", "mzJ`z")

-- Make cursor stay in place when using J
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Just to be sure
vim.keymap.set("n", "<C-c>", "<Esc>")
-- Don't press Q
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { desc = "Nop", silent = true })

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
