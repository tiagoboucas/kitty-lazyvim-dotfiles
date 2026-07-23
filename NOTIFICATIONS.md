# Notifications

Your terminal now has 3 layers of notifications:

## 1. **Desktop Notifications (macOS)**

Script installed: `~/dotfiles/scripts/claude-notify.sh`

### Manual usage:
```bash
msg                                          # Quick notification
notify "Custom Title" "Message content"      # Custom title + message
```

### Smart features:
- 📝 **Auto-detects active tab** - shows tab title in notification
- ✂️ **Message preview** - truncates to 100 chars for readability
- 🎯 **Click to focus** - clicking notification brings kitty to front

### Examples:
```bash
msg
notify "Alert" "This is a very long message that will be automatically truncated to fit in the notification nicely"
```

The notification will show the tab name as title and first 100 chars of message! 🎯

---

## 2. **Bell & Audio Alerts (Kitty)**

Automatically configured in `~/.config/kitty/kitty.conf`:

- 🔔 **Tab alert**: Shows bell when activity detected
- 📳 **Visual bell**: Screen flashes
- 🔊 **Audio bell**: "Glass" system sound
- ⏱️ **Auto-notify**: Automatic notification after 2s of inactivity

---

## 3. **Terminal Integration (Starship Prompt)**

Real-time git status in prompt when switching directories

---

## Setup Complete

Everything is installed! Reload your shell:

```bash
source ~/.zshrc
```

Test it:
```bash
msg
```

You should see a macOS notification with sound! 🎵
