# nvim-cheatsheet

Lightweight, Markdown-backed Neovim cheatsheet viewer with floating popups, pinnable splits, Treesitter highlighting, built-in pure-Neovim sheets, and custom user sheets.

> **Note:** This plugin (code, built-in cheatsheets, documentation, and tests) was AI-generated based on interactive design requirements. Use and modify freely—see [LICENSE](./LICENSE).

## Features

- **Zero dependencies** — built entirely on native Neovim 0.10+ APIs (`nvim_open_win`, `vim.ui.select`, `vim.treesitter`).
- **Peek or pin while you work** — open a centered floating popup for a quick glance, or press `p` to pin it to a split (`bottom`, `top`, `left`, or `right`) and jump focus straight back to your code so you can reference syntax while typing commands like `:s/...`.
- **5 built-in pure-Neovim cheatsheets** — concise tables + practical recipes out of the box:
  - `substitute` — Substitute (`:s`)
  - `motions` — Motions & Jumps
  - `text-objects` — Text Objects & Operators
  - `registers-macros` — Registers, Macros & Repeat
  - `visual-global` — Visual Block & Global Edits
- **Custom & overridable sheets** — add your own Markdown files for personal keymaps or tools, or press `e` on any built-in sheet to copy and customize it locally without losing edits on plugin updates.
- **Opt-in keymaps & `which-key` support** — always exposes `:Cheatsheet`, with optional prefix shortcuts and automatic `which-key` group registration.

## Requirements

- Neovim >= 0.10
- Optional (recommended): Treesitter `markdown` and `markdown_inline` parsers for rich Markdown highlighting

## Installation

Works out of the box with `:Cheatsheet` — calling `setup()` is only needed if you want to enable keymaps or change defaults.

### `vim.pack` (Neovim 0.12+)

```lua
vim.pack.add { 'https://github.com/bwot/nvim-cheatsheet' }
```

### `lazy.nvim`

```lua
{
  'bwot/nvim-cheatsheet',
  cmd = 'Cheatsheet',
}
```

### Optional: Enabling Keymaps

Keymaps are disabled by default so the plugin never collides with your existing bindings. To enable prefix shortcuts (default `<leader>h`) and `which-key` group registration, call `setup()` with `keymaps`:

```lua
-- vim.pack / init.lua
require('nvim-cheatsheet').setup {
  keymaps = {
    prefix = '<leader>h', -- or simply `keymaps = true` for defaults
  },
}
```

> **Note for `lazy.nvim` users:** If you enable `keymaps`, remove `cmd = 'Cheatsheet'` (or replace it with `event = 'VeryLazy'`) so the plugin loads on startup and registers your shortcuts:
>
> ```lua
> {
>   'bwot/nvim-cheatsheet',
>   event = 'VeryLazy',
>   opts = {
>     keymaps = {
>       prefix = '<leader>h',
>     },
>   },
> }
> ```

With `prefix = '<leader>h'`, the following Normal-mode mappings are created:

| Key | Action |
| --- | --- |
| `<leader>hh` | Browse all cheatsheets (picker) |
| `<leader>hs` | Substitute (`:s`) |
| `<leader>hm` | Motions & Jumps |
| `<leader>ht` | Text Objects & Operators |
| `<leader>hr` | Registers, Macros & Repeat |
| `<leader>hv` | Visual Block & Global Edits |

## Usage

### Commands

| Command | Description |
| --- | --- |
| `:Cheatsheet` or `:Cheatsheet pick` | Open interactive cheatsheet picker |
| `:Cheatsheet <id>` | Open a specific sheet by ID (supports `<Tab>` completion) |
| `:Cheatsheet pin` | Toggle between floating popup and pinned split |
| `:Cheatsheet edit` | Edit the active sheet (prompts to create a local copy for built-ins) |
| `:Cheatsheet close` | Close the cheatsheet window |

### Controls Inside the Cheatsheet Window

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Cycle to the next / previous cheatsheet |
| `p` | Toggle between centered float and pinned split |
| `e` | Edit the current Markdown file |
| `q` | Close the cheatsheet window |
| `<Esc>` | Close when floating; clear search highlights (`:nohlsearch`) when pinned |

## Custom Cheatsheets

You can add your own cheatsheets or customize any built-in sheet by placing standard `.md` files in your Neovim config's `cheatsheet/` directory:

