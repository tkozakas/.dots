vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*Jenkinsfile*',
  callback = function()
    vim.bo.filetype = 'groovy'
  end,
  desc = 'Set Jenkinsfile filetype to groovy for syntax highlighting',
})

