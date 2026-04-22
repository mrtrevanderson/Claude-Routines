#!/usr/bin/env bash
# Morning Briefing Runner
# Invoked by cron at 8:30 AM ET on weekdays.
# Requires: claude CLI in PATH, MCP servers configured in Claude Code settings.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/prompt.md"
LOG_DIR="$SCRIPT_DIR/logs"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/briefing_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

# Rotate logs: keep only the last 30 runs
find "$LOG_DIR" -name "briefing_*.log" | sort | head -n -30 | xargs -r rm --

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting morning briefing routine"

# Skip on US federal holidays
HOLIDAY_FILE="$SCRIPT_DIR/holidays.txt"
TODAY="$(date +%Y-%m-%d)"
if [[ -f "$HOLIDAY_FILE" ]] && grep -q "^${TODAY}" "$HOLIDAY_FILE"; then
  log "Today ($TODAY) is a US federal holiday — skipping briefing."
  exit 0
fi

# Run the Claude routine
# --print: non-interactive mode; outputs to stdout
# --mcp-config is inherited from the Claude Code environment
log "Invoking claude with morning briefing prompt"

claude \
  --print \
  --dangerously-skip-permissions \
  < "$PROMPT_FILE" \
  >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
  log "Morning briefing completed successfully"
else
  log "Morning briefing exited with code $EXIT_CODE — check log: $LOG_FILE"
fi

exit $EXIT_CODE
