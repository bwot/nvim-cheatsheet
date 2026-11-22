local config = require 'nvim-cheatsheet.config'
local sheets_mod = require 'nvim-cheatsheet.sheets'

local M = {}

local state = {
  buf = nil,
  win = nil,
  pinned = false,
  current_id = nil,
  prev_win = nil,
}

local split_direction_map = {
  bottom = 'below',
  top = 'above',
  right = 'right',
  left = 'left',
}

local function is_win_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function is_buf_valid()
  return state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf)
end

local function resolve_dim(value, total)
  if value <= 1 then
    return math.floor(total * value)
  end
  return math.floor(value)
end

local function pin_label(position)
  if position == 'right' or position == 'left' or position == 'top' then
    return 'pin ' .. position
  end
  return 'pin bottom'
end

local function build_hints(pinned)
  local keys = config.options.window.keys
  local parts = {}

  if keys.next and keys.prev then
    table.insert(parts, string.format('[%s/%s] switch', keys.next:gsub('[<>]', ''), keys.prev:gsub('[<>]', '')))
  end
  if keys.pin then
    local action = pinned and 'float' or pin_label(config.options.window.pin.position)
    table.insert(parts, string.format('[%s] %s', keys.pin, action))
  end
  if keys.edit then
    table.insert(parts, string.format('[%s] edit', keys.edit))
  end
  if keys.close then
    local close_hint = (not pinned and keys.close_float) and (keys.close .. '/' .. keys.close_float:gsub('[<>]', ''))
      or keys.close
    table.insert(parts, string.format('[%s] close', close_hint))
  end

  return table.concat(parts, '  ')
end

