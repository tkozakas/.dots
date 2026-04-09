return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      {
        'zbirenbaum/copilot-cmp',
        config = function()
          require('copilot_cmp').setup()
        end,
      },
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = 'copilot' },
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
      require('copilot').setup({
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
