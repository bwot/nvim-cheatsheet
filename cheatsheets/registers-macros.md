# Registers, Macros & Repeat

## Essential Registers

Prefix `y`, `d`, `c`, or `p` with `"{reg}` (e.g. `"0p`, `"_dd`, `"ayiw`).

| Register | Contents |
| --- | --- |
| `""` | Unnamed — last yank, delete, or change |
| `"0` | **Yank register** — last `y` only (not overwritten by `d`/`c`/`x`!) |
| `"+` / `"*` | System clipboard / X11 primary selection |
| `"_` | **Black hole** — discard deleted text without touching registers |
| `"a`–`"z` | Named registers (`"A`–`"Z` **appends** to that register) |
| `"1`–`"9` | Last 9 multi-line deletes (`"1` = most recent) |
| `"/` / `":` | Last search pattern / last Ex command |
| `"%` | Current file path |
| `:reg` | Show all register contents (`:reg a 0 +` to filter) |

## Pasting Registers in Insert & Command Mode

| Key | Action |
| --- | --- |
| `<C-r>{reg}` | Insert contents of `{reg}` (e.g. `<C-r>0`, `<C-r>+`, `<C-r>/`) |
| `<C-r><C-w>` | Paste word under cursor into command line (`:` or `/`) |
| `<C-r><C-a>` | Paste WORD under cursor into command line |
| `<C-r>={expr}<CR>` | Evaluate expression & insert result (inline calculator!) |

## Repeat & Change History

| Key | Action |
| --- | --- |
| `.` | Repeat last normal-mode change |
| `;` / `,` | Repeat / reverse last `f`/`t` motion |
| `&` / `g&` | Repeat last `:s` on current line / entire file |
| `g;` / `g,` | Jump to older / newer change location |
| `u` / `<C-r>` | Undo / redo (`g-` / `g+` walks undo branches chronologically) |

## Macros

| Key | Action |
| --- | --- |
| `q{a-z}` | Start recording macro into register `{a-z}` |
| `q` | Stop recording |
| `@{a-z}` | Play macro `{a-z}` |
| `@@` | Replay the most recently run macro |
| `{n}@{a}` | Play macro `{a}` `n` times |
| `q{A-Z}` | Append more keystrokes to existing macro `{a-z}` |
| `:'<,'>norm @{a}` | Run macro `{a}` on every visually selected line |

## Recipes / Examples

```text
1. Replace one word with another you just yanked (without losing the yank):
   yiw  ->  move to target  ->  "_diw  ->  p    (or just: diw then "0p)

2. Record a clean, repeatable macro on multiple lines:
   qq       start recording into `q`
   0        anchor cursor at start of line (crucial for reliability!)
   ...      perform edit
   j        optional: step down (skip if using :norm @q)
   q        stop recording
   5@q      replay 5 times   (or visually select lines -> :norm @q)

3. Edit a macro in register `q` without re-recording it:
   "qp      paste macro text into buffer -> fix it -> 0"qy$

4. Quick math in Insert mode:
   <C-r>=16 * 1024<CR>   ->  inserts 16384
```
