# Keymaps

`<leader>` is **space**. Press `<leader>` alone and which-key lists what follows.
`<leader>?` shows buffer-local keymaps. `:LazyExtras` toggles feature sets.

## Files & search

| Key | Action |
|---|---|
| `<leader><space>` | Find file in project |
| `<leader>ff` / `<leader>fF` | Find file (root / cwd) |
| `<leader>fr` | Recent files |
| `<leader>/` | Live grep in project |
| `<leader>sg` / `<leader>sw` | Grep / grep word under cursor |
| `<leader>ss` | Symbols in buffer |
| `<leader>e` | File explorer |
| `<leader>bd` | Close buffer |
| `H` / `L` | Previous / next buffer |

## Harpoon

| Key | Action |
|---|---|
| `<leader>H` | Pin current file |
| `<leader>h` | Open pinned list |
| `<leader>1`..`<leader>5` | Jump to pin 1-5 |

## LSP

| Key | Action |
|---|---|
| `gd` / `gr` | Go to definition / references |
| `gI` / `gy` | Implementation / type definition |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename (incremental, live preview) |
| `<leader>cf` | Format buffer |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>xx` | Diagnostics list |

## Refactoring

| Key | Action |
|---|---|
| `<leader>rs` | Refactor menu (visual mode too) |

## Git

| Key | Action |
|---|---|
| `<leader>gg` | lazygit |
| `<leader>gb` | Line blame |
| `]h` / `[h` | Next / previous hunk |
| `<leader>ghs` / `<leader>ghr` | Stage / reset hunk |

## Debugger (DAP)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Start / continue |
| `<leader>di` / `<leader>do` | Step into / out |
| `<leader>dO` | Step over |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | Open REPL |
| `<leader>dt` | Terminate session |

## Tests (neotest)

| Key | Action |
|---|---|
| `<leader>tt` | Run tests in file |
| `<leader>tr` | Run nearest test |
| `<leader>tl` | Re-run last test |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |
| `<leader>tS` | Stop running tests |

## Windows

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>\|` / `<leader>-` | Split vertical / horizontal |
| `<C-Up/Down/Left/Right>` | Resize split |

## kitty

| Key | Action |
|---|---|
| `f1` | New window in current directory |
| `f2` | Open `vim .` in current directory |
| `cmd+ctrl+,` | Reload kitty config |
| `ctrl+shift+Enter` | New window |
| `ctrl+shift+t` | New tab |
| `ctrl+shift+l` | Next layout |

## Kitty (terminal)

| Key | Action |
|---|---|
| `cmd+t` | New tab (same directory) |
| `cmd+w` | Close tab |
| `cmd+]` / `cmd+[` | Next / previous tab |
| `cmd+1..9` | Go to tab N |
| `cmd+shift+]` / `cmd+shift+[` | Move tab right / left |
| `cmd+alt+t` | Rename tab |
| drag tab | Reorder (never detaches) |
| click `✕` on tab / middle-click | Close tab |
| `cmd+d` / `cmd+shift+d` | Split right / down |
| `cmd+alt+arrows` | Move between splits |
| `cmd+shift+z` | Zoom split (stack layout) |
| `cmd+r` | Resize split |
| `cmd+f` | Search scrollback |
| `cmd+k` | Clear screen |
| `cmd+shift+e` | Open a URL from screen (hints) |
| `cmd+shift+p` | Insert a path from screen (hints) |
| `cmd+,` / `cmd+shift+r` | Edit / reload config |

## Shell (zsh)

| Key | Action |
|---|---|
| `→` | Accept inline autosuggestion |
| `ctrl+r` | Fuzzy history search (fzf) |
| `ctrl+t` | Fuzzy file picker (fzf) |
| `alt+c` | Fuzzy cd (fzf) |
| `z <name>` | Jump to a frecent directory (zoxide) |
