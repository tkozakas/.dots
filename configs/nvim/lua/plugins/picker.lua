local cycle_order = { smart = "files", files = "grep", grep = "smart" }

local function cycle_mode(picker)
  local query = picker.input:get()
  local next_source = cycle_order[picker.opts.source] or "smart"
  picker:close()
  if next_source == "grep" then
    Snacks.picker.grep({ search = query })
  else
    Snacks.picker[next_source]({ pattern = query })
  end
end

local cycle_keys = {
  win = {
    input = {
      keys = {
        ["<c-g>"] = { "cycle_mode", mode = { "i", "n" } },
      },
    },
  },
}

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>/", false },
    { "<leader>ff", false },
    { "<leader>sg", false },
  },
  opts = {
    picker = {
      actions = {
        cycle_mode = cycle_mode,
      },
      sources = {
        smart = vim.tbl_deep_extend("force", { filter = { cwd = true } }, cycle_keys),
        files = cycle_keys,
        grep = vim.tbl_deep_extend("force", { regex = false }, cycle_keys),
        grep_word = { regex = false },
        grep_buffers = { regex = false },
        lsp_references = {
          include_declaration = false,
          layout = { preset = "vertical" },
        },
        lsp_definitions = { layout = { preset = "vertical" } },
        lsp_declarations = { layout = { preset = "vertical" } },
        lsp_implementations = { layout = { preset = "vertical" } },
        lsp_type_definitions = { layout = { preset = "vertical" } },
      },
    },
  },
}
