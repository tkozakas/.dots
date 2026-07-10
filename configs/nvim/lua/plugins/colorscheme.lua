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
  -- Column-80 ruler: virt-column draws a thin ▏ glyph instead of the solid
  -- reversed ColorColumn cell; keep the cell background off and tint the glyph.
  set(0, 'ColorColumn',  { ctermfg = 'NONE', ctermbg = 'NONE', cterm = {} })
  set(0, 'VirtColumn',   { ctermfg = 8, ctermbg = 'NONE', cterm = {} })

  -- The builtin default scheme leaves most syntax groups colorless in
  -- 16-color mode (keywords render bold-only). Give them classic vim
  -- ANSI colors so go/ruby/etc. read as properly highlighted.
  set(0, 'Statement', { ctermfg = 11, cterm = { bold = true } }) -- func/def/end/if
  set(0, 'Keyword',   { link = 'Statement' })
  set(0, 'Type',      { ctermfg = 6 })  -- cyan: struct/interface/module types
  set(0, 'Constant',  { ctermfg = 13 }) -- bright magenta: consts/symbols
  set(0, 'Number',    { link = 'Constant' })
  set(0, 'Boolean',   { link = 'Constant' })
  set(0, 'Comment',   { ctermfg = 8 })  -- muted gray comments
  set(0, 'PreProc',   { ctermfg = 12 }) -- import/require/attributes
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('minimal-chrome', { clear = true }),
  callback = minimal_chrome,
})
minimal_chrome()

-- Render 'colorcolumn' (set in core/options.lua) as a thin virtual glyph,
-- matching the ▏ tab guides instead of a full-cell background block.
return {
  'lukas-reineke/virt-column.nvim',
  opts = { char = '▏' },
}
