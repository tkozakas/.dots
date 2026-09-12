local slash = vim.fn.maparg("<leader>/", "n", false, true)
if slash.desc and slash.desc:find("Grep") then
  vim.keymap.del("n", "<leader>/")
end

vim.keymap.set("n", "<leader><space>", function()
  Snacks.picker.smart()
end, { desc = "Search (smart, C-g cycles mode)" })
local functions = require("config.functions")

vim.keymap.set("n", "d", '"_d', { desc = "Delete (no yank)" })
vim.keymap.set("x", "d", '"_d', { desc = "Delete selection (no yank)" })

vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

local ctrl_e = vim.api.nvim_replace_termcodes("<C-e>", true, false, true)
local ctrl_y = vim.api.nvim_replace_termcodes("<C-y>", true, false, true)

local function scroll_down()
  local last_line = vim.api.nvim_buf_line_count(0)
  local win_height = vim.api.nvim_win_get_height(0)
  local topline = vim.fn.line("w0")
  local max_top = last_line - math.floor(win_height / 2)
  if topline < max_top then
    local scroll = math.min(3, max_top - topline)
    -- normal! is mode-safe: raw feedkeys of <C-e> in insert mode would insert text
    vim.cmd.normal({ args = { string.rep(ctrl_e, scroll) }, bang = true })
  end
end

local function scroll_up()
  vim.cmd.normal({ args = { string.rep(ctrl_y, 3) }, bang = true })
end

vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelDown>", scroll_down)
vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelUp>", scroll_up)

vim.keymap.set("n", "<M-Left>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<M-Right>", "<C-i>", { desc = "Jump forward" })

vim.keymap.set("n", "<leader>e", function()
  require("oil").open()
end, { desc = "File explorer (oil)" })

vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete (force)" })
vim.keymap.set("n", "<leader>bl", function()
  Snacks.picker.buffers()
end, { desc = "List (fuzzy)" })

vim.keymap.set("n", "<leader>gh", functions.open_in_gh, { desc = "Open on GitHub" })
vim.keymap.set("n", "<leader>gp", functions.open_or_create_pr, { desc = "Open/create PR" })

vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Diagnostic details" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
vim.keymap.set("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dp", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Previous diagnostic" })
