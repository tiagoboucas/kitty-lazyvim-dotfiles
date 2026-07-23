#!/bin/bash
# Claude Code hook → macOS notification.
# Claude Code pipes JSON on stdin (hook_event_name, message, cwd, ...).
# Wired up in ~/.claude/settings.json (Notification and Stop events).

INPUT=$(cat)
JQ=/opt/homebrew/bin/jq

EVENT=$(printf '%s' "$INPUT" | "$JQ" -r '.hook_event_name // empty' 2>/dev/null)
MESSAGE=$(printf '%s' "$INPUT" | "$JQ" -r '.message // empty' 2>/dev/null)
CWD=$(printf '%s' "$INPUT" | "$JQ" -r '.cwd // empty' 2>/dev/null)

PROJECT=$(basename "${CWD:-Claude}")

case "$EVENT" in
  Stop)
    TITLE="Claude — $PROJECT"
    MESSAGE="${MESSAGE:-Done — your turn ✅}"
    ;;
  Notification)
    TITLE="Claude needs you — $PROJECT"
    MESSAGE="${MESSAGE:-Waiting for your input}"
    ;;
  *)
    TITLE="Claude — $PROJECT"
    MESSAGE="${MESSAGE:-New message}"
    ;;
esac

exec ~/dotfiles/scripts/claude-notify.sh "$TITLE" "$MESSAGE"
