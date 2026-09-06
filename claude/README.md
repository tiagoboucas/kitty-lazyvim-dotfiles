# Claude Code colours

`settings.partial.json` sets only:

```json
{ "theme": "dark-ansi" }
```

`dark-ansi` makes Claude Code paint itself from the **terminal's 16 ANSI
colours** instead of a built-in palette. Both terminals load the Omarchy Tokyo
Night palette — `../ghostty/config` (primary) and
`../alacritty/themes/tokyo-night.toml` (fallback), both 1:1 with
`basecamp/omarchy` → `themes/tokyo-night/colors.toml` — so Claude Code looks
exactly like a real Omarchy terminal. Swap the terminal theme and Claude
follows.

`install.sh` merges this key into `~/.claude/settings.json` with `jq` and keeps
every other key (permissions, hooks, MCP config, machine-specific `autoMode`
data) untouched. The full `~/.claude/settings.json` is **not** committed — this
repo is public and that file carries private infrastructure details.
