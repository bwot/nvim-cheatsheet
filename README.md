# nvim-cheatsheet

Lightweight, Markdown-backed Neovim cheatsheet viewer with floating popups, pinnable splits, Treesitter highlighting, built-in pure-Neovim sheets, and user overrides.

> **Note:** This plugin (code, built-in cheatsheets, documentation, and tests) was AI-generated based on interactive design requirements. Use and modify freely—see [LICENSE](./LICENSE).

## Features

- **Zero dependencies** — built entirely on native Neovim 0.10+ APIs (`nvim_open_win`, `vim.ui.select`, `vim.treesitter`).
- **Floating popup + pinnable split** — peek in a centered float, or press `p` to pin to a bottom/top/left/right split and return focus straight to your code window so you can reference syntax while typing `:s/...`.
- **Built-in pure-Neovim sheets + user overrides** — ships 5 balanced cheatsheets (tables + recipes):
  - `substitute` — Substitute (`:s`)
  - `motions` — Motions & Jumps
  - `text-objects` — Text Objects & Operators
  - `registers-macros` — Registers, Macros & Repeat
  - `visual-global` — Visual Block & Global Edits
- **Easy customization** — drop any `.md` file into `stdpath('config')/cheatsheet/` to add a new sheet, or name it like a built-in (e.g. `substitute.md`) to override it. Pressing `e` on a built-in prompts to create a local override copy first so edits survive plugin updates.
- **Opt-in keymaps & `which-key` support** — always exposes `:Cheatsheet`, with optional prefix keymaps and automatic `which-key` group registration.

## Requirements

- Neovim >= 0.10 (recommended: Treesitter `markdown` and `markdown_inline` parsers for rich highlighting)

## Installation

### `vim.pack` (Neovim 0.12+)

```lua
vim.pack.add { 'https://github.com/<your-user>/nvim-cheatsheet' }

require('nvim-cheatsheet').setup {
  keymaps = {
    prefix = '<leader>h',
  },
}
```

### `lazy.nvim`

```lua
{
  '<your-user>/nvim-cheatsheet',
  cmd = 'Cheatsheet',
  opts = {
    keymaps = {
      prefix = '<leader>h',
    },
  },
}
```

## Usage

### Commands

- `:Cheatsheet` or `:Cheatsheet pick` — Open interactive cheatsheet picker
- `:Cheatsheet <id>` — Open a specific cheatsheet (supports tab completion)
- `:Cheatsheet pin` — Toggle floating / pinned split mode
- `:Cheatsheet edit` — Edit the active cheatsheet (prompts to create override for built-ins)
- `:Cheatsheet close` — Close the cheatsheet window

### Buffer Controls (inside the cheatsheet window)

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Cycle next / previous cheatsheet |
| `p` | Toggle between centered float and pinned split |
| `e` | Edit the markdown file (prompts to copy built-ins to user dir) |
| `q` | Close cheatsheet window |
| `<Esc>` | Close when floating; clear search highlights when pinned |

## Configuration

All options and their defaults:

```lua
require('nvim-cheatsheet').setup {
  -- Directory for user cheatsheets and overrides of built-ins
  dir = vim.fn.stdpath 'config' .. '/cheatsheet',

  -- Include the 5 bundled pure-Neovim cheatsheets
  include_builtins = true,

  -- Per-sheet metadata overrides (title, key, order)
  sheets = {
    -- personal = { title = 'My Config', key = 'p', order = 5 },
  },

  -- Opt-in keymaps: false (default), true (uses <leader>h), or table
  keymaps = false,
  -- keymaps = {
  --   prefix = '<leader>h',
  --   group = 'Help / Cheatsheets',
  --   picker = 'h',        -- <leader>hh (set false to disable)
  --   which_key = true,    -- auto-register group if which-key is installed
  --   sheets = {
  --     -- substitute = 's',
  --     -- personal = 'p',
  --   },
  -- },

  window = {
    border = 'rounded',    -- string|table|nil (nil inherits vim.o.winborder)
    max_width = 0.86,      -- fraction (0..1) or fixed columns (>1)
    max_height = 0.82,     -- fraction (0..1) or fixed lines (>1)
    min_width = 68,
    min_height = 12,
    conceallevel = 2,
    concealcursor = 'nc',
    pin = {
      position = 'bottom', -- 'bottom' | 'top' | 'right' | 'left'
      size = 0.36,         -- fraction (0..1) or fixed lines/columns (>1)
      max_size = 0.45,
      min_size = 10,
      return_focus = true, -- jump back to code window when pinning
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
```

## License

Released into the public domain under [The Unlicense](./LICENSE).
