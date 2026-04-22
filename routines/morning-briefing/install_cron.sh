#!/usr/bin/env bash
# install_cron.sh — registers the morning briefing cron job.
# Safe to re-run (idempotent): replaces any existing entry with the current config.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run.sh"
CRON_TAG="# claude-morning-briefing"

chmod +x "$RUNNER"
mkdir -p "$SCRIPT_DIR/logs"

# 8:30 AM Eastern Time, Monday–Friday.
# TZ= prefix is supported by vixie-cron and cronie (most Linux distributions).
# For macOS, use the launchd plist documented in README.md instead.
CRON_LINE="TZ=America/New_York 30 8 * * 1-5 $RUNNER $CRON_TAG"

if crontab -l 2>/dev/null | grep -qF "$CRON_TAG"; then
  echo "Updating existing cron entry..."
  (crontab -l 2>/dev/null | grep -vF "$CRON_TAG"; echo "$CRON_LINE") | crontab -
else
  echo "Installing cron entry..."
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
fi

echo ""
echo "✓ Cron job installed:"
crontab -l | grep "$CRON_TAG"
echo ""
echo "Runs every weekday at 8:30 AM Eastern Time."
echo "Logs: $SCRIPT_DIR/logs/"
echo ""
echo "To remove:"
echo "  crontab -l | grep -vF '$CRON_TAG' | crontab -"
