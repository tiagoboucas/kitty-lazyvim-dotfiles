#!/bin/sh
# Cria os symlinks de ~/.config para este repo.
set -e
DOTS="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.config/kitty ~/.config/nvim

for f in kitty.conf current-theme.conf; do
  ln -sfn "$DOTS/kitty/$f" ~/.config/kitty/"$f"
done

for f in init.lua lazy-lock.json lazyvim.json lua stylua.toml; do
  ln -sfn "$DOTS/nvim/$f" ~/.config/nvim/"$f"
done

echo "ok — symlinks criados"
