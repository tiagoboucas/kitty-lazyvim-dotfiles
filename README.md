# dotfiles

Omarchy-flavoured macOS terminal + editor. One repo, replayable on a fresh Mac.

## What's in here

| Area | File | Notes |
|------|------|-------|
| Terminal | `alacritty/alacritty.toml` | FiraCode Nerd Font Mono @ 11, Tokyo Night, macOS window tweaks |
| Palette | `alacritty/themes/tokyo-night.toml` | Omarchy Tokyo Night, 1:1 from `omacom/omarchy` |
| Tabs | `tmux/tmux.conf` | Alacritty has no tabs — tmux windows are the tabs. Omarchy config |
| Prompt | `starship/starship.toml` | Omarchy starship, 1:1 |
| Shell | `zshrc` | oh-my-zsh + starship + zoxide/fzf/eza/bat; auto-`exec tmux` inside Alacritty |
| Editor | `nvim/` | LazyVim + `nvim/lua/plugins/tokyonight.lua` → `tokyonight-night` |
| Claude Code | `claude/settings.partial.json` | `theme: dark-ansi` → inherits the terminal palette |
| Wallpaper | `wallpapers/` | Omarchy Tokyo Night backgrounds; `tokyo-night-sunset-lake.png` is active |
| Legacy | `kitty/` | previous terminal, kept for parity |

## Install on a new Mac

```sh
git clone git@github.com:tiagoboucas/kitty-lazyvim-dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` runs `brew bundle`, downloads the official **Alacritty DMG**
(Homebrew disabled the cask on 2026-09-01 — Gatekeeper), symlinks every config,
merges `theme: dark-ansi` into `~/.claude/settings.json` with `jq` (nothing else
in that file is touched, and the full file is **not** committed — this repo is
public), pins `org.alacritty AppleFontSmoothing = 2` (this is what controls the
perceived font weight — 0 thinnest … 3 heaviest), and sets the wallpaper.

Existing real files are moved to `*.bak.<timestamp>` before being symlinked.

## Font / size / weight

Guaranteed identical on any machine by three things, all version-controlled:

1. `Brewfile` → `cask "font-fira-code-nerd-font"`
2. `alacritty/alacritty.toml` → `family = "FiraCode Nerd Font Mono"`, `size = 11`
3. `install.sh` → `defaults write org.alacritty AppleFontSmoothing -int 2`

## Tabs (tmux)

Prefix is **Ctrl-Space** (Ctrl-b also works).

| Key | Action |
|-----|--------|
| `Prefix c` | new tab | 
| `Alt-1..9` | jump to tab N |
| `Alt-←` / `Alt-→` | prev / next tab |
| `Alt-Shift-←/→` | move tab |
| `Prefix r` | rename tab |
| `Prefix k` | close tab |
| `Alt-Enter` / `Alt-Shift-Enter` | split down / right |

Set `NO_AUTO_TMUX=1` to stop Alacritty auto-starting tmux.

## Switching theme

Drop another Omarchy palette next to `alacritty/themes/tokyo-night.toml`
(same key layout), point `general.import` at it, and set the matching
`colorscheme` in `nvim/lua/plugins/tokyonight.lua`. Claude Code follows the
terminal automatically via `dark-ansi`.
