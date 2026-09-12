return {
  "tpope/vim-sleuth",

  { "vim-scripts/groovy.vim", ft = "groovy" },

  {
    "Wansmer/treesj",
    opts = {
      use_default_keymaps = false,
      max_join_length = 80,
    },
    keys = {
      {
        "<leader>/",
        function()
          require("treesj").toggle()
        end,
        desc = "Split/join node",
      },
    },
  },

  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>re",
        function()
          return require("refactoring").refactor("Extract Function")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Refactor: extract function",
      },
      {
        "<leader>rv",
        function()
          return require("refactoring").refactor("Extract Variable")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Refactor: extract variable",
      },
      {
        "<leader>ri",
        function()
          return require("refactoring").refactor("Inline Variable")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Refactor: inline variable",
      },
    },
    opts = {},
  },

  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo tree" },
    },
  },
}
