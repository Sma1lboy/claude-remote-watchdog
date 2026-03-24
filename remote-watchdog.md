Run the remote control watchdog script to check connection health and auto-reconnect dead sessions.

Execute the `remote-watchdog.sh` script located in the same directory as this command file (resolve via symlink if needed):

```bash
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]:-$0}" 2>/dev/null || echo "$0")")" && pwd)"
# Fallback: check common locations
for dir in "$SCRIPT_DIR" ~/.claude/scripts "$(dirname "$(readlink ~/.claude/commands/remote-watchdog.md 2>/dev/null)")" ; do
  [[ -x "$dir/remote-watchdog.sh" ]] && WATCHDOG="$dir/remote-watchdog.sh" && break
done
```

Run: `${WATCHDOG:-~/.claude/scripts/remote-watchdog.sh}`

If the script reports `[DEAD]` and attempts auto-reconnect, wait 10 seconds then re-run the script to verify the reconnect succeeded. Report the final status.

If the script is not executable or missing, run `chmod +x` on it first.

Keep output concise — this runs on a loop.
