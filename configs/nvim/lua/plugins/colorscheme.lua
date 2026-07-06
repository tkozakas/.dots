-- Default colorscheme: render the builtin scheme through the terminal's
-- 16-color ANSI palette so nvim matches tmux/alacritty/opencode.
vim.opt.termguicolors = false
vim.cmd('colorscheme default')

-- Minimalist chrome: hide the end-of-buffer ~, thin the split, and flatten
-- the statusline so nothing renders as a solid white block.
vim.opt.fillchars = {
  eob = ' ',   -- hide ~ on lines past the end of the buffer
  vert = '│',  -- thin single-line vertical split
  horiz = ' ', -- no heavy horizontal bar between stacked splits
  horizup = ' ',
  horizdown = ' ',
  vertleft = '│',
  vertright = '│',
  verthoriz = '│',
}

local function minimal_chrome()
  local set = vim.api.nvim_set_hl
  -- Muted, non-reversed vertical split (ANSI 8 = bright black / gray)
  set(0, 'WinSeparator', { ctermfg = 8, ctermbg = 'NONE', cterm = {} })
  set(0, 'VertSplit',    { ctermfg = 8, ctermbg = 'NONE', cterm = {} })
  -- Flat statusline: plain text, terminal background, no reverse block
  set(0, 'StatusLine',   { ctermfg = 7, ctermbg = 'NONE', cterm = {} })
  set(0, 'StatusLineNC', { ctermfg = 8, ctermbg = 'NONE', cterm = {} })
  -- Fully mute any residual EndOfBuffer glyph
  set(0, 'EndOfBuffer',  { ctermfg = 0, ctermbg = 'NONE', cterm = {} })
  -- Kill the reversed (solid white) ColorColumn block at column 80; render it
  -- as a subtle gray cell instead of an inverted bar past the line end.
  set(0, 'ColorColumn',  { ctermfg = 'NONE', ctermbg = 8, cterm = {} })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('minimal-chrome', { clear = true }),
  callback = minimal_chrome,
})
minimal_chrome()

return {}
