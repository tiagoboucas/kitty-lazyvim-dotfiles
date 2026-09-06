# Claude Code colours

`settings.partial.json` sets only:

```json
{ "theme": "dark-ansi" }
```

`dark-ansi` makes Claude Code paint itself from the **terminal's 16 ANSI
colours** instead of a built-in palette. Because Alacritty loads the Omarchy
Tokyo Night palette (`../alacritty/themes/tokyo-night.toml`), Claude Code ends
up matching Omarchy automatically — swap the Alacritty theme and Claude follows.

`install.sh` merges this key into `~/.claude/settings.json` with `jq` and keeps
every other key (permissions, hooks, MCP config, machine-specific `autoMode`
data) untouched. The full `~/.claude/settings.json` is **not** committed — this
repo is public and that file carries private infrastructure details.
