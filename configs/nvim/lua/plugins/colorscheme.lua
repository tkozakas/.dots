return {
  'Mofiqul/vscode.nvim',
  config = function()
    require('vscode').setup({
      style = 'dark',
      transparent = false,
      italic_comments = true,
    })
    vim.cmd('colorscheme vscode')
  end,
}
