return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup()
      require('nvim-dap-virtual-text').setup()
      require('dap-go').setup()
      require('dap-python').setup('python')

      dap.adapters.ruby = {
        type = 'executable',
        command = 'rdbg',
        args = { '-c', '--', 'bundle', 'exec', 'ruby' },
      }

      dap.configurations.ruby = {
        {
          type = 'ruby',
          request = 'launch',
          name = 'Debug Ruby file',
          program = '${file}',
        },
        {
          type = 'ruby',
          request = 'attach',
          name = 'Attach to process',
          port = 12345,
        },
      }

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

      vim.keymap.set('n', '<leader>xb', dap.toggle_breakpoint, { desc = 'Debug: [B]reakpoint toggle' })
      vim.keymap.set('n', '<leader>xc', dap.continue, { desc = 'Debug: [C]ontinue' })
      vim.keymap.set('n', '<leader>xi', dap.step_into, { desc = 'Debug: step [I]nto' })
      vim.keymap.set('n', '<leader>xo', dap.step_over, { desc = 'Debug: step [O]ver' })
      vim.keymap.set('n', '<leader>xO', dap.step_out, { desc = 'Debug: step [O]ut' })
      vim.keymap.set('n', '<leader>xr', dap.repl.open, { desc = 'Debug: [R]EPL' })
      vim.keymap.set('n', '<leader>xl', dap.run_last, { desc = 'Debug: run [L]ast' })
      vim.keymap.set('n', '<leader>xt', dapui.toggle, { desc = 'Debug: UI [T]oggle' })
      vim.keymap.set('n', '<leader>xx', dap.terminate, { desc = 'Debug: terminate/e[X]it' })
      vim.keymap.set({ 'n', 'v' }, '<leader>xh', function()
        require('dap.ui.widgets').hover()
      end, { desc = 'Debug: [H]over' })
    end,
  },
}
