return {
  'nvim-telescope/telescope.nvim',
  branch = 'master',
  cmd = { 'Telescope' },
  keys = {
    { '<leader>j', desc = 'Recent files' },
    { '<leader>sf', desc = '[S]earch [F]iles (repo)' },
    { '<leader>sg', desc = '[S]earch [G]rep (repo)' },
    { '<leader>sa', desc = '[S]earch [A]ST pattern (repo)' },
    { '<leader>sF', desc = '[S]earch [F]iles (cwd)' },
    { '<leader>sG', desc = '[S]earch [G]rep (cwd)' },
    { '<leader>sA', desc = '[S]earch [A]ST pattern (cwd)' },
    { '<leader><leader>', desc = 'Resume last search' },
  },
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
    { 'nvim-telescope/telescope-frecency.nvim', opts = { db_safe_mode = false } },
    { 'Marskey/telescope-sg' },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local lga_actions = require('telescope-live-grep-args.actions')

    telescope.setup({
      pickers = {
        find_files = {
          theme = 'ivy',
          layout_config = { height = 0.50 },
          -- Use fd with full path matching so / and _ work naturally
          find_command = { 'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git' },
        },
      },
      defaults = {
        -- ripgrep flags for live grep: smart-case, search hidden files,
        -- respect .gitignore, skip .git itself
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob=!.git/*',
        },
        path_display = { 'filename_first' },
        cache_picker = {
          num_pickers = 10,
          limit_entries = 1000,
        },
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
        live_grep_args = {
          auto_quoting = true, -- wraps input in "" so ripgrep treats it as literal (no regex escaping needed)
          theme = 'ivy',
          layout_config = { height = 0.50 },
          mappings = {
            i = {
              -- Ctrl-k to quote the query (toggle literal mode)
              ['<C-k>'] = lga_actions.quote_prompt(),
              -- Ctrl-g to add glob filter e.g. --glob=*.rb
              ['<C-g>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
              -- Ctrl-t to filter by file type e.g. -truby
              ['<C-t>'] = lga_actions.quote_prompt({ postfix = ' -t ' }),
            },
          },
        },
        ast_grep = {
          command = { 'sg', '--json=stream' },
          grep_open_files = false,
          lang = nil, -- auto-detect from file extension
        },
      },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('frecency')
    telescope.load_extension('live_grep_args')
    telescope.load_extension('ast_grep')

    local git_root = require('core.functions').git_root
    local function buf_dir()
      local name = vim.api.nvim_buf_get_name(0)
      if name == '' then return vim.fn.getcwd() end
      return vim.fn.fnamemodify(name, ':p:h')
    end

    vim.keymap.set('n', '<leader>j', function()
      require('telescope').extensions.frecency.frecency({
        workspace = 'CWD',
        theme = 'ivy',
        previewer = false,
        layout_config = { height = 0.50 },
      })
    end, { desc = 'Recent files' })

    vim.keymap.set('n', '<leader>sf', function()
      require('telescope.builtin').find_files({ cwd = git_root() })
    end, { desc = '[S]earch [F]iles (repo)' })

    vim.keymap.set('n', '<leader>sg', function()
      require('telescope').extensions.live_grep_args.live_grep_args({
        cwd = git_root(),
      })
    end, { desc = '[S]earch [G]rep (repo)' })

    vim.keymap.set('n', '<leader>sa', function()
      require('telescope').extensions.ast_grep.ast_grep({ cwd = git_root() })
    end, { desc = '[S]earch [A]ST pattern (repo)' })

    vim.keymap.set('n', '<leader>sF', function()
      require('telescope.builtin').find_files({ cwd = buf_dir() })
    end, { desc = '[S]earch [F]iles (cwd)' })

    vim.keymap.set('n', '<leader>sG', function()
      require('telescope').extensions.live_grep_args.live_grep_args({
        cwd = buf_dir(),
      })
    end, { desc = '[S]earch [G]rep (cwd)' })

    vim.keymap.set('n', '<leader>sA', function()
      require('telescope').extensions.ast_grep.ast_grep({ cwd = buf_dir() })
    end, { desc = '[S]earch [A]ST pattern (cwd)' })

    vim.keymap.set('n', '<leader><leader>', function()
      require('telescope.builtin').resume()
    end, { desc = 'Resume last search' })
  end,
}
