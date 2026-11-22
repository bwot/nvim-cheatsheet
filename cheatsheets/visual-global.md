# Visual Block & Global Edits

## Visual Modes

| Key | Mode / Action |
| --- | --- |
| `v` / `V` / `<C-v>` | Characterwise / Linewise / **Blockwise** (column) selection |
| `gv` | Re-select the last visual selection |
| `o` / `O` | Jump cursor to the opposite end / corner of selection |

## Visual Block (`<C-v>`) Power Moves

Select a vertical column with `<C-v>` + `j`/`k`, then:

| Key | Effect across every selected line |
| --- | --- |
| `I{text}<Esc>` | Insert `{text}` at the **left** edge of the block |
| `A{text}<Esc>` | Append `{text}` at the **right** edge *(press `$` first for ragged lines!)* |
| `c{text}<Esc>` | Change selected block to `{text}` on every line |
| `r{c}` | Replace every character in the block with `{c}` |
| `<C-a>` / `<C-x>` | Increment / decrement every number in selection by 1 |
| `g<C-a>` / `g<C-x>` | **Sequentially** increment / decrement (`1, 2, 3, 4...`) |

## `:norm[al]` — Replay Normal Keys Across Lines

```vim
:[range]norm[al][!] {normal-keys}
```

| Command | Effect |
| --- | --- |
| `:'<,'>norm A;` | Append `;` to the end of every selected line |
| `:%norm I// ` | Prepend `// ` to every line in the file |
| `:'<,'>norm @q` | Execute macro `q` on every selected line |
| `:'<,'>norm! ...` | Use `!` to ignore custom keymaps (raw built-in keys) |

## `:g[lobal]` & `:v[global]` — Filter Lines & Run Ex Commands

```vim
:[range]g/{pattern}/{cmd}      " run {cmd} on lines MATCHING {pattern}
:[range]v/{pattern}/{cmd}      " run {cmd} on lines NOT matching {pattern}
```

| Command | Effect |
| --- | --- |
| `:g/pat/d` | Delete every line matching `pat` |
| `:v/pat/d` | **Keep only** lines matching `pat` (delete all others) |
| `:g/^\s*$/d` | Delete all empty / whitespace-only lines |
| `:g/pat/m $` | Move all matching lines to the bottom of the file |
| `:g/pat/t $` | Copy all matching lines to the bottom of the file |
| `:g/pat/y A` | Collect all matching lines into register `a` (`qaq` clears `a` first) |
| `:g/pat/norm ...` | Run a Normal-mode edit on every matching line |
| `:g/pat/s/a/b/g` | Substitute `a` -> `b` **only** on lines matching `pat` |

## Recipes / Examples

```vim
" 1. Append a trailing comma to lines of different lengths
"    <C-v> down across lines -> $ -> A,<Esc>

" 2. Create a sequential 1..N list from zeros
"    <C-v> down over column of `0`s -> g<C-a>

" 3. Extract every TODO line in the buffer into the system clipboard
qaq
:g/TODO/y A
:let @+ = @a

" 4. Filter a huge log file down to only ERROR lines
:v/ERROR/d

" 5. Append a comment to every line matching a pattern
:g/DEBUG/norm A // remove before merge
```
