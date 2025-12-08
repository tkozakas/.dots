vim.keymap.set('n', '<leader>t', function()
  local current_file = vim.fn.expand('%:.')
  local test_file_path = current_file:find('_spec.rb') and current_file or vim.b.onv_otherFile
  if test_file_path == nil then
    vim.notify('Could not find test file')
  end
  Tmux_split('bundle exec rspec ' .. test_file_path)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>T', function()
  local current_file = vim.fn.expand('%:.')
  local test_file_path = current_file:find('_spec.rb') and current_file or vim.b.onv_otherFile
  if test_file_path == nil then
    vim.notify('Could not find test file')
  end
  local line_no, _ = unpack(vim.api.nvim_win_get_cursor(0))
  Tmux_split('bundle exec rspec ' .. test_file_path .. ':' .. line_no)
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>cr', function()
  local ts = vim.treesitter
  local parser = ts.get_parser(0, "ruby")
  local tree = parser:parse()[1]
  local root = tree:root()
  print(root)

  local query = ts.query.parse("ruby", [[
    (class name: (constant) @class_name)
  ]])

  for _, node in query:iter_captures(root, 0) do
    print(node)
    print(ts.get_node_text(node, 0))
    break
  end
end)

vim.keymap.set('n', '<leader>w', function()
  require("telescope")
    .extensions
    .live_grep_args
    .live_grep_args({
      default_text = '"" --glob !**_spec.rb',
      attach_mappings = function()
          vim.schedule(function()
            vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 3 })
          end)
          return true
        end,
    })
end)
