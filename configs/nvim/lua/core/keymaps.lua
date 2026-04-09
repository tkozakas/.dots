vim.keymap.set({ 'n', 'v' }, '<leader>', '<nop>')

-- General (scrolloff=999 keeps cursor centered, no explicit zz needed)
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('n', 'd', '"_d', { desc = 'Delete (no yank)' })
vim.keymap.set('x', 'd', '"_d', { desc = 'Delete selection (no yank)' })

-- Trackpad/mouse scroll: free viewport scroll, capped so last line stops at center
local ctrl_e = vim.api.nvim_replace_termcodes('<C-e>', true, false, true)
local ctrl_y = vim.api.nvim_replace_termcodes('<C-y>', true, false, true)

local function scroll_down()
  local last_line = vim.api.nvim_buf_line_count(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local topline = vim.fn.line('w0')
  local max_top = last_line - math.floor(win_height / 2)
  if topline < max_top then
    local scroll = math.min(3, max_top - topline)
    vim.fn.feedkeys(string.rep(ctrl_e, scroll), 'nx')
  end
end

local function scroll_up()
  vim.fn.feedkeys(string.rep(ctrl_y, 3), 'nx')
end

vim.keymap.set({ 'n', 'v', 'i' }, '<ScrollWheelDown>', scroll_down)
vim.keymap.set({ 'n', 'v', 'i' }, '<ScrollWheelUp>', scroll_up)

-- Buffer
vim.keymap.set('n', '<leader>bb', '<C-^>', { desc = 'Switch to previous' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete' })
vim.keymap.set('n', '<leader>bD', '<cmd>bdelete!<CR>', { desc = 'Delete (force)' })
vim.keymap.set('n', '<leader>bl', function()
  require('telescope.builtin').buffers()
end, { desc = 'List (fuzzy)' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Previous' })

-- Git
vim.keymap.set('n', '<leader>gh', function()
  require('core.functions').open_in_gh()
end, { desc = 'Open on GitHub' })
vim.keymap.set('n', '<leader>gp', function()
  require('core.functions').open_or_create_pr()
end, { desc = 'Open/create PR' })

-- Diagnostics
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Details' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Location list' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist, { desc = 'Quickfix list' })
vim.keymap.set('n', '<leader>dn', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next' })
vim.keymap.set('n', '<leader>dp', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous' })

-- Search
vim.keymap.set('n', '<leader>sw', function()
  require('core.functions').word_grep('')
end, { desc = '[S]earch [W]ord under cursor' })

