return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
      indent = { enabled = false },
      explorer = { enabled = false },
      scroll = { enabled = false },
      animate = { enabled = false },
      notifier = {
        width = { min = 40, max = 0.6 },
        height = { min = 1, max = 0.8 },
      },
    },
  },
}
