local function switch_to(source)
  return function(picker)
    local query = picker.input:get()
    picker:close()
    if source == "grep" then
      Snacks.picker.grep({ search = query })
    else
      Snacks.picker[source]({ pattern = query })
    end
  end
end

local switch_keys = {
  ["<c-s>"] = { "switch_smart", mode = { "i", "n" } },
  ["<c-r>"] = { "switch_recent", mode = { "i", "n" } },
  ["<c-f>"] = { "switch_files", mode = { "i", "n" } },
  ["<c-g>"] = { "switch_grep", mode = { "i", "n" } },
}

local function mode_source(mark, extra)
  return vim.tbl_deep_extend("force", {
    prompt = "[" .. mark .. "] ",
    win = { input = { keys = switch_keys } },
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
        switch_smart = switch_to("smart"),
        switch_recent = switch_to("recent"),
        switch_files = switch_to("files"),
        switch_grep = switch_to("grep"),
      },
      sources = {
        smart = mode_source("s", { filter = { cwd = true } }),
        recent = mode_source("r", { filter = { cwd = true } }),
        files = mode_source("f"),
        grep = mode_source("g", { regex = false }),
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
