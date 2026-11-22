# Motions & Jumps

## Horizontal (In-Line)

| Key | Movement |
| --- | --- |
| `w` / `b` / `e` | Next word start / prev word start / word end |
| `W` / `B` / `E` | Same for whitespace-delimited **WORD**s |
| `ge` / `gE` | End of previous word / WORD |
| `0` / `^` / `$` | Line start / first non-blank / line end (`g0`/`g^`/`g$` for wrapped) |
| `f{c}` / `F{c}` | Jump **onto** next / previous `{c}` on current line |
| `t{c}` / `T{c}` | Jump **before** next / previous `{c}` on current line |
| `;` / `,` | Repeat / reverse last `f`, `F`, `t`, `T` |

## Vertical & Screen

| Key | Movement |
| --- | --- |
| `j` / `k` | Down / up line (`gj` / `gk` for wrapped display lines) |
| `{n}j` / `{n}k` | Jump `n` lines down / up |
| `{` / `}` | Previous / next blank-line paragraph |
| `gg` / `G` / `{n}G` | Top of file / bottom of file / line `{n}` |
| `H` / `M` / `L` | Top / middle / bottom of visible screen |
| `<C-d>` / `<C-u>` | Scroll half-page down / up |
| `zz` / `zt` / `zb` | Center / top / bottom screen on cursor line |

## Code Structure & Brackets

| Key | Movement |
| --- | --- |
| `%` | Jump to matching `()`, `[]`, `{}`, or comment/keyword pair |
| `[{` / `]}` | Jump to enclosing unmatched `{` / `}` |
| `[(` / `])` | Jump to enclosing unmatched `(` / `)` |
| `[[` / `]]` | Previous / next top-level section or `{` in column 1 |
| `[d` / `]d` | Previous / next diagnostic (built-in in Neovim 0.10+) |

## Search

| Key | Action |
| --- | --- |
| `/` / `?` | Search forward / backward |
| `n` / `N` | Next / previous match |
| `*` / `#` | Search whole word under cursor forward / backward |
| `g*` / `g#` | Search partial word under cursor forward / backward |
| `<C-l>` / `:noh` | Clear search highlights |

## Jumplist, Changelist & Marks

| Key | Action |
| --- | --- |
| `<C-o>` / `<C-i>` | Jump **older** / **newer** in jumplist (even across files) |
| `''` / `` `` `` | Bounce back to previous jump line / exact cursor position |
| `g;` / `g,` | Walk older / newer edit positions in changelist |
| `` `. `` / `gi` | Last edit position / jump to last Insert pos & enter Insert |
| `m{a-z}` | Set buffer-local mark (`m{A-Z}` = global across files) |
| `'{m}` / `` `{m} `` | Jump to mark line / exact column |

## Recipes / Examples

```text
1. Jump to definition & bounce right back:
   gd  ->  read code  ->  <C-o>  (returns to exact spot)

2. Jump to where you were just typing after scrolling away:
   gi  (jumps back AND enters Insert mode)   or   g;  (stays in Normal)

3. Delete up to a comma on the current line:
   dt,  (deletes till `,`)   or   df,  (includes `,`)

4. Bookmark a spot across files:
   mA  ->  navigate elsewhere  ->  'A  (jumps back to file & line)
```
