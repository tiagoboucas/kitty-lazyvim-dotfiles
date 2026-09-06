# Ghostty — primary terminal

`config` is the Ghostty port of `../alacritty/alacritty.toml` +
`../alacritty/themes/tokyo-night.toml`. Same Omarchy Tokyo Night palette, same
FiraCode Nerd Font Mono @ 11, same blue-text override.

## Why Ghostty over Alacritty here

| | Alacritty | Ghostty |
|---|---|---|
| Native macOS tabs | buggy — `Cmd+T` attaches the tab to the *first* window, not the focused one | works; `Cmd+T` tabs the focused window, `Cmd+D` / `Cmd+Shift+D` split |
| Tinted title bar | `decorations = "Transparent"` tints it but the grid renders *under* it — needs a hand-tuned `padding.y`, breaks on macOS updates | `macos-titlebar-style = transparent` tints **and** insets the grid automatically |
| Ligatures | not rendered | on by default (FiraCode `=>`, `!=`, `->` …) |

Alacritty stays installed and configured as a fallback.

## Colour / blue text

`background = 1a1b26`, palette `0..15` ported 1:1 from the Alacritty theme, then
the same override the kitty/Alacritty configs carry:

```
foreground  = 82aaff   # default text
palette = 7  = 82aaff   # ANSI "white"
palette = 15 = a3c0ff   # ANSI bright white
```

That is what makes Claude Code (`theme: dark-ansi`, inherits the 16 ANSI
colours) and other apps print in blue instead of Tokyo Night's grey.

## Parity notes

- `font-thicken = true` replaces Alacritty's
  `defaults write org.alacritty AppleFontSmoothing -int 2` — no `defaults`
  needed, it lives in `config`.
- `term = xterm-256color` instead of Ghostty's own `xterm-ghostty`, so SSH into
  hosts without the ghostty terminfo entry still behaves.
- `font-style-italic = false` keeps italics upright (FiraCode ships no italic).
- Custom keybinds: Shift/Alt+Shift+Return as CSI-u, Shift/Ctrl+Insert
  paste/copy. Everything else is Ghostty's default map.

Reload after edits: `Cmd+Shift+,`.
