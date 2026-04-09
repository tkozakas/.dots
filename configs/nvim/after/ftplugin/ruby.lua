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
  require('core.functions').word_grep('--glob !**_spec.rb')
end, { buffer = 0, desc = '[W]ord search (exclude specs)' })
