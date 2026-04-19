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
      local theme = 'default' -- fallback to vim default
      local f = io.open(theme_file, 'r')
      if f then
        theme = f:read('*l') or theme
        f:close()
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

      apply_theme(theme)

      -- Watch for theme changes via SIGUSR1
      vim.api.nvim_create_autocmd('Signal', {
        pattern = 'SIGUSR1',
        callback = function()
          local tf = io.open(theme_file, 'r')
          if tf then
            local new_theme = tf:read('*l')
            tf:close()
            if new_theme then
              apply_theme(new_theme)
            end
          end
        end,
      })
    end,
  },
}
