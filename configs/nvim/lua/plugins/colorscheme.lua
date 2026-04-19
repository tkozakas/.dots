-- Colorscheme plugins + loader
-- Active theme is determined by ~/.config/current-theme/ symlink
return {
  {
    'folke/tokyonight.nvim',
    lazy = true,
    config = function()
      require('tokyonight').setup({ style = 'night' })
    end,
  },
  {
    'navarasu/onedark.nvim',
    lazy = true,
    config = function()
      require('onedark').setup({ style = 'darker' })
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = true,
    config = function()
      require('gruvbox').setup({ contrast = 'hard' })
    end,
  },
  -- Loader: reads theme from current-theme symlink
  {
    'folke/tokyonight.nvim',
    name = 'theme-loader',
    priority = 999,
    lazy = false,
    config = function()
      local theme_file = vim.fn.expand('~/.config/current-theme/nvim_colorscheme')

      local function read_theme()
        local f = io.open(theme_file, 'r')
        if f then
          local t = f:read('*l')
          f:close()
          return t
        end
        return 'default'
      end

      local function apply_theme(t)
        if t == 'default' then
          vim.cmd('colorscheme default')
        elseif t == 'onedark' then
          require('onedark').load()
        else
          pcall(vim.cmd.colorscheme, t)
        end
      end

      apply_theme(read_theme())

      vim.api.nvim_create_autocmd('Signal', {
        pattern = 'SIGUSR1',
        callback = function()
          apply_theme(read_theme())
        end,
      })
    end,
  },
}
