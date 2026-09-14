local cycle_order = { smart = "recent", recent = "files", files = "grep", grep = "smart" }

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

local function cycle_source(prompt_mark, extra)
  return vim.tbl_deep_extend("force", {
    prompt = "[" .. prompt_mark .. "] ",
    win = {
      input = {
        keys = {
          ["<c-g>"] = { "cycle_mode", mode = { "i", "n" } },
        },
      },
    },
  }, extra or {})
end

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
        smart = cycle_source("s", { filter = { cwd = true } }),
        recent = cycle_source("r", { filter = { cwd = true } }),
        files = cycle_source("f"),
        grep = cycle_source("g", { regex = false }),
        grep_word = { regex = false },
        grep_buffers = { regex = false },
        lsp_references = {
          include_declaration = false,
          unique_lines = true,
          layout = { preset = "vertical" },
        },
        lsp_definitions = { unique_lines = true, layout = { preset = "vertical" } },
        lsp_declarations = { unique_lines = true, layout = { preset = "vertical" } },
        lsp_implementations = { unique_lines = true, layout = { preset = "vertical" } },
        lsp_type_definitions = { unique_lines = true, layout = { preset = "vertical" } },
      },
    },
  },
}
