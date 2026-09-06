#!/bin/bash
# macOS notification helper - shows tab details and message content
# Usage: claude-notify.sh "Title" "Message"
#
# Three back-ends, picked by which terminal is running:
#   - Ghostty  : OSC 777 desktop notification + bell, written to the surface
#                pty. Ghostty raises the real macOS notification itself (it has
#                its own notification authorisation) and clicking it focuses the
#                surface that fired it. No terminal-notifier needed.
#   - kitty    : ring the kitty bell (bell_on_tab shows the 🔔) + terminal-
#                notifier, with a click action that focuses the exact window
#                via `kitten @ focus-window`.
#   - anything : terminal-notifier only (Alacritty has no notification path).
# If the primary path can't reach the tty (hook run without a controlling
# terminal) it falls through to terminal-notifier.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

TITLE="${1:-New Message}"
MESSAGE="${2}"

# Truncate message to 100 chars for the notification.
if [ -n "$MESSAGE" ]; then
  DISPLAY_MSG=$(echo "$MESSAGE" | cut -c1-100)
  if [ ${#MESSAGE} -gt 100 ]; then
    DISPLAY_MSG="${DISPLAY_MSG}..."
  fi
else
  DISPLAY_MSG="New message received"
fi

# ---------------------------------------------------------------------------
# Ghostty
# ---------------------------------------------------------------------------
is_ghostty() {
  [ "$TERM_PROGRAM" = "ghostty" ] || [ -n "$GHOSTTY_RESOURCES_DIR" ] \
    || [ -n "$GHOSTTY_BIN_DIR" ]
}

if is_ghostty; then
  # OSC 777 is ;-delimited and ST-terminated — strip anything that would
  # break the frame.
  g_title=$(printf '%s' "$TITLE"       | tr -d ';\a\033\r\n')
  g_body=$(printf '%s'  "$DISPLAY_MSG" | tr -d ';\a\033\r\n')
  # notify (OSC 777) + bell (\a → Glass + tab attention, see ghostty/config).
  if { printf '\033]777;notify;%s;%s\033\\\a' "$g_title" "$g_body" > /dev/tty; } 2>/dev/null; then
    exit 0
  fi
  # tty not writable — fall through to terminal-notifier below.
fi

# ---------------------------------------------------------------------------
# kitty
# ---------------------------------------------------------------------------
if [ -n "$KITTY_WINDOW_ID" ] && command -v kitten &>/dev/null; then
  TAB_INFO=$(kitten @ ls 2>/dev/null </dev/null \
    | jq -r '.[].tabs[] | select(.is_active) | .title' 2>/dev/null \
    | head -1)
  if [ -n "$TAB_INFO" ]; then
    TITLE="$TAB_INFO — $TITLE"
  fi
fi

# Ring the kitty bell in the tab this session lives in, so the tab shows the
# 🔔 (bell_on_tab) and the window/dock alert (window_alert_on_bell) fires.
# 1st try: our controlling terminal IS that tab's pty (hooks run inside it).
# Fallback: resolve the tab's tty via kitty remote control + ps.
ring_bell() {
  if { printf '\a' > /dev/tty; } 2>/dev/null; then
    return
  fi
  if [ -n "$KITTY_WINDOW_ID" ] && command -v kitten &>/dev/null; then
    local pid tty sock
    local -a to=()
    # kitten @ uses $KITTY_LISTEN_ON automatically; for sessions started
    # before listen_on was configured, fall back to the newest socket.
    if [ -z "$KITTY_LISTEN_ON" ]; then
      sock=$(ls -t /tmp/mykitty-* 2>/dev/null | head -1)
      [ -n "$sock" ] && to=(--to "unix:$sock")
    fi
    pid=$(kitten @ "${to[@]}" ls 2>/dev/null </dev/null \
      | jq -r --argjson id "$KITTY_WINDOW_ID" \
          '.[].tabs[].windows[] | select(.id == $id) | .pid' 2>/dev/null | head -1)
    if [ -n "$pid" ]; then
      tty=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
      if [ -n "$tty" ] && [ "$tty" != "??" ]; then
        printf '\a' > "/dev/$tty" 2>/dev/null
      fi
    fi
  fi
}
[ -n "$KITTY_WINDOW_ID" ] && ring_bell

# ---------------------------------------------------------------------------
# terminal-notifier (kitty click-to-focus, or the generic fallback)
# ---------------------------------------------------------------------------
# Click action: bring kitty to the front AND focus the exact window this
# session lives in (-execute wins over -activate, so it does both itself).
# NOTE: do NOT use -sender net.kovidgoyal.kitty — it hangs forever because
# kitty has no macOS notification authorization of its own.
ACTION=()
if [ -n "$KITTY_WINDOW_ID" ]; then
  ACTION=(-activate "net.kovidgoyal.kitty")
  SOCK="${KITTY_LISTEN_ON:-unix:$(ls -t /tmp/mykitty-* 2>/dev/null | head -1)}"
  if [ "$SOCK" != "unix:" ]; then
    ACTION=(-execute "open -b net.kovidgoyal.kitty; /opt/homebrew/bin/kitten @ --to '$SOCK' focus-window --match id:$KITTY_WINDOW_ID")
  fi
elif is_ghostty; then
  ACTION=(-activate "com.mitchellh.ghostty")
fi

terminal-notifier \
  -title "$TITLE" \
  -message "$DISPLAY_MSG" \
  -sound "Glass" \
  "${ACTION[@]}"
