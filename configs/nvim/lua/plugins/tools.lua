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
        {
          pattern = "/app/(.*)/(.*).rb",
          target = {
            { context = "test", target = "/spec/%1/%2_spec.rb" },
          },
        },
        {
          pattern = "(.+)/spec/(.*)/(.*)_spec.rb",
          target = {
            { target = "%1/app/%2/%3.rb" },
          },
        },
      },
    },
    config = function(_, opts)
      require("other-nvim").setup(opts)
    end,
  },
}
