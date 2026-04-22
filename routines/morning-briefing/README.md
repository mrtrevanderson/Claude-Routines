# Morning Briefing Routine

Delivers a daily Slack DM to Trevor Anderson at 8:30 AM ET every weekday
with a synthesized briefing from Jira, Confluence, Slack, and Microsoft 365 Calendar.

## Files

| File | Purpose |
|------|---------|
| `prompt.md` | The routine prompt Claude executes — contains all data-pull and synthesis instructions |
| `run.sh` | Shell wrapper invoked by cron; handles logging, holiday skipping, and CLI invocation |
| `holidays.txt` | US federal holiday dates (update annually) |
| `logs/` | Auto-created; stores one log file per run, retained for 30 runs |

## Prerequisites

1. **`claude` CLI** installed and in `PATH` (`which claude` should resolve).
2. **MCP servers active** in your Claude Code environment:
   - Atlassian MCP (Jira + Confluence)
   - Slack MCP
   - Microsoft 365 MCP
3. **`--dangerously-skip-permissions`** accepted: the runner passes this flag so
   the routine executes non-interactively. Only use on a machine you control.

## Running Manually

```bash
# Test a one-off run
bash routines/morning-briefing/run.sh

# Or pipe the prompt directly
claude --print --dangerously-skip-permissions < routines/morning-briefing/prompt.md
```

## Cron Setup

The target schedule is **8:30 AM Eastern Time, Monday–Friday**.

Eastern Time shifts seasonally:
- **EST (Nov–Mar):** UTC-5 → cron hour = `13`
- **EDT (Mar–Nov):** UTC-4 → cron hour = `12`

The cleanest approach is to set the cron job's `TZ` variable so the system
handles DST automatically:

```bash
# Open crontab
crontab -e
```

Add this line (adjust the path to match your clone location):

```cron
TZ=America/New_York
30 8 * * 1-5 /path/to/Claude-Routines/routines/morning-briefing/run.sh
```

> **Note:** `TZ=` inside crontab works on Linux with Vixie cron and systemd-cron.
> On macOS, use a launchd plist instead (see below).

### Alternative: systemd timer (Linux)

Create `/etc/systemd/system/morning-briefing.service`:
```ini
[Unit]
Description=Claude Morning Briefing

[Service]
Type=oneshot
Environment=TZ=America/New_York
ExecStart=/path/to/Claude-Routines/routines/morning-briefing/run.sh
User=your-username
```

Create `/etc/systemd/system/morning-briefing.timer`:
```ini
[Unit]
Description=Run morning briefing at 8:30 AM ET weekdays

[Timer]
OnCalendar=Mon-Fri 08:30:00 America/New_York
Persistent=true

[Install]
WantedBy=timers.target
```

Enable:
```bash
systemctl daemon-reload
systemctl enable --now morning-briefing.timer
systemctl list-timers morning-briefing.timer
```

### Alternative: launchd plist (macOS)

Create `~/Library/LaunchAgents/com.trevor.morning-briefing.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.trevor.morning-briefing</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/path/to/Claude-Routines/routines/morning-briefing/run.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
    <!-- Monday = 2, Friday = 6 in launchd -->
    <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
    <dict><key>Weekday</key><integer>6</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>30</integer></dict>
  </array>
  <key>StandardOutPath</key>
  <string>/path/to/Claude-Routines/routines/morning-briefing/logs/launchd.log</string>
  <key>StandardErrorPath</key>
  <string>/path/to/Claude-Routines/routines/morning-briefing/logs/launchd-error.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>TZ</key>
    <string>America/New_York</string>
  </dict>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.trevor.morning-briefing.plist
```

## Updating the Holiday List

Edit `holidays.txt` annually. Each line must be:
```
YYYY-MM-DD  Holiday Name
```
Lines starting with `#` are comments and are ignored by the runner.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| "Slack DM failed" in log | Verify Slack MCP connection; check Trevor's Slack user ID was resolved correctly |
| Jira section missing | Check Atlassian MCP auth token hasn't expired |
| Script exits immediately | Ensure `claude` is in PATH for the cron user (`which claude`) |
| Holiday skip not working | Confirm `holidays.txt` date format is exactly `YYYY-MM-DD` |
