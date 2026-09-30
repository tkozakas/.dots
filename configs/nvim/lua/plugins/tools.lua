local function ruby_spec(file)
  if file:match("_spec%.rb$") then
    return nil
  end
  local root, rest = file:match("^(.*/)app/(.+)%.rb$")
  if root then
    return { root .. "spec/" .. rest .. "_spec.rb" }
  end
  root, rest = file:match("^(.*/)lib/(.+)%.rb$")
  if root then
    return { root .. "spec/lib/" .. rest .. "_spec.rb" }
  end
end

local function ruby_source(file)
  local root, rest = file:match("^(.*/)spec/(.+)_spec%.rb$")
  if not root then
    return nil
  end
  local candidates = { root .. "app/" .. rest .. ".rb" }
  if rest:match("^lib/") then
    table.insert(candidates, 1, root .. rest .. ".rb")
  end
  for _, candidate in ipairs(candidates) do
    if vim.uv.fs_stat(candidate) then
      return { candidate }
    end
  end
  return { candidates[1] }
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "M", function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
      { "mm", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: toggle menu" },
      { "ma", function() require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
      { "ms", function() require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
      { "md", function() require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
      { "mf", function() require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
    },
    config = function()
      require("harpoon"):setup()
    end,
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
      "fredrikaverpil/neotest-golang",
    },
    keys = {
      { "<leader>tn", function() require("neotest").run.run() end, desc = "Test: run nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: run file" },
      { "<leader>ta", function() require("neotest").run.run({ suite = true }) end, desc = "Test: run all" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: summary" },
      { "<leader>to", function() require("neotest").output_panel.toggle() end, desc = "Test: output" },
      { "<leader>tx", function() require("neotest").run.stop() end, desc = "Test: stop" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rspec")({
            rspec_cmd = function()
              return { "bundle", "exec", "rspec" }
            end,
          }),
          require("neotest-golang"),
        },
      })
    end,
  },

  {
    "rgroli/other.nvim",
    keys = {
      { "<leader>o", function() require("other-nvim").open() end, desc = "Open other file" },
      { "<leader>O", function() require("other-nvim").openVSplit() end, desc = "Open other file (vsplit)" },
    },
    opts = {
      mappings = {
        "golang",
        "python",
        { pattern = ruby_spec, target = "%1", context = "test" },
        { pattern = ruby_source, target = "%1" },
      },
    },
    config = function(_, opts)
      require("other-nvim").setup(opts)
    end,
  },
}
