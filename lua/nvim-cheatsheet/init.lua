local config = require 'nvim-cheatsheet.config'
local sheets = require 'nvim-cheatsheet.sheets'
local ui = require 'nvim-cheatsheet.ui'

local M = {}

local function is_which_key_available()
  if type(package.loaded['which-key']) == 'table' then
    return true
  end
  return #vim.api.nvim_get_runtime_file('lua/which-key/init.lua', false) > 0
    or #vim.api.nvim_get_runtime_file('lua/which-key.lua', false) > 0
end

local function register_which_key(prefix, group)
  if not is_which_key_available() then
    return false
  end
  local ok, wk = pcall(require, 'which-key')
  if ok and type(wk) == 'table' and type(wk.add) == 'function' then
    wk.add { { prefix, group = group } }
    return true
  end
  return false
end

local function setup_keymaps(km)
  if type(km) ~= 'table' or not km.prefix or km.prefix == '' then
    return
  end

  local prefix = km.prefix
  local map = vim.keymap.set

  for _, sheet in ipairs(sheets.list()) do
    if type(sheet.key) == 'string' and sheet.key ~= '' then
      map('n', prefix .. sheet.key, function()
        ui.open(sheet.id)
      end, { desc = sheet.title })
    end
  end

  if type(km.picker) == 'string' and km.picker ~= '' then
    map('n', prefix .. km.picker, ui.pick, { desc = 'Browse all cheatsheets' })
  end

  if km.which_key ~= false and km.group and km.group ~= '' then
    local augroup = vim.api.nvim_create_augroup('NvimCheatsheetWhichKey', { clear = true })
    if not register_which_key(prefix, km.group) then
      local function schedule_very_lazy()
        vim.api.nvim_create_autocmd('User', {
          group = augroup,
          pattern = 'VeryLazy',
          once = true,
          callback = function()
            register_which_key(prefix, km.group)
          end,
        })
      end

      if vim.v.vim_did_enter == 0 then
        vim.api.nvim_create_autocmd('VimEnter', {
          group = augroup,
          once = true,
          callback = function()
            if not register_which_key(prefix, km.group) then
              schedule_very_lazy()
            end
          end,
        })
      else
        schedule_very_lazy()
      end
    end
  end
end

---@param opts? table
function M.setup(opts)
  local options = config.setup(opts)
  if options.keymaps then
    setup_keymaps(options.keymaps)
  end
end

M.open = ui.open
M.close = ui.close
M.cycle = ui.cycle
M.toggle_pin = ui.toggle_pin
M.edit = ui.edit_current
M.pick = ui.pick
M.list = sheets.list
M.is_open = ui.is_open
M.is_pinned = ui.is_pinned

return M
