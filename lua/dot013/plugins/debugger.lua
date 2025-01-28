return {
	-- DAP Debugger support
	{
		"nvim-dap",
		dap_of = {
			"nvim-dap-ui",
			"nvim-dap-virtual-text",
			"nvim-dap-go",
		},
		keys = {
			{ "<leader>b", ":lua require('dap').toggle_breakpoint()<cr>", "[Debugger] Toggle breakpoint" },
			{ "<leader>x", ":lua require('dap').continue()<cr>", "[Debugger] Continue debugger" },
			{ "<leader>X", ":lua require('dap').terminate()<cr>", "[Debugger] Terminate debugger" },
			{ "<leader>C", ":lua require('dap').clear_breakpoints()<cr>", "[Debugger] Clear all breakpoints" },
			-- UI
			{ "<leader>xu", ":lua require('dapui').toggle()<cr>", "[Debugger] Toggle debugger UI" },
			{
				"<leader>K",
				":lua require('dapui').eval(nil, { enter = true })<cr>",
				"[Debugger] Eval var under cursor",
			},
		},
		after = function()
			local dap = require("dap")

			local dapui = require("dapui")
			dapui.setup()

			local dapvt = require("nvim-dap-virtual-text")
			dapvt.setup()

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

			-- Languages
			local dapgo = require("dap-go")
			dapgo.setup()
		end,
	},

	-- Debugger UI
	{
		"nvim-dap-ui",
		dep_of = { "nvim-dap" },
	},
	{
		"nvim-nio",
		dep_of = { "nvim-dap-ui" },
	},

	-- Debugger state hover
	{
		"nvim-dap-virtual-text",
		dep_of = { "nvim-dap" },
	},

	-- Language specific debuggers
	{
		"nvim-dap-go",
		dep_of = { "nvim-dap" },
	},
}
