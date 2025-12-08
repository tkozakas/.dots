vim.api.nvim_create_user_command('Gcommit', function()
  vim.fn.system('git add . && git commit -m "feat: changes"')
end, {})

vim.api.nvim_create_user_command('Econf', function()
  vim.cmd('e ~/dotfiles/.config/nvim/init.lua')
end, {})

vim.api.nvim_create_user_command('Cp', function()
  require('core.functions').copy_to_clipboard()
end, {})

vim.api.nvim_create_user_command('Gh', function()
  require('core.functions').OpenInGH()
end, {})
