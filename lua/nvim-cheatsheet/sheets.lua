local config = require 'nvim-cheatsheet.config'

local M = {}

---@class NvimCheatsheetSheet
---@field id string
---@field title string
---@field file string
---@field path string
---@field key? string|false
---@field source 'builtin'|'override'|'user'
---@field order integer

local builtin_specs = {
  { id = 'substitute', title = 'Substitute (:s)', key = 's', file = 'substitute.md', order = 10 },
  { id = 'motions', title = 'Motions & Jumps', key = 'm', file = 'motions.md', order = 20 },
  { id = 'text-objects', title = 'Text Objects & Operators', key = 't', file = 'text-objects.md', order = 30 },
  {
    id = 'registers-macros',
    title = 'Registers, Macros & Repeat',
    key = 'r',
    file = 'registers-macros.md',
    order = 40,
  },
  { id = 'visual-global', title = 'Visual Block & Global Edits', key = 'v', file = 'visual-global.md', order = 50 },
}

local function plugin_root()
  local src = debug.getinfo(1, 'S').source
  if src:sub(1, 1) == '@' then
    src = src:sub(2)
  end
  return vim.fs.normalize(vim.fn.fnamemodify(src, ':p:h:h:h'))
end

function M.builtin_dir()
  return plugin_root() .. '/cheatsheets'
end

function M.user_dir()
  return config.options.dir
end

local function format_title(id)
  return (id:gsub('[-_]+', ' '):gsub('(%a)([%w]*)', function(first, rest)
    return first:upper() .. rest
  end))
end

local function apply_meta(sheet)
  local meta = config.options.sheets and config.options.sheets[sheet.id]
  if type(meta) == 'table' then
    if meta.title ~= nil then
      sheet.title = meta.title
    end
    if meta.key ~= nil then
      sheet.key = meta.key
    end
    if meta.order ~= nil then
      sheet.order = meta.order
    end
  end

  local km = config.options.keymaps
  if type(km) == 'table' and type(km.sheets) == 'table' and km.sheets[sheet.id] ~= nil then
    sheet.key = km.sheets[sheet.id]
  end

  return sheet
end

local function scan_markdown_files(dir)
  local files = {}
  local handle = vim.uv.fs_scandir(dir)
  if not handle then
    return files
  end

  while true do
    local name, ftype = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if (ftype == 'file' or ftype == 'link') and name:sub(-3) == '.md' then
      table.insert(files, name)
    end
  end

  table.sort(files)
  return files
end

---@return NvimCheatsheetSheet[]
function M.list()
  local sheets = {}
  local seen = {}
  local bdir = M.builtin_dir()
  local udir = M.user_dir()

  if config.options.include_builtins then
    for _, spec in ipairs(builtin_specs) do
      local builtin_path = bdir .. '/' .. spec.file
      local user_path = udir .. '/' .. spec.file
      local has_user = vim.uv.fs_stat(user_path) ~= nil
      local has_builtin = vim.uv.fs_stat(builtin_path) ~= nil

      if has_user or has_builtin then
        local sheet = apply_meta {
          id = spec.id,
          title = spec.title,
          file = spec.file,
          path = has_user and user_path or builtin_path,
          key = spec.key,
          source = has_user and 'override' or 'builtin',
          order = spec.order,
        }
        table.insert(sheets, sheet)
        seen[spec.file] = true
      end
    end
  end

  for idx, name in ipairs(scan_markdown_files(udir)) do
    if not seen[name] then
      local id = name:sub(1, -4)
      local sheet = apply_meta {
        id = id,
        title = format_title(id),
        file = name,
        path = udir .. '/' .. name,
        key = nil,
        source = 'user',
        order = 1000 + idx,
      }
      table.insert(sheets, sheet)
      seen[name] = true
    end
  end

  table.sort(sheets, function(a, b)
    if a.order ~= b.order then
      return a.order < b.order
    end
    return a.id < b.id
  end)

  return sheets
end

---@param id string
---@return NvimCheatsheetSheet|nil, integer|nil, NvimCheatsheetSheet[]
function M.find(id)
  local sheets = M.list()
  for idx, sheet in ipairs(sheets) do
    if sheet.id == id then
      return sheet, idx, sheets
    end
  end
  return nil, nil, sheets
end

---@param sheet NvimCheatsheetSheet
---@return string[]
function M.read(sheet)
  local ok, lines = pcall(vim.fn.readfile, sheet.path)
  if not ok or type(lines) ~= 'table' then
    return { '# ' .. sheet.title, '', 'Could not read `' .. sheet.path .. '`.' }
  end
  return lines
end

---@param sheet NvimCheatsheetSheet
---@return string|nil, string|nil
function M.copy_to_user_dir(sheet)
  local udir = M.user_dir()
  local ok_dir = pcall(vim.fn.mkdir, udir, 'p')
  if not ok_dir then
    return nil, 'Failed to create directory: ' .. udir
  end

  local dest = udir .. '/' .. sheet.file
  local lines = M.read(sheet)
  local ok_write, err = pcall(vim.fn.writefile, lines, dest)
  if not ok_write then
    return nil, 'Failed to write ' .. dest .. ': ' .. tostring(err)
  end

  return dest, nil
end

return M
