# Notifications

When Claude Code finishes a turn or needs input **in WezTerm**, you get a macOS
notification with the Glass sound. Other terminals get nothing.

Wired through Claude Code hooks → `scripts/claude-code-notify.sh` →
`scripts/claude-notify.sh`.

## Hooks (`~/.claude/settings.json`)

```jsonc
"Stop":         "~/dotfiles/scripts/claude-code-notify.sh"   // Claude finished, your turn
"Notification": "~/dotfiles/scripts/claude-code-notify.sh"   // Claude is waiting on you
```

`claude-code-notify.sh` reads the hook JSON on stdin, turns the event +
`cwd` into a title (`Claude — <project>` / `Claude needs you — <project>`)
and message, then calls `claude-notify.sh`.

## `scripts/claude-notify.sh`

- Exits silently unless `$WEZTERM_PANE` is set (i.e. not running in WezTerm).
- Sends the banner with `terminal-notifier -sound Glass`.
- Clicking it runs `wezterm cli activate-pane --pane-id $WEZTERM_PANE`, which
  brings WezTerm forward on the exact pane that fired it.

## Manual usage

```bash
notify "Custom Title" "Message content"   # alias → claude-notify.sh
msg                                       # quick ping
```

## Test (from a WezTerm pane)

```bash
~/dotfiles/scripts/claude-notify.sh "Test" "hello from WezTerm"
```
