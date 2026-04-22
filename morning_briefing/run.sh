#!/usr/bin/env bash
# Morning Briefing Routine — run.sh
# Invoked by cron at 8:30 AM ET on weekdays.
# Requires: claude CLI in PATH, MCP servers configured in Claude Code settings.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_TEMPLATE="$SCRIPT_DIR/prompt.md"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/briefing_$(date +%Y%m%d_%H%M%S).log"

# -- Date strings --
DATE_DISPLAY="$(date '+%A, %B %-d, %Y')"          # e.g. Tuesday, April 22, 2025
DATE_ISO="$(date '+%Y-%m-%d')"                     # e.g. 2025-04-22

# -- US Federal Holiday check --
# Exits 0 (skip) on federal holidays. Add dates for the current year as needed.
FEDERAL_HOLIDAYS=(
  "2026-01-01"   # New Year's Day
  "2026-01-19"   # MLK Day
  "2026-02-16"   # Presidents' Day
  "2026-05-25"   # Memorial Day
  "2026-06-19"   # Juneteenth
  "2026-07-03"   # Independence Day (observed)
  "2026-07-04"   # Independence Day
  "2026-09-07"   # Labor Day
  "2026-10-12"   # Columbus Day
  "2026-11-11"   # Veterans Day
  "2026-11-26"   # Thanksgiving
  "2026-12-25"   # Christmas
)

for holiday in "${FEDERAL_HOLIDAYS[@]}"; do
  if [[ "$DATE_ISO" == "$holiday" ]]; then
    echo "[$(date)] Skipping briefing — federal holiday ($DATE_ISO)" | tee -a "$LOG_FILE"
    exit 0
  fi
done

# -- Build prompt by substituting date placeholders --
PROMPT="$(sed \
  -e "s/{{DATE}}/$DATE_DISPLAY/g" \
  -e "s/{{DATE_ISO}}/$DATE_ISO/g" \
  "$PROMPT_TEMPLATE")"

# -- Create log directory --
mkdir -p "$LOG_DIR"

echo "[$(date)] Starting morning briefing for $DATE_DISPLAY" | tee -a "$LOG_FILE"

# -- Execute via Claude Code CLI --
# --print        : non-interactive, output to stdout
# --no-interactive: suppress any interactive prompts
# Pipe output to log while still printing to stdout (tee)
if command -v claude &>/dev/null; then
  claude \
    --print \
    --no-interactive \
    --allowedTools "mcp__Atlassian__*,mcp__Slack__*,mcp__Microsoft-365__*" \
    "$PROMPT" \
    2>&1 | tee -a "$LOG_FILE"
  EXIT_CODE="${PIPESTATUS[0]}"
else
  echo "[$(date)] ERROR: 'claude' CLI not found in PATH. Add Claude Code to PATH and retry." | tee -a "$LOG_FILE"
  EXIT_CODE=1
fi

echo "[$(date)] Briefing complete (exit $EXIT_CODE). Log: $LOG_FILE"
exit "$EXIT_CODE"
