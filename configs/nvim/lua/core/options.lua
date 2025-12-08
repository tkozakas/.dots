-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

-- General behavior
vim.opt.autoread = true -- auto update file if changed outside of nvim
vim.opt.exrc = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.timeoutlen = 300
vim.opt.undofile = true -- persistent undo history
vim.opt.updatetime = 250 -- save swap file and trigger CursorHold

-- Clipboard
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Display
vim.opt.background = "dark"
vim.opt.breakindent = true
vim.opt.cmdheight = 0
vim.opt.cursorline = true
vim.opt.inccommand = "split"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.listchars = { tab = '▏ ', trail = '·', nbsp = '␣' }
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true -- enable 24-bit colors
vim.opt.wrap = false

local Maxline = 80
vim.cmd("set colorcolumn=" .. Maxline)

-- Search
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.incsearch = true -- enable highlighting search in progress
vim.opt.smartcase = true

-- Indentation
vim.opt.autoindent = true -- copy indent from current line when starting new line
vim.opt.expandtab = true -- use appropriate number of spaces with tab
vim.opt.shiftwidth = 2 -- controls number of spaces when using >> or << commands
vim.opt.smartindent = true -- indenting correctly after {
vim.opt.softtabstop = 2 -- how many spaces tab inserts
vim.opt.tabstop = 2 -- how many spaces tab inserts

-- Completion
vim.opt.completeopt = "menu,menuone,noselect,preview" -- omnicomplete options for popup menu
vim.opt.pumheight = 15 -- max height of completion menu

-- UI
vim.opt.winborder = "rounded" -- rounded border

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = "●",
	},
})
