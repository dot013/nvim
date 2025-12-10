-- Yazi file manager

if vim.fn.executable("yazi") then
	local PATH_CACHE = vim.fn.stdpath("cache")
	local PATH_SELECTED_FILES = PATH_CACHE .. "/tfm_selected_files"
	local function open_yazi(path_to_open, open_mode)
		local file_to_focus = path_to_open or vim.fn.expand("%")
		if file_to_focus ~= "" then
			file_to_focus = string.format('"%s"', file_to_focus)
		end

		local buffers_for_existing_files = {}
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.fn.buflisted(buf) == 1 then
				local buf_name = vim.fn.bufname(buf)
				if vim.fn.filereadable(buf_name) == 1 then
					table.insert(buffers_for_existing_files, buf_name)
				end
			end
		end

		-- Clean leftover files
		vim.fn.delete(PATH_SELECTED_FILES)

		local cmd = string.format("yazi --chooser-file %s %s", PATH_SELECTED_FILES, file_to_focus)
		local last_win = vim.api.nvim_get_current_win()

		-- Open window
		local buf = vim.api.nvim_create_buf(false, true)
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			border = "rounded",
			style = "minimal",
			height = vim.o.lines,
			width = vim.o.columns,
			row = 0.5 - 1,
			col = 0.5,
		})
		vim.api.nvim_set_option_value("winhl", "NormalFloat:Normal", { win = win })
		vim.api.nvim_set_option_value("filetype", "tfm", { buf = buf })

		local group = vim.api.nvim_create_augroup("tfm_window", { clear = true })
		vim.api.nvim_create_autocmd("VimResized", {
			group = group,
			buffer = buf,
			callback = function()
				vim.api.nvim_win_set_config(
					win,
					vim.tbl_deep_extend("force", vim.api.nvim_win_get_config(win), {
						height = vim.o.lines,
						width = vim.o.columns,
						row = 0.5 - 1,
						col = 0.5,
					})
				)
			end,
		})

		local on_exit = function(_, code, _)
			if code ~= 0 then
				return
			end

			vim.api.nvim_win_close(0, true)
			vim.api.nvim_set_current_win(last_win)

			if vim.fn.filereadable(PATH_SELECTED_FILES) ~= 1 then
				return
			end

			local selected_files = vim.fn.readfile(PATH_SELECTED_FILES)
			local edit = open_mode or vim.cmd.edit
			local directories = {}

			for _, path in ipairs(selected_files) do
				if vim.fn.isdirectory(path) == 1 then
					table.insert(directories, path)
				else
					edit(path)
				end
			end

			local _, first_dir = next(directories)
			if first_dir ~= nil then
				open_yazi(first_dir, open_mode)
			end

			-- Clean leftover files
			vim.fn.delete(PATH_SELECTED_FILES)

			-- Close empty buffers
			for _, buf in ipairs(buffers_for_existing_files) do
				if vim.fn.filereadable(buf) ~= 1 then
					vim.cmd.bdelete(buf)
				end
			end
		end

		vim.fn.jobstart(cmd, {
			term = true,
			on_exit = on_exit,
		})

		vim.cmd.startinsert()
	end

	vim.api.nvim_create_user_command("Ex", function()
		open_yazi()
	end, {})
end

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
