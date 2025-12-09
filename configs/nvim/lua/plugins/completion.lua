return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
      {
        'zbirenbaum/copilot-cmp',
        event = 'LspAttach',
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
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
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
    event = 'LspAttach',
    config = function()
      require('copilot').setup({
        panel = { enabled = false },
        suggestion = { enabled = false },
      })
    end,
  },
}
