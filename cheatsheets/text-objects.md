# Text Objects & Operators

## Grammar

```text
{operator} + {i | a} + {object}
```

- **`i` (inner)**: contents only, excluding delimiters or surrounding whitespace
- **`a` (around)**: contents **plus** delimiters or trailing whitespace

## Common Operators

| Operator | Action |
| --- | --- |
| `c` / `d` / `y` | Change / delete / yank |
| `v` | Visually select |
| `=` / `>` / `<` | Auto-indent / indent / outdent |
| `gu` / `gU` / `g~` | Lowercase / uppercase / toggle case |
| `gq` | Format / reflow text to `textwidth` |
| `gc` | Toggle comment *(built-in in Neovim 0.10+)* |

## Built-in Text Objects

| Object | Targets |
| --- | --- |
| `iw` / `aw` | Word (alphanumeric / punctuation) |
| `iW` / `aW` | **WORD** (anything separated by whitespace) |
| `is` / `as` | Sentence |
| `ip` / `ap` | Paragraph (blank-line block) |
| `i"` / `i'` / `` i` `` | Quoted string *(searches forward on current line automatically)* |
| `i)` or `ib` | Parentheses `(...)` (`a)` / `ab` includes parens) |
| `i}` or `iB` | Curly braces `{...}` (`a}` / `aB` includes braces) |
| `i]` / `i>` | Square brackets `[...]` / angle brackets `<...>` |
| `it` / `at` | HTML / XML tag contents / entire tag |

## Linewise & Doubling Shortcuts

| Key | Action |
| --- | --- |
| `dd` / `yy` / `cc` | Delete / yank / change entire line |
| `D` / `C` / `Y` | Delete / change / yank from cursor to end of line |
| `gcc` | Toggle comment on current line *(built-in)* |
| `==` / `>>` / `<<` | Auto-indent / indent / outdent current line |

## Recipes / Examples

```text
1. Edit inside quotes anywhere on the line (cursor doesn't need to be inside):
   ci"

2. Re-indent an entire code block inside braces:
   =i{

3. Delete an entire paragraph cleanly (no stray blank line):
   dap

4. Comment out an entire paragraph or code block:
   gcip   or   gca{

5. Uppercase the current word:
   gUiw
```
