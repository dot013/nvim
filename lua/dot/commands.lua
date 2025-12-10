-- Grip markdown reader

---@type integer?
local grip_channel = nil
vim.api.nvim_create_user_command("GripStart", function()
	if grip_channel then
		return
	end

	local file = vim.api.nvim_buf_get_name(0)
	local cmd = "go-grip -b false -H 0.0.0.0 " .. file

	grip_channel = vim.fn.jobstart(cmd, {
		on_stderr = function(_, err)
			if grip_channel == nil then
				return
			end

			vim.fn.jobstop(grip_channel)

			local content = table.concat(err, "\n")
			if #content > 0 then
				vim.notify("Grip error: " .. content, vim.log.levels.ERROR, {})
			end
		end,
		on_exit = function()
			if grip_channel == nil then
				return
			end

			vim.fn.chanclose(grip_channel)
			grip_channel = nil
		end,
		stderr_buffered = true,
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
