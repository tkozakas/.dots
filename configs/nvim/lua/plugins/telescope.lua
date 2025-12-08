return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  lazy = false,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
    { 'nvim-telescope/telescope-frecency.nvim', config = { db_safe_mode = false } },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')

    telescope.load_extension('fzf')
    telescope.load_extension('frecency')
    telescope.load_extension('live_grep_args')

    telescope.setup({
      pickers = {
        find_files = {
          theme = 'ivy',
          layout_config = { height = 0.50 },
        },
      },
      defaults = {
        mappings = {
          i = {
            ['<esc><esc>'] = false,
            ['jk'] = actions.close,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
      },
    })

    local function get_search_dir()
      local cwd = vim.fn.getcwd()
      local git_root = vim.fn.systemlist('git -C "' .. cwd .. '" rev-parse --show-toplevel 2>/dev/null')[1]
      
      if git_root and git_root ~= '' and vim.v.shell_error == 0 then
        return git_root
      end

      return cwd
    end

    vim.keymap.set('n', '<leader>j', function()
      vim.cmd('Telescope frecency workspace=CWD theme=ivy previewer=false layout_config={height=0.50}')
    end, { desc = 'Find Recent Files' })

    vim.keymap.set('n', '<leader>ff', function()
      require('telescope.builtin').find_files({ cwd = get_search_dir() })
    end, { desc = '[F]ind [F]iles' })

    vim.keymap.set('n', '<leader>sg', function()
      require('telescope').extensions.live_grep_args.live_grep_args({ cwd = get_search_dir() })
    end, { desc = '[S]earch by [G]rep' })

    vim.keymap.set('n', '<leader><leader>', function()
      require('telescope.builtin').resume()
    end, { desc = 'Resume Last Search' })
  end,
}
