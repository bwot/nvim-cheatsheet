-- Standalone headless test suite for nvim-cheatsheet
-- Run from the plugin root:
--   nvim --headless -u NONE -i NONE --cmd 'set rtp+=.' -l tests/run.lua

local tmp_dir = vim.fn.tempname()
vim.fn.mkdir(tmp_dir, 'p')

-- Source plugin entry point
vim.cmd.runtime 'plugin/nvim-cheatsheet.lua'

local cs = require 'nvim-cheatsheet'
cs.setup {
  dir = tmp_dir,
  keymaps = {
    prefix = '<leader>h',
    sheets = {
      custom = 'c',
    },
  },
}

-- Add a custom user sheet to verify auto-discovery
vim.fn.writefile({ '# Custom Sheet', '', 'Hello from user dir.' }, tmp_dir .. '/custom.md')

-- Re-run setup so custom sheet keymap gets registered too
cs.setup {
  dir = tmp_dir,
  keymaps = {
    prefix = '<leader>h',
    sheets = {
      custom = 'c',
    },
  },
}

local orig_win = vim.api.nvim_get_current_win()

-- 1. Built-ins + custom sheet discovered
local list = cs.list()
assert(#list == 6, 'expected 5 built-ins + 1 custom sheet, got ' .. #list)
assert(list[1].id == 'substitute' and list[1].source == 'builtin', 'expected substitute built-in first')
assert(list[6].id == 'custom' and list[6].source == 'user', 'expected custom user sheet last')

-- 2. Open floating window
cs.open 'substitute'
assert(cs.is_open() and not cs.is_pinned(), 'expected open floating window')
local float_win = vim.api.nvim_get_current_win()
assert(float_win ~= orig_win, 'expected float focus')
assert(vim.api.nvim_win_get_config(float_win).relative == 'editor', 'expected editor float')
assert(vim.bo.filetype == 'markdown', 'expected markdown filetype')
assert(vim.wo[float_win].conceallevel == 2, 'expected conceallevel 2')

-- 3. Cycle sheets
cs.cycle(1)
assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '# Motions & Jumps', 'cycle(1) failed')
cs.cycle(-1)
assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '# Substitute (`:s`)', 'cycle(-1) failed')

-- 4. Pin to bottom split -> focus returns to orig_win
cs.toggle_pin()
assert(cs.is_open() and cs.is_pinned(), 'expected pinned window')
assert(vim.api.nvim_get_current_win() == orig_win, 'expected focus returned to code window')
local wins = vim.api.nvim_tabpage_list_wins(0)
assert(#wins == 2, 'expected 2 windows, got ' .. #wins)
local split_win = wins[1] == orig_win and wins[2] or wins[1]
assert(vim.api.nvim_win_get_config(split_win).relative == '', 'expected non-float split')
assert(vim.wo[split_win].winfixheight == true, 'expected winfixheight on bottom split')

-- 5. Calling open from code window focuses pinned split & switches sheet
cs.open 'visual-global'
assert(vim.api.nvim_get_current_win() == split_win, 'expected pinned split focused')
assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '# Visual Block & Global Edits', 'switch failed')

-- 6. Unpin back to floating
cs.toggle_pin()
assert(cs.is_open() and not cs.is_pinned(), 'expected unpinned float')

-- 7. Built-in edit prompts before copying (test cancel then confirm)
local orig_select = vim.ui.select
local prompt_seen = false
vim.ui.select = function(items, opts, on_choice)
  prompt_seen = true
  on_choice(items[2], 2) -- Cancel
end
cs.edit()
assert(prompt_seen, 'expected prompt when editing built-in')
assert(vim.uv.fs_stat(tmp_dir .. '/visual-global.md') == nil, 'cancel should not copy file')

vim.ui.select = function(items, opts, on_choice)
  on_choice(items[1], 1) -- Confirm copy
end
cs.edit()
vim.ui.select = orig_select
assert(vim.uv.fs_stat(tmp_dir .. '/visual-global.md') ~= nil, 'confirm should create override copy')
assert(vim.api.nvim_buf_get_name(0):match 'visual%-global%.md$', 'should open copied override file')

-- 8. Override takes precedence over built-in
local overridden = vim.tbl_filter(function(s)
  return s.id == 'visual-global'
end, cs.list())[1]
assert(overridden and overridden.source == 'override', 'expected source=override after copy')

-- 9. Direct edit on user sheet does NOT prompt
local prompted_user = false
vim.ui.select = function()
  prompted_user = true
end
cs.open 'custom'
cs.edit()
vim.ui.select = orig_select
assert(not prompted_user, 'user sheet edit should not prompt')
assert(vim.api.nvim_buf_get_name(0):match 'custom%.md$', 'should open custom.md directly')

-- 10. :Cheatsheet user command & completion
assert(vim.fn.exists ':Cheatsheet' == 2, 'expected :Cheatsheet command')
vim.cmd 'Cheatsheet motions'
assert(cs.is_open(), 'expected :Cheatsheet motions to open window')
vim.cmd 'Cheatsheet close'
assert(not cs.is_open(), 'expected :Cheatsheet close to close window')

-- 11. Right-side vertical pin position works too
cs.setup {
  dir = tmp_dir,
  window = {
    pin = { position = 'right', return_focus = false },
  },
}
cs.open 'motions'
cs.toggle_pin()
assert(cs.is_pinned(), 'expected right split pinned')
assert(vim.wo[vim.api.nvim_get_current_win()].winfixwidth == true, 'expected winfixwidth on right split')
cs.close()

-- Clean up temp dir
vim.fn.delete(tmp_dir, 'rf')

print 'ALL NVIM-CHEATSHEET PLUGIN TESTS PASSED'
