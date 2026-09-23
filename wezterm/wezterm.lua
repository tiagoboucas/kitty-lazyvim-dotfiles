-- ~/.config/wezterm/wezterm.lua  (symlinked from ~/dotfiles/wezterm/)
--
-- WezTerm port of the Omarchy "Tokyo Night" Alacritty setup on macOS.
-- Mirrors ../alacritty/alacritty.toml + ../alacritty/themes/tokyo-night.toml:
-- same palette, FiraCode Nerd Font Mono @ 11, 14/6 padding, no blur, standard
-- opaque macOS title bar, Option handed back to macOS for dead-key accents.
-- Deliberate divergence: opacity is 0.94 here (Alacritty is 0.82) — the extra
-- solidity keeps Claude Code's diff highlighting readable over the wallpaper.
--
-- Reload after edits: automatic (WezTerm watches this file).

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ---------------------------------------------------------------------------
-- Colours — Omarchy "Tokyo Night", 1:1 with ../alacritty/themes/tokyo-night.toml
-- (itself 1:1 with basecamp/omarchy -> themes/tokyo-night/colors.toml).
-- ---------------------------------------------------------------------------
config.colors = {
  foreground = "#a9b1d6",
  background = "#1a1b26",

  cursor_bg = "#c0caf5",
  cursor_fg = "#1a1b26",
  cursor_border = "#c0caf5",

  selection_fg = "#c0caf5",
  selection_bg = "#7aa2f7",

  ansi = {
    "#32344a", -- black
    "#f7768e", -- red
    "#9ece6a", -- green
    "#e0af68", -- yellow
    "#7aa2f7", -- blue
    "#ad8ee6", -- magenta
    "#449dab", -- cyan
    "#787c99", -- white
  },
  brights = {
    "#444b6a", -- bright black
    "#ff7a93", -- bright red
    "#b9f27c", -- bright green
    "#ff9e64", -- bright yellow
    "#7da6ff", -- bright blue
    "#bb9af7", -- bright magenta
    "#0db9d7", -- bright cyan
    "#acb0d0", -- bright white
  },

  -- Fancy tab bar pills. Without this WezTerm uses its own default palette,
  -- which doesn't derive from the scheme above and reads visibly off-theme.
  tab_bar = {
    background = "#16161e", -- Tokyo Night bg_dark, one step below terminal bg
    active_tab = { bg_color = "#1a1b26", fg_color = "#c0caf5" },
    inactive_tab = { bg_color = "#16161e", fg_color = "#545c7e" },
    inactive_tab_hover = { bg_color = "#292e42", fg_color = "#a9b1d6" },
    new_tab = { bg_color = "#16161e", fg_color = "#545c7e" },
    new_tab_hover = { bg_color = "#292e42", fg_color = "#c0caf5" },
  },
}

-- ---------------------------------------------------------------------------
-- Font — FiraCode Nerd Font Mono @ 11. FiraCode ships no italic face, so the
-- Alacritty config maps italic -> Regular; do the same here via font_rules
-- instead of letting WezTerm synthesise a slant. Ligatures are OFF to match
-- Alacritty (which can't render them) — delete the harfbuzz_features line to
-- get WezTerm's default (ligatures ON).
--
-- Weight — Alacritty renders via CoreText and picks up
--   defaults write org.alacritty AppleFontSmoothing -int 2
-- which stem-darkens Regular into that "solid" Omarchy look. WezTerm rasterises
-- with FreeType, which does NOT read AppleFontSmoothing (that key is a no-op for
-- WezTerm), so Regular here came out visibly thinner. Matching it instead by
-- stepping the face up to Medium — the closest parity lever WezTerm actually
-- has. Bump to "Regular" if it reads too heavy on a non-Retina display.
-- ---------------------------------------------------------------------------
config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium" })
config.font_size = 11.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font_rules = {
  {
    italic = true,
    font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium", italic = false }),
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Bold", italic = false }),
  },
}
-- Full hinting + greyscale AA (what modern macOS does anyway). The old
-- "Light" / "HorizontalLcd" pair rendered thinner still and washed out over the
-- translucent background.
config.freetype_load_target = "Normal"
config.freetype_render_target = "Normal"

-- ---------------------------------------------------------------------------
-- Window — 14/6 padding, standard opaque macOS title bar (Alacritty
-- decorations = "Full"), 0.94 opacity (Alacritty is 0.82), blur off.
-- ---------------------------------------------------------------------------
config.window_padding = { left = 14, right = 14, top = 6, bottom = 6 }
config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 0.94
config.macos_window_background_blur = 0

-- Native tabs (WezTerm has them built in). Hide the bar with a single tab so a
-- lone window reads like plain Alacritty; show it once a second tab exists.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.window_frame = {
  font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Bold" }),
  font_size = 11.0,
  -- With window_decorations including TITLE, the fancy tab bar is drawn
  -- inside the native titlebar strip; unset it defaults to macOS's grey
  -- chrome, which is what actually looked off-theme (not the tab pills).
  active_titlebar_bg = "#16161e",
  inactive_titlebar_bg = "#16161e",
}

-- ---------------------------------------------------------------------------
-- Keyboard
--   Option handed back to macOS so dead-key accents work (Option+e e -> é);
--   Alacritty: option_as_alt = "None".
--   Shift+Return / Alt+Shift+Return as CSI-u so TUIs can tell them from a
--   plain Return. Shift+Insert paste, Ctrl+Insert copy. Cmd+N new window,
--   Cmd+T new tab (both are WezTerm defaults, kept explicit for parity with
--   the Alacritty [keyboard] block).
-- ---------------------------------------------------------------------------
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true
-- Lets apps that opt in see Cmd (SUPER) chords, e.g. Cmd+C forwarded below.
config.enable_kitty_keyboard = true

config.keys = {
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b[13;2u") },
  { key = "Enter", mods = "ALT|SHIFT", action = act.SendString("\x1b[13;4u") },
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "Insert", mods = "CTRL", action = act.CopyTo("Clipboard") },
  -- Mouse-capturing TUIs (Claude Code fullscreen) own the selection, so WezTerm's
  -- is empty: forward Cmd+C to the app instead of copying nothing.
  {
    key = "c",
    mods = "SUPER",
    action = wezterm.action_callback(function(window, pane)
      if window:get_selection_text_for_pane(pane) ~= "" then
        window:perform_action(act.CopyTo("Clipboard"), pane)
      else
        window:perform_action(act.SendKey({ key = "c", mods = "SUPER" }), pane)
      end
    end),
  },
  { key = "n", mods = "CMD", action = act.SpawnWindow },
  { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
  -- Reorder tabs, macOS convention (Cmd+Shift+[ / ])
  { key = "[", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "]", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
}

-- ---------------------------------------------------------------------------
-- Misc — match the Alacritty [env] / clipboard behaviour.
--   Alacritty sets TERM=xterm-256color and osc52 = "CopyPaste". WezTerm already
--   lets apps *write* the clipboard via OSC 52; read-back has no opt-in and
--   stays disabled.
-- ---------------------------------------------------------------------------
config.term = "xterm-256color"
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"

return config
