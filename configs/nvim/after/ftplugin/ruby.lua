local function find_spec_file()
  local file = vim.fn.expand('%:.')
  if file:find('_spec.rb') then return file end
  local spec = file:gsub('^app/', 'spec/'):gsub('%.rb$', '_spec.rb')
  if vim.fn.filereadable(spec) == 1 then return spec end
  return nil
end

vim.keymap.set('n', '<leader>t', function()
  local spec = find_spec_file()
  if not spec then
    vim.notify('Could not find test file', vim.log.levels.WARN)
    return
  end
  require('core.functions').Tmux_split('bundle exec rspec ' .. spec)
end, { buffer = 0, desc = '[T]est: run rspec file' })

vim.keymap.set('n', '<leader>T', function()
  local spec = find_spec_file()
  if not spec then
    vim.notify('Could not find test file', vim.log.levels.WARN)
    return
  end
  local line_no = vim.api.nvim_win_get_cursor(0)[1]
  require('core.functions').Tmux_split('bundle exec rspec ' .. spec .. ':' .. line_no)
end, { buffer = 0, desc = '[T]est: run rspec at line' })

vim.keymap.set('n', '<leader>cr', function()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, 'ruby')
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = ts.query.parse(
    'ruby',
    [[
    (class name: (constant) @class_name)
  ]]
  )

  for _, node in query:iter_captures(root, 0) do
    vim.notify(ts.get_node_text(node, 0), vim.log.levels.INFO)
    break
  end
end, { buffer = 0, desc = '[C]lass: show [R]uby class name' })

vim.keymap.set('n', '<leader>w', function()
  require('telescope').extensions.live_grep_args.live_grep_args({
    default_text = '"" --glob !**_spec.rb',
    attach_mappings = function()
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 3 })
      end)
      return true
    end,
  })
end, { buffer = 0, desc = '[W]ord search (exclude specs)' })
