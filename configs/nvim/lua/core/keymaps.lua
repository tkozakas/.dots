-- ============================================================================
-- NEOVIM KEYMAPS
-- ============================================================================
-- Mnemonic prefixes:
--   <leader>b - Buffer        <leader>g - Git
--   <leader>c - Code/AI       <leader>l - LSP
--   <leader>d - Diagnostics   <leader>s - Search
--   <leader>f - Format        <leader>t - Tmux
--   <leader>x - Debug

-- General/Editor
vim.keymap.set({ 'n', 'v' }, '<leader>', '<nop>')
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('n', 'd', '"_d', { desc = 'Delete (no yank)' })
vim.keymap.set('x', 'd', '"_d', { desc = 'Delete selection (no yank)' })

-- Window splits
vim.keymap.set('n', '<C-w>h', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<C-w>v', ':vsplit<CR>', { desc = 'Split window vertically' })

-- Buffer Management
vim.keymap.set('n', '<leader>b', '<C-^>', { desc = '[B]uffer: Switch to previous' })
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = '[B]uffer: [D]elete' })
vim.keymap.set('n', '<leader>bD', ':bdelete!<CR>', { desc = '[B]uffer: [D]elete (force)' })
vim.keymap.set('n', '<leader>bf', ':bfirst<CR>', { desc = '[B]uffer: [F]irst' })
vim.keymap.set('n', '<leader>bl', function()
  require('telescope.builtin').buffers()
end, { desc = '[B]uffer: [L]ist (fuzzy)' })
vim.keymap.set('n', '<leader>bL', ':blast<CR>', { desc = '[B]uffer: [L]ast' })
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = '[B]uffer: [N]ext' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = '[B]uffer: [P]revious' })

-- Code Operations
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<CR>', { desc = '[C]ode: Toggle [C]laude AI' })

-- LSP Navigation
vim.keymap.set('n', '<leader>le', ':Refactor extract ', { desc = '[L]SP: [E]xtract' })
vim.keymap.set('v', '<leader>le', ':Refactor extract ', { desc = '[L]SP: [E]xtract' })

-- Git Operations
vim.keymap.set('n', '<leader>gc', ':Gcommit<CR>', { desc = '[G]it: [C]ommit' })
vim.keymap.set('n', '<leader>gg', function()
  require('core.functions').lazygit()
end, { desc = '[G]it: Open [G]UI (LazyGit)' })
vim.keymap.set('n', '<leader>gh', ':Gh<CR>', { desc = '[G]it: Open on [H]ub' })
vim.keymap.set('n', '<leader>gp', function()
  require('core.functions').open_or_create_pr()
end, { desc = '[G]it: [P]R' })

-- Diagnostics
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = '[D]iagnostic: [D]etails' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = '[D]iagnostic: [L]ocation list' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist, { desc = '[D]iagnostic: [Q]uickfix list' })
vim.keymap.set('n', '<leader>dn', function() vim.diagnostic.jump({ count = 1 }) end, { desc = '[D]iagnostic: [N]ext' })
vim.keymap.set('n', '<leader>dp', function() vim.diagnostic.jump({ count = -1 }) end, { desc = '[D]iagnostic: [P]revious' })

-- Tmux Integration
vim.keymap.set('n', '<leader>th', function()
  require('core.functions').tmux_split_horizontal()
end, { desc = '[T]mux: Split [H]orizontal' })
vim.keymap.set('n', '<leader>tv', function()
  require('core.functions').tmux_split_vertical()
end, { desc = '[T]mux: Split [V]ertical' })
