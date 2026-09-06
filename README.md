# dotfiles

Omarchy-flavoured macOS terminal + editor. One repo, replayable on a fresh Mac.

## What's in here

| Area | File | Notes |
|------|------|-------|
| Terminal | `ghostty/config` | **primary** — FiraCode Nerd Font Mono @ 11, Tokyo Night, native tabs/splits, transparent titlebar |
| Terminal (fallback) | `alacritty/alacritty.toml` | same palette/font/keybinds; kept for parity |
| Palette | `alacritty/themes/tokyo-night.toml` | Omarchy Tokyo Night, 1:1 from `omacom/omarchy`; `ghostty/config` inlines the same values |
| Prompt | `starship/starship.toml` | Omarchy starship, 1:1 |
| Shell | `zshrc` | oh-my-zsh + starship + zoxide/fzf/eza/bat |
| tmux | `tmux/tmux.conf` | Omarchy config, symlinked — **not** auto-started; run `tmux` yourself if you want splits/windows |
| Editor | `nvim/` | LazyVim + `nvim/lua/plugins/tokyonight.lua` → `tokyonight-night` |
| Claude Code | `claude/settings.partial.json` | `theme: dark-ansi` → inherits the terminal palette |
| Wallpaper | `wallpapers/` | Omarchy Tokyo Night backgrounds; `tokyo-night-sunset-lake.png` is active |
| Legacy | `kitty/` | previous terminal, kept for parity |

## Install on a new Mac

```sh
git clone git@github.com:tiagoboucas/kitty-lazyvim-dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` runs `brew bundle` (installs **Ghostty** + everything else),
downloads the official **Alacritty DMG** for the fallback (Homebrew disabled the
cask on 2026-09-01 — Gatekeeper), symlinks every config including
`ghostty/config` → `~/.config/ghostty/config`, merges `theme: dark-ansi` into
`~/.claude/settings.json` with `jq` (nothing else in that file is touched, and
the full file is **not** committed — this repo is public), pins
`org.alacritty AppleFontSmoothing = 2` for the Alacritty fallback (Ghostty does
the same via `font-thicken` in its config), and sets the wallpaper.

Existing real files are moved to `*.bak.<timestamp>` before being symlinked.

## Font / size / weight

Guaranteed identical on any machine by things that are all version-controlled:

1. `Brewfile` → `cask "font-fira-code-nerd-font"`
2. `ghostty/config` → `font-family = FiraCode Nerd Font Mono`, `font-size = 11`,
   `font-thicken = true` (perceived weight); `alacritty/alacritty.toml` mirrors
   `family` / `size = 11`
3. `install.sh` → `defaults write org.alacritty AppleFontSmoothing -int 2` (the
   Alacritty equivalent of `font-thicken` — 0 thinnest … 3 heaviest)

## Colours

`ghostty/config` and `alacritty/themes/tokyo-night.toml` both carry the Omarchy
"Tokyo Night" palette **1:1** with `basecamp/omarchy` →
`themes/tokyo-night/colors.toml` (fg `#a9b1d6`, bg `#1a1b26`, the 16 ANSI
colours). No overrides — the text matches a real Omarchy terminal, and Claude
Code inherits it via `dark-ansi`.

## Tabs

Ghostty has native tabs (`Cmd+T`) and splits (`Cmd+D` / `Cmd+Shift+D`) that
target the focused window. Alacritty has neither. `tmux` is still installed with
the Omarchy config (`tmux/tmux.conf`, prefix **Ctrl-Space**) — **not**
auto-started; run `tmux` yourself if you want it, e.g. `Prefix c` for a new
window, `Alt-1..9` to jump.

## Switching theme

Drop another Omarchy palette next to `alacritty/themes/tokyo-night.toml`
(same key layout), point `general.import` at it, and set the matching
`colorscheme` in `nvim/lua/plugins/tokyonight.lua`. Claude Code follows the
terminal automatically via `dark-ansi`.
