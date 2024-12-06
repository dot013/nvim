return {
	{
		"nvim-dap",
		keys = {
			{ "<leader>b", ":lua require('dap').toggle_breakpoint()<cr>", "[Debugger] Toggle breakpoint" },
			{ "<leader>x", ":lua require('dap').continue()<cr>", "[Debugger] Continue debugger" },
			{ "<leader>X", ":lua require('dap').terminate()<cr>", "[Debugger] Terminate debugger" },
			{ "<leader>C", ":lua require('dap').clear_breakpoints()<cr>", "[Debugger] Clear all breakpoints" },
		},
		after = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
	{
		"nvim-dap-ui",
		dap_of = { "nvim-dap" },
		keys = {
			{ "<leader>xu", ":lua require('dapui').toggle()<cr>", "[Debugger] Toggle debugger UI" },
			{
				"<leader>K",
				":lua require('dapui').eval(nil, { enter = true })<cr>",
				"[Debugger] Eval var under cursor",
			},
		},
	},
	{ "nvim-dap-virtual-text", dep_of = { "nvim-dap" } },

	-- Language specific debuggers
	{ "nvim-dap-go", dep_of = { "nvim-dap" }, enabled = vim.fn.executable("delve") == 1 },
}
