return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        },
      })
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    config = function()
      -- copilot.lua needs node >= 22; the system node is v20, so prefer
      -- mise's LTS install and fall back to PATH node.
      local node = vim.fn.expand('~/.local/share/mise/installs/node/lts/bin/node')
      if vim.fn.executable(node) == 0 then
        node = 'node'
      end
      require('copilot').setup({
        copilot_node_command = node,
        -- One copilot paradigm only: inline ghost text (suggestion) with
        -- <C-l> accept. The cmp menu is LSP/path/buffer only — running the
        -- copilot-cmp source at the same time duplicated every suggestion.
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<C-l>',
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-e>',
          },
        },
      })
    end,
  },
}
