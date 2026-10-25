return {
  "mfussenegger/nvim-dap",
  dependencies = {
    { "leoluz/nvim-dap-go", config = true },
    {
      "mfussenegger/nvim-dap-python",
      config = function()
        require("dap-python").setup("python")
      end,
    },
    { "suketa/nvim-dap-ruby", config = true },
  },
  keys = {
    { "<leader>xb", function() require("dap").toggle_breakpoint() end, desc = "Debug: breakpoint toggle" },
    { "<leader>xc", function() require("dap").continue() end, desc = "Debug: continue" },
    { "<leader>xi", function() require("dap").step_into() end, desc = "Debug: step into" },
    { "<leader>xo", function() require("dap").step_over() end, desc = "Debug: step over" },
    { "<leader>xO", function() require("dap").step_out() end, desc = "Debug: step out" },
    { "<leader>xr", function() require("dap").repl.open() end, desc = "Debug: REPL" },
    { "<leader>xl", function() require("dap").run_last() end, desc = "Debug: run last" },
    { "<leader>xt", function() require("dapui").toggle() end, desc = "Debug: UI toggle" },
    { "<leader>xx", function() require("dap").terminate() end, desc = "Debug: terminate" },
    { "<leader>xh", function() require("dap.ui.widgets").hover() end, desc = "Debug: hover", mode = { "n", "v" } },
    { "<leader>xe", function() require("dapui").eval() end, desc = "Debug: eval", mode = { "n", "v" } },
  },
}
