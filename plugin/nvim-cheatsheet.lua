if vim.g.loaded_nvim_cheatsheet then
  return
end
vim.g.loaded_nvim_cheatsheet = true

local subcommands = { 'pick', 'pin', 'close', 'edit' }

vim.api.nvim_create_user_command('Cheatsheet', function(cmd)
  local cs = require 'nvim-cheatsheet'
  local arg = vim.trim(cmd.args or '')

  if arg == '' or arg == 'pick' then
    cs.pick()
  elseif arg == 'close' then
    cs.close()
  elseif arg == 'pin' then
    cs.toggle_pin()
  elseif arg == 'edit' then
    cs.edit()
  else
    cs.open(arg)
  end
end, {
  nargs = '?',
  desc = 'Open or manage nvim-cheatsheet popups',
  complete = function(arg_lead)
    local cs = require 'nvim-cheatsheet'
    local items = {}
    for _, sheet in ipairs(cs.list()) do
      table.insert(items, sheet.id)
    end
    for _, sub in ipairs(subcommands) do
      table.insert(items, sub)
    end

    if arg_lead == '' then
      return items
    end
    return vim.tbl_filter(function(item)
      return vim.startswith(item, arg_lead)
    end, items)
  end,
})
