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
      "lewis6991/async.nvim",
    },
    keys = {
      {
        "<leader>rr",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "n", "x" },
        desc = "Refactor: menu",
      },
      {
        "<leader>re",
        function()
          return require("refactoring").extract_func()
        end,
        mode = "x",
        expr = true,
        desc = "Refactor: extract function",
      },
      {
        "<leader>rf",
        function()
          return require("refactoring").extract_func_to_file()
        end,
        mode = "x",
        expr = true,
        desc = "Refactor: extract to file",
      },
      {
        "<leader>rv",
        function()
          return require("refactoring").extract_var()
        end,
        mode = "x",
        expr = true,
        desc = "Refactor: extract variable",
      },
      {
        "<leader>ri",
        function()
          return require("refactoring").inline_var()
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "Refactor: inline variable",
      },
      {
        "<leader>rI",
        function()
          return require("refactoring").inline_func()
        end,
        expr = true,
        desc = "Refactor: inline function",
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
