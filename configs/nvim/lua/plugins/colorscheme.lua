-- All colorscheme plugins are installed; the active one is selected by ~/.config/nvim/theme
-- Theme picker writes to that file and sends a reload command to running instances
return {
  {
    'navarasu/onedark.nvim',
    lazy = true,
    config = function()
      require('onedark').setup({ style = 'darker' })
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    config = function()
      require('catppuccin').setup({ flavour = 'mocha' })
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = true,
    config = function()
      require('gruvbox').setup({ contrast = 'hard' })
    end,
  },
  -- Loader: reads theme file and applies colorscheme
  {
    'navarasu/onedark.nvim', -- dummy dep to run after all above
    name = 'theme-loader',
    priority = 999,
    lazy = false,
    config = function()
      local theme_file = vim.fn.expand('~/.config/nvim/theme')
      local theme = 'onedark' -- fallback
      local f = io.open(theme_file, 'r')
      if f then
        theme = f:read('*l') or theme
        f:close()
      end
      -- Ensure the plugin is loaded before setting colorscheme
      local ok = pcall(function()
        if theme == 'onedark' then
          require('onedark').load()
        else
          vim.cmd.colorscheme(theme)
        end
      end)
      if not ok then
        require('onedark').load()
      end

      -- Watch for theme changes via SIGUSR1
      vim.api.nvim_create_autocmd('Signal', {
        pattern = 'SIGUSR1',
        callback = function()
          local tf = io.open(theme_file, 'r')
          if tf then
            local new_theme = tf:read('*l')
            tf:close()
            if new_theme then
              if new_theme == 'onedark' then
                require('onedark').load()
              else
                pcall(vim.cmd.colorscheme, new_theme)
              end
            end
          end
        end,
      })
    end,
  },
}
