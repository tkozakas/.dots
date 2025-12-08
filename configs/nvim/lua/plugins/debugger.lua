return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup UI
			dapui.setup()

			-- Setup virtual text
			require("nvim-dap-virtual-text").setup()

			-- Setup Go debugger
			require("dap-go").setup()

			-- Setup Python debugger
			require("dap-python").setup("python")

			-- Setup Ruby debugger (using rdbg)
			dap.adapters.ruby = {
				type = "executable",
				command = "rdbg",
				args = { "-c", "--", "bundle", "exec", "ruby" },
			}

			dap.configurations.ruby = {
				{
					type = "ruby",
					request = "launch",
					name = "Debug Ruby file",
					program = "${file}",
				},
				{
					type = "ruby",
					request = "attach",
					name = "Attach to process",
					port = 12345,
				},
			}

			-- Auto open/close UI
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

			-- Keymaps
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug [B]reakpoint toggle" })
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug step [I]nto" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug step [O]ver" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[D]ebug step [O]ut" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[D]ebug [R]EPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[D]ebug run [L]ast" })
			vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "[D]ebug UI [T]oggle" })
			vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "[D]ebug terminate/e[X]it" })
			vim.keymap.set({ "n", "v" }, "<leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { desc = "[D]ebug [H]over" })
		end,
	},
}
