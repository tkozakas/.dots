vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})



-- Auto-save on focus loss and leaving insert mode
vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufLeave', 'FocusLost' }, {
  group = vim.api.nvim_create_augroup('auto-save', { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not vim.api.nvim_buf_is_valid(buf) then return end
    if vim.bo[buf].modified and vim.bo[buf].buftype == '' and vim.bo[buf].filetype ~= 'harpoon' then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd('silent! write')
      end)
    end
  end,
})
