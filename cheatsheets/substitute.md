# Substitute (`:s`)

## Syntax

```vim
:[range]s[ubstitute]/{pattern}/{replacement}/[flags]
```

> Any punctuation works as a delimiter — e.g. `:s#old/path#new/path#g` or `:s|foo|bar|g`.

## Ranges

| Range | Scope |
| --- | --- |
| *(none)* | Current line only |
| `%` | Entire file (`1,$`) |
| `'<,'>` | Visual selection (auto-inserted when typing `:` in Visual mode) |
| `10,20` | Lines 10 through 20 |
| `.,+5` | Current line and the next 5 lines |
| `.,$` | Current line to end of file |
| `/foo/,/bar/` | From next line matching `foo` to line matching `bar` |

## Flags

| Flag | Effect |
| --- | --- |
| `g` | Replace **all** matches on each line (default: first match only) |
| `c` | **Confirm** each match (`y` yes, `n` no, `a` all, `q` quit, `l` last) |
| `i` / `I` | Force case-insensitive / case-sensitive |
| `n` | Count matches only (no replacement) |
| `e` | Suppress error when pattern is not found |

## Pattern & Magic

| Token | Meaning |
| --- | --- |
| `\v` | **Very magic** — PCRE-like regex (no escaping `()`, `+`, `?`, `|`, `{}`) |
| `\V` | **Very nomagic** — match text literally (only `\` is special) |
| `\<word\>` | Match whole word boundaries |
| `\%V` | Restrict match strictly to inside the Visual selection |
| `//` *(empty)* | Reuse the last `/` search pattern |

## Replacement Specials

| Token | Inserts |
| --- | --- |
| `&` or `\0` | Entire matched text |
| `\1` .. `\9` | Capture groups 1–9 |
| `\r` / `\t` | Newline / Tab |
| `\u` / `\l` | Uppercase / lowercase the **next** character |
| `\U` / `\L` .. `\E` | Uppercase / lowercase **until** `\E` (or end) |
| `\=expr` | Evaluate Vimscript/Lua expression (e.g. `\=line('.')`) |

## Quick Shortcuts

| Key | Action |
| --- | --- |
| `&` | Repeat last `:s` on current line (without flags) |
| `:&&` | Repeat last `:s` on current line **with** previous flags |
| `g&` | Repeat last `:s` across entire file with flags (`:%s//~/&`) |
| `<C-r><C-w>` | Paste word under cursor into command line |
| `<C-r>/` | Paste last search pattern into command line |

## Recipes / Examples

```vim
" 1. Replace word under cursor across file with confirmation
"    Press * on the word first, then:
:%s//new_name/gc

" 2. Replace ONLY inside a character/block visual selection
:'<,'>s/\%Vold/new/g

" 3. Swap two comma-separated arguments (using \v very magic)
:%s/\v(\w+),\s*(\w+)/\2, \1/g

" 4. Replace paths or URLs without escaping slashes
:%s#http://old.dev#https://new.dev#g

" 5. Convert snake_case to camelCase
:%s/_\([a-z]\)/\u\1/g

" 6. Strip trailing whitespace without error if already clean
:%s/\s\+$//e

" 7. Number occurrences dynamically with an expression
:%s/TODO/\='TODO #' . line('.')/g
```
