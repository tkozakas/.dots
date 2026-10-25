return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = function()
      -- copilot.lua needs node >= 22; the system node is v20, so prefer
      -- mise's LTS install and fall back to PATH node.
      local node = vim.fn.expand("~/.local/share/mise/installs/node/lts/bin/node")
      if vim.fn.executable(node) == 0 then
        node = "node"
      end
      return {
        copilot_node_command = node,
        -- One copilot paradigm only: inline ghost text, no panel, no cmp menu
        -- source — running both duplicated every suggestion.
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
            accept_word = "<C-Right>",
            accept_line = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-e>",
          },
        },
      }
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
      vim.g.ai_accept = function()
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          suggestion.accept()
          return true
        end
      end
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {
          "select_and_accept",
          "snippet_forward",
          function()
            return vim.g.ai_accept and vim.g.ai_accept()
          end,
          "fallback",
        },
      },
    },
  },
}
