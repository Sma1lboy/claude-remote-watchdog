# claude-remote-watchdog

Auto-detect and fix dead [Claude Code](https://docs.anthropic.com/en/docs/claude-code) Remote Control (`/remote-control`) sessions in tmux.

## The Problem

Claude Code's `/remote-control` silently drops connections after 15-60 minutes. The built-in reconnection never recovers — the status bar shows "Remote Control reconnecting" indefinitely. The only fix is to manually cycle `/remote-control` at the terminal, which defeats the purpose of remote control.

See: [anthropics/claude-code#34255](https://github.com/anthropics/claude-code/issues/34255)

## How It Works

1. Scans all tmux panes for Claude Code's status bar
2. Detects `Remote Control reconnecting` (stuck/dead state)
3. Uses a 2-check grace period to avoid false positives on transient drops
4. Sends tmux keystrokes to automatically cycle disconnect → reconnect:
   - `Ctrl+C` → clear prompt
   - `/remote-control` → navigate to "Disconnect this session" → Enter
   - `/remote-control` → auto-connects to fresh bridge session

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- tmux (sessions must run inside tmux panes)

## Install

```bash
git clone https://github.com/sma1lboy/claude-remote-watchdog.git
cd claude-remote-watchdog
./install.sh
```

This creates symlinks in `~/.claude/`:
- `~/.claude/commands/remote-watchdog.md` — slash command
- `~/.claude/scripts/remote-watchdog.sh` — watchdog script

## Usage

### Inside Claude Code (recommended)

```
# One-time health check
/remote-watchdog

# Auto-monitor every 5 minutes
/loop 5m /remote-watchdog
```

### Standalone (no Claude session needed)

```bash
# Manual run
~/.claude/scripts/remote-watchdog.sh

# Dry run (detect only, no reconnect)
~/.claude/scripts/remote-watchdog.sh --dry-run

# Crontab (fully autonomous)
*/5 * * * * ~/.claude/scripts/remote-watchdog.sh >> /tmp/remote-watchdog.log 2>&1
```

## Output

```
=== Remote Control Watchdog 10:48:42 ===
[HEALTHY] Deck (%4)
[WARN] agent-universe (%5): 'reconnecting' — confirming next check
[DEAD] workspace-i (%6): stuck on 'reconnecting' — auto-reconnecting
[ACTION] Cycling /remote-control on pane %6 (workspace-i)...
[OK] Reconnect sequence sent to pane %6 (workspace-i)
```

| Status | Meaning |
|--------|---------|
| `[HEALTHY]` | Remote Control active |
| `[PENDING]` | Currently connecting |
| `[WARN]` | First detection of reconnecting — grace period |
| `[DEAD]` | Confirmed dead — auto-reconnect triggered |
| `[SKIP]` | No Remote Control sessions found in tmux |

## How the Reconnect Works

The `/remote-control` TUI menu has three options:

```
  Disconnect this session
  Show QR code
❯ Continue                  ← cursor starts here
```

The script navigates `Up Up Enter` to select "Disconnect", then runs `/remote-control` again which auto-connects to a fresh bridge — no TUI interaction needed on the second call.

## Limitations

- **tmux required**: Detection relies on reading tmux pane content via `tmux capture-pane`
- **TUI timing**: The script uses 5-second waits between keystrokes; slow machines may need `STEP_WAIT` increased
- **Grace period**: Takes 2 consecutive checks (~10 min with default `/loop 5m`) before triggering reconnect to avoid false positives

## License

MIT