- **macOS / Linux:** `~/.config/nvim/cheatsheet/`
- **Windows:** `%LOCALAPPDATA%\nvim\cheatsheet\`
- *(Matches `vim.fn.stdpath('config') .. '/cheatsheet'`, configurable via `dir`.)*

### Adding a New Sheet

1. Create a Markdown file in that folder, e.g. `~/.config/nvim/cheatsheet/my-keymaps.md`.
2. The filename automatically becomes the sheet ID (`my-keymaps`) and display title (`My Keymaps`).
3. Open it immediately with `:Cheatsheet my-keymaps` or select it in `:Cheatsheet` — new files are discovered automatically without restarting Neovim.

To pin your sheet to the top of the list, customize its title, or bind a shortcut key under your prefix, add an entry under `sheets` in `setup()`:

```lua
require('nvim-cheatsheet').setup {
  keymaps = { prefix = '<leader>h' },
  sheets = {
    ['my-keymaps'] = {
      title = 'My Workflow',
      key = 'k',   -- opens with <leader>hk
      order = 1,   -- appear first (built-ins use 10..50)
    },
  },
}
```

### Example User Cheatsheet

Save this as `~/.config/nvim/cheatsheet/my-keymaps.md` and run `:Cheatsheet my-keymaps` (then press `p` whenever you want to keep it pinned while working):

```markdown
# My Neovim Workflow

## LSP & Diagnostics

| Key | Action |
| --- | --- |
| `grd` / `grr` | Go to definition / list references |
| `grn` / `gra` | Rename symbol / code action |
| `K` | Hover docs (press again to enter float) |
| `[d` / `]d` | Previous / next diagnostic |

## Search & Files (Telescope)

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files in project |
| `<leader>fg` | Live grep across workspace |
| `<leader>fb` | Switch open buffers |
| `<C-q>` *(in picker)* | Send results to Quickfix list |

## Git Hunks & Quickfix

| Key | Action |
| --- | --- |
| `]c` / `[c` | Next / previous Git hunk |
| `<leader>gp` / `<leader>gr` | Preview / reset hunk under cursor |
| `]q` / `[q` | Next / previous Quickfix item |
| `:cdo s/old/new/gc \| update` | Search & replace across Quickfix files |
```

### Overriding a Built-in Sheet

There are two ways to tweak a bundled sheet (such as `substitute.md` or `motions.md`) so your changes survive plugin updates:

1. **From inside Neovim (easiest):** open the built-in sheet and press `e`. You'll be prompted to copy it into `~/.config/nvim/cheatsheet/` and open the local copy for editing.
2. **Manually:** create a file with the same filename as a built-in (e.g. `~/.config/nvim/cheatsheet/substitute.md`).

Overridden sheets take precedence over the bundled version and show `*` in the window title (`[override]` in the picker). Delete your local file at any time to restore the built-in sheet.

## Configuration

Pass any options you want to change to `require('nvim-cheatsheet').setup { ... }`. Below are all available options and their defaults:

```lua
require('nvim-cheatsheet').setup {
  -- Folder scanned for your custom sheets and overrides of built-ins
  -- (defaults to ~/.config/nvim/cheatsheet on macOS/Linux)
  dir = vim.fn.stdpath 'config' .. '/cheatsheet',

  -- Set to false to show only your own sheets from `dir`
  include_builtins = true,

  -- Per-sheet metadata overrides keyed by sheet ID (filename without .md)
  sheets = {
    -- ['my-keymaps'] = { title = 'My Workflow', key = 'k', order = 1 },
    -- substitute = { key = false }, -- disable a sheet's prefix keymap
  },

  -- Opt-in prefix keymaps:
  --   false (default) -> commands only (:Cheatsheet)
  --   true            -> enable defaults (<leader>h prefix + which-key)
  --   table           -> customize any field below
  keymaps = false,
  -- keymaps = {
  --   prefix = '<leader>h',
  --   group = 'Help / Cheatsheets', -- which-key group label
  --   picker = 'h',                 -- <leader>hh (set false to disable)
  --   which_key = true,             -- auto-register group if which-key is installed
  --   sheets = {
  --     -- Override per-sheet key suffixes here (or under top-level `sheets`)
  --     -- substitute = 's',
  --     -- ['my-keymaps'] = 'k',
  --   },
  -- },

  window = {
    border = 'rounded',    -- string | table | nil (nil inherits vim.o.winborder)
    max_width = 0.86,      -- fraction of screen (0..1) or fixed columns (>1)
    max_height = 0.82,     -- fraction of screen (0..1) or fixed lines (>1)
    min_width = 68,
    min_height = 12,
    conceallevel = 2,      -- hides Markdown syntax markers cleanly
    concealcursor = 'nc',
    pin = {
      position = 'bottom', -- 'bottom' | 'top' | 'right' | 'left'
      size = 0.36,         -- fraction (0..1) or fixed lines/columns (>1)
      max_size = 0.45,
      min_size = 10,
      return_focus = true, -- jump back to your code window after pinning
    },
    -- Buffer-local keys inside the cheatsheet window (set any to false to disable)
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
