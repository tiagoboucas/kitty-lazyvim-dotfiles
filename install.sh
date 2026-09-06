#!/usr/bin/env bash
# Replicate this Omarchy-flavoured macOS terminal setup on a fresh machine.
#   - Ghostty — primary terminal (Omarchy Tokyo Night palette, FiraCode Nerd
#     Font Mono @ 11, native tabs/splits, transparent titlebar)
#   - Alacritty — same palette/font, kept as a fallback
#   - tmux providing the "tabs" (Omarchy config)
#   - starship prompt (Omarchy config)
#   - Neovim / LazyVim with tokyonight-night
#   - Claude Code theme = dark-ansi (inherits the terminal palette)
#   - Omarchy Tokyo Night desktop wallpaper
set -euo pipefail
DOTS="$(cd "$(dirname "$0")" && pwd)"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

backup_and_link() {
  # backup_and_link <src> <dest>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    say "backed up existing $dest"
  fi
  ln -sfn "$src" "$dest"
}

# ---------------------------------------------------------------------------
say "Installing packages from Brewfile"
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2; exit 1
fi
brew bundle --file="$DOTS/Brewfile"

# ---------------------------------------------------------------------------
# Alacritty — Homebrew disabled the cask on 2026-09-01 (Gatekeeper). Grab the
# official DMG. It is ad-hoc signed; a curl download carries no quarantine bit
# so it launches without a prompt. If macOS still refuses it:
#   xattr -dr com.apple.quarantine /Applications/Alacritty.app
ALACRITTY_VERSION="0.17.0"
if [ ! -d "/Applications/Alacritty.app" ]; then
  say "Installing Alacritty $ALACRITTY_VERSION from the official DMG"
  tmpd="$(mktemp -d)"
  curl -fsSL -o "$tmpd/Alacritty.dmg" \
    "https://github.com/alacritty/alacritty/releases/download/v${ALACRITTY_VERSION}/Alacritty-v${ALACRITTY_VERSION}.dmg"
  hdiutil attach "$tmpd/Alacritty.dmg" -nobrowse -quiet -mountpoint "$tmpd/mnt"
  cp -R "$tmpd/mnt/Alacritty.app" /Applications/
  hdiutil detach "$tmpd/mnt" -quiet
  rm -rf "$tmpd"
fi

# ---------------------------------------------------------------------------
say "Linking Ghostty (primary terminal)"
backup_and_link "$DOTS/ghostty/config" "$HOME/.config/ghostty/config"

say "Linking Alacritty (fallback)"
backup_and_link "$DOTS/alacritty/alacritty.toml"          "$HOME/.config/alacritty/alacritty.toml"
backup_and_link "$DOTS/alacritty/themes/tokyo-night.toml" "$HOME/.config/alacritty/themes/tokyo-night.toml"

say "Linking tmux"
backup_and_link "$DOTS/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

say "Linking starship + zsh"
backup_and_link "$DOTS/starship/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$DOTS/zshrc"                  "$HOME/.zshrc"

say "Linking Neovim (LazyVim)"
for f in init.lua lazy-lock.json lazyvim.json stylua.toml lua; do
  backup_and_link "$DOTS/nvim/$f" "$HOME/.config/nvim/$f"
done

say "Linking kitty (legacy, kept for parity)"
for f in kitty.conf current-theme.conf griffin-theme.conf tab_bar.py; do
  [ -e "$DOTS/kitty/$f" ] && backup_and_link "$DOTS/kitty/$f" "$HOME/.config/kitty/$f"
done

# ---------------------------------------------------------------------------
say "Merging Claude Code theme (dark-ansi) into ~/.claude/settings.json"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
if [ -f "$CLAUDE_SETTINGS" ] && command -v jq >/dev/null 2>&1; then
  cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
  tmp="$(mktemp)"
  jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" "$DOTS/claude/settings.partial.json" > "$tmp"
  mv "$tmp" "$CLAUDE_SETTINGS"
else
  cp "$DOTS/claude/settings.partial.json" "$CLAUDE_SETTINGS"
fi

# ---------------------------------------------------------------------------
say "Pinning Alacritty font smoothing (controls perceived font weight)"
# 0 = off/thinnest … 3 = heaviest. 2 matches the reference machine.
defaults write org.alacritty AppleFontSmoothing -int 2 || true

# ---------------------------------------------------------------------------
say "Setting desktop wallpaper (Omarchy Tokyo Night)"
WALL="$DOTS/wallpapers/tokyo-night-sunset-lake.png"
if [ -f "$WALL" ]; then
  osascript -e "tell application \"System Events\" to set picture of every desktop to \"$WALL\"" || true
  killall Dock 2>/dev/null || true
fi

say "Done. Restart the terminal (or: exec zsh) and open Ghostty."
