#!/bin/bash
# macOS notification for Claude Code, WezTerm only.
# Usage: claude-notify.sh "Title" "Message"
# Clicking the banner brings WezTerm forward on the pane that fired it.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

[ -n "$WEZTERM_PANE" ] || exit 0

TITLE="${1:-New Message}"
MESSAGE="${2:-New message received}"

DISPLAY_MSG=$(echo "$MESSAGE" | cut -c1-100)
[ ${#MESSAGE} -gt 100 ] && DISPLAY_MSG="${DISPLAY_MSG}..."

# -execute wins over -activate, so it both raises the app and focuses the pane.
terminal-notifier \
  -title "$TITLE" \
  -message "$DISPLAY_MSG" \
  -sound "Glass" \
  -execute "open -b com.github.wez.wezterm; /opt/homebrew/bin/wezterm cli activate-pane --pane-id $WEZTERM_PANE"
