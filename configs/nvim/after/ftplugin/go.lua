vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = false
vim.opt.textwidth = 120
vim.opt.conceallevel = 2

vim.keymap.set('n', '<leader>t', function()
  require('core.functions').Tmux_split('go test ./...')
end, { desc = '[T]est: run go test', noremap = true, silent = true })

vim.keymap.set('n', '<leader>w', function()
  require('telescope').extensions.live_grep_args.live_grep_args({
    default_text = '"" --glob !*.gen.go',
    attach_mappings = function()
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 3 })
      end)
      return true
    end,
  })
end, { desc = '[W]ord search (exclude generated)' })
