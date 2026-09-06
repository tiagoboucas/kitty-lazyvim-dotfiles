# Notifications

When Claude Code finishes a turn or needs input, you get a macOS notification
with sound and the tab lights up. Wired through Claude Code hooks →
`scripts/claude-code-notify.sh` → `scripts/claude-notify.sh`.

## Hooks (`~/.claude/settings.json`)

```jsonc
"Stop":         "~/dotfiles/scripts/claude-code-notify.sh"   // Claude finished, your turn
"Notification": "~/dotfiles/scripts/claude-code-notify.sh"   // Claude is waiting on you
```

`claude-code-notify.sh` reads the hook JSON on stdin, turns the event +
`cwd` into a title (`Claude — <project>` / `Claude needs you — <project>`)
and message, then calls `claude-notify.sh`.

## Back-ends (`scripts/claude-notify.sh`)

The helper picks a path from the terminal it's running in:

### Ghostty (primary)

Emits an **OSC 777** desktop notification + a bell to the surface's pty:

```
\033]777;notify;<title>;<body>\033\\   +   \a
```

- Ghostty raises the real macOS notification itself — it has its own
  notification authorisation, and **clicking the banner focuses the exact
  surface** that fired it. No `terminal-notifier` involved.
- The `\a` bell (see `ghostty/config` → `bell-features = audio,attention,title`)
  plays `Glass.aiff`, flashes the title, and marks the tab/window as needing
  attention.
- First run: macOS asks once to allow Ghostty notifications — say yes.

### kitty (legacy)

Rings the kitty bell (`bell_on_tab` shows the 🔔) and fires
`terminal-notifier` with a click action that runs
`kitten @ focus-window --match id:$KITTY_WINDOW_ID`.

### Anything else (Alacritty, …)

`terminal-notifier` only, `-sound Glass`, click activates the app.
Alacritty has no notification protocol of its own.

If the primary path can't reach `/dev/tty` (hook run without a controlling
terminal) it falls through to `terminal-notifier`.

## Manual usage

```bash
notify "Custom Title" "Message content"   # alias → claude-notify.sh
msg                                       # quick ping
```

(`notify` / `msg` aliases live in `zshrc`.)

## Test

```bash
~/dotfiles/scripts/claude-notify.sh "Test" "hello from the terminal"
```

In Ghostty you should get a banner + Glass + the tab marked for attention;
clicking the banner jumps back to that surface.
