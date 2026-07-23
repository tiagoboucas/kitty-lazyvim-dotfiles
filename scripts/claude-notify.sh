#!/bin/bash
# macOS notification helper - shows tab details and message content
# Usage: claude-notify.sh "Title" "Message"

TITLE="${1:-New Message}"
MESSAGE="${2}"

# Best-effort: prefix the active kitty tab title to the notification title.
# Only try inside kitty, with stdin detached so `kitten @` can never hang
# waiting on the tty (e.g. when called from a Claude Code hook).
if [ -n "$KITTY_WINDOW_ID" ] && command -v kitten &>/dev/null; then
  TAB_INFO=$(kitten @ ls 2>/dev/null </dev/null \
    | /opt/homebrew/bin/jq -r '.[].tabs[] | select(.is_active) | .title' 2>/dev/null \
    | head -1)
  if [ -n "$TAB_INFO" ]; then
    TITLE="$TAB_INFO — $TITLE"
  fi
fi

# Truncate message to 100 chars for notification
if [ -n "$MESSAGE" ]; then
  DISPLAY_MSG=$(echo "$MESSAGE" | cut -c1-100)
  if [ ${#MESSAGE} -gt 100 ]; then
    DISPLAY_MSG="${DISPLAY_MSG}..."
  fi
else
  DISPLAY_MSG="New message received"
fi

# -activate focuses kitty when the notification is clicked.
# NOTE: do NOT use -sender net.kovidgoyal.kitty — it hangs forever because
# kitty has no macOS notification authorization of its own.
/opt/homebrew/bin/terminal-notifier \
  -title "$TITLE" \
  -message "$DISPLAY_MSG" \
  -sound "Glass" \
  -activate "net.kovidgoyal.kitty"
