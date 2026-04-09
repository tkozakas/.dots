vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 0
vim.opt_local.expandtab = false
vim.opt_local.textwidth = 120
vim.opt_local.conceallevel = 2
vim.keymap.set('n', '<leader>w', function()
  require('core.functions').word_grep('--glob !*.gen.go')
end, { buffer = 0, desc = '[W]ord search (exclude generated)' })
