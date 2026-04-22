#!/usr/bin/env bash
# install_cron.sh — installs the morning briefing cron job for Trevor Anderson.
# Run once to register; safe to re-run (idempotent).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run.sh"
CRON_TAG="# claude-morning-briefing"

# Ensure run.sh is executable
chmod +x "$RUNNER"

# Cron expression: 8:30 AM Eastern (UTC-5 in ET standard, UTC-4 in EDT).
# Most cron daemons run in UTC. We use TZ= prefix (supported by vixie-cron,
# cronie, and most Linux distributions). Adjust if your system uses a
# different cron implementation.
CRON_LINE="TZ=America/New_York 30 8 * * 1-5 $RUNNER >> $SCRIPT_DIR/logs/cron.log 2>&1 $CRON_TAG"

# Check if already installed
if crontab -l 2>/dev/null | grep -qF "$CRON_TAG"; then
  echo "Cron job already installed. Replacing with current configuration..."
  # Remove old entry and reinstall
  (crontab -l 2>/dev/null | grep -vF "$CRON_TAG"; echo "$CRON_LINE") | crontab -
else
  # Append to existing crontab
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
fi

echo ""
echo "✓ Cron job installed:"
crontab -l | grep "$CRON_TAG"
echo ""
echo "The morning briefing will run every weekday at 8:30 AM Eastern Time."
echo "Logs will be written to: $SCRIPT_DIR/logs/"
echo ""
echo "To remove the cron job, run:"
echo "  crontab -l | grep -vF '$CRON_TAG' | crontab -"
