#!/bin/bash
# Install claude-remote-watchdog
# Creates symlinks in ~/.claude/ for the command and script.
#
# Usage: ./install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude/commands ~/.claude/scripts

# Symlink command
ln -sfn "$REPO_DIR/remote-watchdog.md" ~/.claude/commands/remote-watchdog.md
echo "Linked: ~/.claude/commands/remote-watchdog.md → $REPO_DIR/remote-watchdog.md"

# Symlink script
ln -sfn "$REPO_DIR/remote-watchdog.sh" ~/.claude/scripts/remote-watchdog.sh
echo "Linked: ~/.claude/scripts/remote-watchdog.sh → $REPO_DIR/remote-watchdog.sh"

# Ensure executable
chmod +x "$REPO_DIR/remote-watchdog.sh"

cat <<'EOF'

✓ Installed! Usage:

  One-time check:     /remote-watchdog
  Auto-monitor:       /loop 5m /remote-watchdog
  Standalone cron:    */5 * * * * ~/.claude/scripts/remote-watchdog.sh >> /tmp/remote-watchdog.log 2>&1
  Dry run:            ~/.claude/scripts/remote-watchdog.sh --dry-run

EOF
