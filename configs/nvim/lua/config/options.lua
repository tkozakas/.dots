vim.opt.exrc = true
vim.opt.swapfile = false

vim.g.autoformat = false

-- Render through the terminal's 16-color ANSI palette so nvim inherits the
-- same Tango colors as tmux/omp/lazygit (LazyVim defaults this to true)
vim.opt.termguicolors = false

vim.opt.cmdheight = 0
vim.opt.relativenumber = false
vim.opt.scrolloff = 999
vim.opt.colorcolumn = "80"
vim.opt.breakindent = true
vim.opt.inccommand = "split"
vim.opt.listchars = { tab = "▏ ", trail = "·", nbsp = "␣" }
vim.opt.winborder = "rounded"


vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git/*"

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
})
