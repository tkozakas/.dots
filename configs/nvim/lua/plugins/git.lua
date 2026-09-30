local function branch_base(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  for _, ref in ipairs({ "origin/HEAD", "origin/main", "origin/master" }) do
    local out = vim.fn.systemlist({ "git", "-C", dir, "merge-base", "HEAD", ref })
    if vim.v.shell_error == 0 and out[1] then
      return out[1]
    end
  end
end

local based = setmetatable({}, { __mode = "k" })

local function use_branch_base(bufnr)
  local bcache = require("gitsigns.cache").cache[bufnr]
  if not bcache then
    return
  end
  based[bcache] = true
  local base = branch_base(bufnr)
  if base then
    vim.api.nvim_buf_call(bufnr, function()
      require("gitsigns").change_base(base)
    end)
  end
end

local function toggle_branch_diff()
  vim.g.gitsigns_worktree_only = not vim.g.gitsigns_worktree_only
  if vim.g.gitsigns_worktree_only then
    require("gitsigns").reset_base(true)
    vim.notify("Git signs: working tree")
    return
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[bufnr].gitsigns_status_dict then
      use_branch_base(bufnr)
    end
  end
  vim.notify("Git signs: branch changes")
end

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsUpdate",
  callback = function(ev)
    local bufnr = ev.data and ev.data.buffer
    if not bufnr or vim.g.gitsigns_worktree_only then
      return
    end
    local bcache = require("gitsigns.cache").cache[bufnr]
    if bcache and not based[bcache] then
      based[bcache] = true
      vim.schedule(function()
        use_branch_base(bufnr)
      end)
    end
  end,
})

return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>gm", toggle_branch_diff, desc = "Toggle branch diff signs" },
    },
  },
}