local function compute_float_config(lines, sheet, idx, total)
  local wcfg = config.options.window
  local max_line_width = 0
  for _, line in ipairs(lines) do
    local w = vim.fn.strdisplaywidth(line)
    if w > max_line_width then
      max_line_width = w
    end
  end

  local columns = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight - 2

  local max_w = math.max(20, resolve_dim(wcfg.max_width, columns))
  local min_w = math.min(wcfg.min_width, math.max(20, columns - 4))
  local width = math.min(math.max(max_line_width + 4, min_w), max_w)

  local max_h = math.max(6, resolve_dim(wcfg.max_height, editor_height))
  local min_h = math.min(wcfg.min_height, max_h)
  local height = math.min(math.max(#lines + 1, min_h), max_h)

  local row = math.max(0, math.floor((editor_height - height) / 2))
  local col = math.max(0, math.floor((columns - width) / 2))

  local border = wcfg.border
  if border == nil and vim.o.winborder ~= '' then
    border = vim.o.winborder
  end

  local badge = sheet.source == 'override' and ' *' or ''
  local hints = build_hints(false)

  return {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = border,
    title = string.format(' %s%s (%d/%d) ', sheet.title, badge, idx, total),
    title_pos = 'center',
    footer = hints ~= '' and (' ' .. hints .. ' ') or nil,
    footer_pos = 'center',
  }
end

local function compute_split_config(lines)
  local pin = config.options.window.pin
  local pos = pin.position or 'bottom'
  local split = split_direction_map[pos] or 'below'
  local is_vertical = split == 'left' or split == 'right'

  if is_vertical then
    local total = vim.o.columns
    local target = resolve_dim(pin.size, total)
    local max_s = resolve_dim(pin.max_size, total)
    local min_s = math.min(pin.min_size, max_s)
    local max_line_width = 0
    for _, line in ipairs(lines) do
      local w = vim.fn.strdisplaywidth(line)
      if w > max_line_width then
        max_line_width = w
      end
    end
    local width = math.max(min_s, math.min(max_s, math.max(target, math.min(max_line_width + 4, max_s))))
    return { split = split, win = -1, width = width }, true
  end

  local total = vim.o.lines
  local target = resolve_dim(pin.size, total)
  local max_s = resolve_dim(pin.max_size, total)
  local min_s = math.min(pin.min_size, max_s)
  local content_h = #lines + 2
  local height = math.max(min_s, math.min(max_s, math.min(content_h, math.max(target, min_s))))
  return { split = split, win = -1, height = height }, false
end

local function configure_window(win, sheet, idx, total, pinned, is_vertical)
  local wcfg = config.options.window
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].conceallevel = wcfg.conceallevel
  vim.wo[win].concealcursor = wcfg.concealcursor
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'
  vim.wo[win].foldcolumn = '0'
  vim.wo[win].colorcolumn = ''
  vim.wo[win].cursorline = true
  vim.wo[win].spell = false
  vim.wo[win].winfixheight = pinned and not is_vertical
  vim.wo[win].winfixwidth = pinned and is_vertical

  if pinned then
    local title = sheet.title:gsub('%%', '%%%%')
    local badge = sheet.source == 'override' and ' *' or ''
    local hints = build_hints(true):gsub('%%', '%%%%')
    vim.wo[win].winbar =
      string.format('%%=%%#Title# %s%s (%d/%d) %%*   %%#Comment#%s%%=', title, badge, idx, total, hints)
  else
    vim.wo[win].winbar = ''
  end
end

local function restore_prev_win()
  if state.prev_win and vim.api.nvim_win_is_valid(state.prev_win) and state.prev_win ~= state.win then
    vim.api.nvim_set_current_win(state.prev_win)
  end
end

function M.close()
  local win = state.win
  state.win = nil
  state.pinned = false
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  restore_prev_win()
end

local function ensure_buffer()
  if is_buf_valid() then
    return state.buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = 'markdown'

  local keys = config.options.window.keys
  local opts = { buffer = buf, silent = true, nowait = true }

  if keys.close then
    vim.keymap.set('n', keys.close, M.close, vim.tbl_extend('force', opts, { desc = 'Close cheatsheet' }))
  end
  if keys.close_float then
    vim.keymap.set('n', keys.close_float, function()
      if state.pinned then
        vim.cmd.nohlsearch()
      else
        M.close()
      end
    end, vim.tbl_extend('force', opts, { desc = 'Close floating cheatsheet' }))
  end
  if keys.next then
    vim.keymap.set('n', keys.next, function()
      M.cycle(1)
    end, vim.tbl_extend('force', opts, { desc = 'Next cheatsheet' }))
  end
  if keys.prev then
    vim.keymap.set('n', keys.prev, function()
      M.cycle(-1)
    end, vim.tbl_extend('force', opts, { desc = 'Previous cheatsheet' }))
  end
  if keys.pin then
    vim.keymap.set('n', keys.pin, M.toggle_pin, vim.tbl_extend('force', opts, { desc = 'Toggle split pin' }))
  end
  if keys.edit then
    vim.keymap.set('n', keys.edit, M.edit_current, vim.tbl_extend('force', opts, { desc = 'Edit cheatsheet markdown' }))
  end

  state.buf = buf
  return buf
end

local function populate_buffer(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  pcall(vim.treesitter.start, buf, 'markdown')
end

local function render(sheet, idx, total, opts)
  opts = opts or {}
  local lines = sheets_mod.read(sheet)
  local buf = ensure_buffer()
  populate_buffer(buf, lines)
  state.current_id = sheet.id

  local pos = config.options.window.pin.position or 'bottom'
  local is_vertical = pos == 'left' or pos == 'right'

  if is_win_open() then
    if state.pinned then
      vim.api.nvim_win_set_buf(state.win, buf)
      configure_window(state.win, sheet, idx, total, true, is_vertical)
      if opts.focus ~= false then
        vim.api.nvim_set_current_win(state.win)
      end
    else
      vim.api.nvim_win_set_buf(state.win, buf)
      vim.api.nvim_win_set_config(state.win, compute_float_config(lines, sheet, idx, total))
      configure_window(state.win, sheet, idx, total, false, false)
    end
    vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
    return
  end

  if opts.pinned then
    local split_cfg, vertical = compute_split_config(lines)
    local win = vim.api.nvim_open_win(buf, true, split_cfg)
    state.win = win
    state.pinned = true
    configure_window(win, sheet, idx, total, true, vertical)
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
    if opts.return_focus then
      restore_prev_win()
    end
  else
    local win = vim.api.nvim_open_win(buf, true, compute_float_config(lines, sheet, idx, total))
    state.win = win
    state.pinned = false
    configure_window(win, sheet, idx, total, false, false)
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
  end
end

---@param id? string
function M.open(id)
  if not id or id == '' then
    if state.current_id then
      id = state.current_id
    else
      M.pick()
      return
    end
  end

  local sheet, idx, all_sheets = sheets_mod.find(id)
  if not sheet then
    vim.notify('nvim-cheatsheet: sheet not found: ' .. tostring(id), vim.log.levels.WARN)
    return
  end

  local cur_win = vim.api.nvim_get_current_win()
  if not is_win_open() or cur_win ~= state.win then
    state.prev_win = cur_win
  end

  if is_win_open() then
    if state.current_id == sheet.id and cur_win == state.win then
      M.close()
      return
    end
    render(sheet, idx, #all_sheets, { focus = true })
    return
  end

  render(sheet, idx, #all_sheets, { pinned = false })
end

---@param step integer
function M.cycle(step)
  local all_sheets = sheets_mod.list()
  if #all_sheets == 0 then
    return
  end

  local current_idx = 1
  for idx, sheet in ipairs(all_sheets) do
    if sheet.id == state.current_id then
      current_idx = idx
      break
    end
  end

  local next_idx = ((current_idx - 1 + step) % #all_sheets) + 1
  render(all_sheets[next_idx], next_idx, #all_sheets, { focus = true })
end

function M.toggle_pin()
  if not is_win_open() or not state.current_id then
    return
  end

  local sheet, idx, all_sheets = sheets_mod.find(state.current_id)
  if not sheet then
    return
  end

  local target_pinned = not state.pinned
  local old_win = state.win
  state.win = nil
  state.pinned = false
  if old_win and vim.api.nvim_win_is_valid(old_win) then
    vim.api.nvim_win_close(old_win, true)
  end

  render(sheet, idx, #all_sheets, {
    pinned = target_pinned,
    return_focus = target_pinned and config.options.window.pin.return_focus,
  })
end

local function open_file_for_edit(path)
  M.close()
  vim.cmd.edit(vim.fn.fnameescape(path))
end

---@param id? string
function M.edit_current(id)
  local target_id = id or state.current_id
  if not target_id then
    vim.notify('nvim-cheatsheet: no active cheatsheet to edit', vim.log.levels.INFO)
    return
  end

  local sheet = sheets_mod.find(target_id)
  if not sheet then
    vim.notify('nvim-cheatsheet: sheet not found: ' .. tostring(target_id), vim.log.levels.WARN)
    return
  end

  if sheet.source ~= 'builtin' then
    open_file_for_edit(sheet.path)
    return
  end

  local dest = sheets_mod.user_dir() .. '/' .. sheet.file
  vim.ui.select({
    'Create local override copy (' .. vim.fn.fnamemodify(dest, ':~') .. ')',
    'Cancel',
  }, {
    prompt = string.format("'%s' is a built-in cheatsheet:", sheet.title),
  }, function(choice, idx)
    if not choice or idx ~= 1 then
      return
    end
    local copied_path, err = sheets_mod.copy_to_user_dir(sheet)
    if not copied_path then
      vim.notify('nvim-cheatsheet: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    vim.notify('nvim-cheatsheet: created override at ' .. vim.fn.fnamemodify(copied_path, ':~'), vim.log.levels.INFO)
    open_file_for_edit(copied_path)
  end)
end

function M.pick()
  local all_sheets = sheets_mod.list()
  if #all_sheets == 0 then
    vim.notify('nvim-cheatsheet: no cheatsheets found', vim.log.levels.WARN)
    return
  end

  vim.ui.select(all_sheets, {
    prompt = 'Cheatsheets:',
    format_item = function(item)
      local tag = item.source == 'override' and ' [override]' or (item.source == 'user' and ' [custom]' or '')
      if item.key then
        return string.format('[%s] %s%s', item.key, item.title, tag)
      end
      return item.title .. tag
    end,
  }, function(choice)
    if choice then
      M.open(choice.id)
    end
  end)
end

function M.is_open()
  return is_win_open()
end

function M.is_pinned()
  return is_win_open() and state.pinned
end

return M
