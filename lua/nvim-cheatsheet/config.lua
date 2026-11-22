local M = {}

---@class NvimCheatsheetPinConfig
---@field position 'bottom'|'top'|'right'|'left'
---@field size number Fraction (0..1) or fixed lines/columns (>1)
---@field max_size number Fraction (0..1) or fixed lines/columns (>1)
---@field min_size integer Minimum lines/columns
---@field return_focus boolean Return focus to previous window after pinning

---@class NvimCheatsheetWindowKeys
---@field close string|false
---@field close_float string|false
---@field next string|false
---@field prev string|false
---@field pin string|false
---@field edit string|false

---@class NvimCheatsheetWindowConfig
---@field border string|table|nil Border style (nil inherits vim.o.winborder)
---@field max_width number Fraction (0..1) or fixed columns (>1)
---@field max_height number Fraction (0..1) or fixed lines (>1)
---@field min_width integer
---@field min_height integer
---@field conceallevel integer
---@field concealcursor string
---@field pin NvimCheatsheetPinConfig
---@field keys NvimCheatsheetWindowKeys

---@class NvimCheatsheetKeymapsConfig
---@field prefix string Leader/key prefix (e.g. '<leader>h')
---@field group string Group name for which-key
---@field picker string|false Key suffix for picker (e.g. 'h' -> '<leader>hh')
---@field which_key boolean Auto-register group with which-key if installed
---@field sheets table<string, string|false> Override or add key suffix per sheet id

---@class NvimCheatsheetSheetMeta
---@field title? string
---@field key? string|false
---@field order? integer

---@class NvimCheatsheetConfig
---@field dir string Directory for user cheatsheets and built-in overrides
---@field include_builtins boolean Include bundled pure-Neovim cheatsheets
---@field sheets table<string, NvimCheatsheetSheetMeta> Metadata overrides keyed by sheet id
---@field keymaps boolean|NvimCheatsheetKeymapsConfig Opt-in keymap registration
---@field window NvimCheatsheetWindowConfig

M.defaults = {
  dir = vim.fn.stdpath 'config' .. '/cheatsheet',
  include_builtins = true,
  sheets = {},
  keymaps = false,
  window = {
    border = 'rounded',
    max_width = 0.86,
    max_height = 0.82,
    min_width = 68,
    min_height = 12,
    conceallevel = 2,
    concealcursor = 'nc',
    pin = {
      position = 'bottom',
      size = 0.36,
      max_size = 0.45,
      min_size = 10,
      return_focus = true,
    },
    keys = {
      close = 'q',
      close_float = '<Esc>',
      next = '<Tab>',
      prev = '<S-Tab>',
      pin = 'p',
      edit = 'e',
    },
  },
}

M.default_keymaps = {
  prefix = '<leader>h',
  group = 'Help / Cheatsheets',
  picker = 'h',
  which_key = true,
  sheets = {},
}

---@type NvimCheatsheetConfig
M.options = vim.deepcopy(M.defaults)

---@param opts? table
---@return NvimCheatsheetConfig
function M.setup(opts)
  opts = opts or {}
  local merged = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts)

  if merged.keymaps == true then
    merged.keymaps = vim.deepcopy(M.default_keymaps)
  elseif type(merged.keymaps) == 'table' then
    merged.keymaps = vim.tbl_deep_extend('force', vim.deepcopy(M.default_keymaps), merged.keymaps)
  end

  if type(merged.dir) == 'string' then
    merged.dir = vim.fs.normalize(vim.fn.expand(merged.dir))
  end

  M.options = merged
  return M.options
end

return M
