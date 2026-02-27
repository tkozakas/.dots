vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 0
vim.opt_local.expandtab = false
vim.opt_local.textwidth = 120
vim.opt_local.conceallevel = 2

vim.keymap.set('n', '<leader>t', function()
  require('core.functions').Tmux_split('go test ./...')
end, { buffer = 0, desc = '[T]est: run go test' })

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
end, { buffer = 0, desc = '[W]ord search (exclude generated)' })
