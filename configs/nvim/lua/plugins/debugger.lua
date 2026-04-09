return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
      'suketa/nvim-dap-ruby',
    },
    keys = {
      { '<leader>xb', function() require('dap').toggle_breakpoint() end, desc = 'Debug: [B]reakpoint toggle' },
      { '<leader>xc', function() require('dap').continue() end, desc = 'Debug: [C]ontinue' },
      { '<leader>xi', function() require('dap').step_into() end, desc = 'Debug: step [I]nto' },
      { '<leader>xo', function() require('dap').step_over() end, desc = 'Debug: step [O]ver' },
      { '<leader>xO', function() require('dap').step_out() end, desc = 'Debug: step [O]ut' },
      { '<leader>xr', function() require('dap').repl.open() end, desc = 'Debug: [R]EPL' },
      { '<leader>xl', function() require('dap').run_last() end, desc = 'Debug: run [L]ast' },
      { '<leader>xt', function() require('dapui').toggle() end, desc = 'Debug: UI [T]oggle' },
      { '<leader>xx', function() require('dap').terminate() end, desc = 'Debug: terminate/e[X]it' },
      { '<leader>xh', function() require('dap.ui.widgets').hover() end, desc = 'Debug: [H]over', mode = { 'n', 'v' } },
      { '<leader>xe', function() require('dapui').eval() end, desc = 'Debug: [E]val', mode = { 'n', 'v' } },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()
      require('nvim-dap-virtual-text').setup()
      require('dap-go').setup()
      require('dap-python').setup('python')
      require('dap-ruby').setup()

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
}
