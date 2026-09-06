# Claude Code colours

`settings.partial.json` sets only:

```json
{ "theme": "dark-ansi" }
```

`dark-ansi` makes Claude Code paint itself from the **terminal's 16 ANSI
colours** instead of a built-in palette. Both terminals load the Omarchy Tokyo
Night palette — `../ghostty/config` (primary) and
`../alacritty/themes/tokyo-night.toml` (fallback) — so Claude Code matches
Omarchy automatically; swap the terminal theme and Claude follows.

The signature blue Claude text is not stock Tokyo Night: both configs force
`foreground` / ANSI `white` (7) / `bright white` (15) to `#82aaff` / `#a3c0ff`.
Claude prints in colour 7/15 and the default fg, so it comes out blue instead of
Tokyo Night's grey. Delete those overrides for the stock grey.

`install.sh` merges this key into `~/.claude/settings.json` with `jq` and keeps
every other key (permissions, hooks, MCP config, machine-specific `autoMode`
data) untouched. The full `~/.claude/settings.json` is **not** committed — this
repo is public and that file carries private infrastructure details.
