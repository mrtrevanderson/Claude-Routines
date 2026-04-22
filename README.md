# Claude-Routines

Automated routines that run via the Claude Code CLI using connected MCP servers.

## Routines

### morning_briefing

Daily weekday briefing delivered as a Slack DM at 8:30 AM ET. Pulls from Jira, Confluence, Slack, and Microsoft 365 Calendar, synthesizes key signals, and sends a formatted summary.

**Prerequisites**
- Claude Code CLI (`claude`) installed and in `$PATH`
- MCP servers configured in Claude Code settings:
  - Atlassian MCP (Jira + Confluence)
  - Slack MCP
  - Microsoft 365 MCP

**Setup**
```bash
cd morning_briefing
chmod +x run.sh install_cron.sh
./install_cron.sh
```

**Manual run (for testing)**
```bash
./morning_briefing/run.sh
```

**Files**
- `prompt.md` — Full briefing prompt with date placeholders (`{{DATE}}`, `{{DATE_ISO}}`)
- `run.sh` — Substitutes dates, calls `claude --print`, logs output
- `install_cron.sh` — Installs the `TZ=America/New_York 30 8 * * 1-5` cron entry
- `logs/` — Runtime logs, gitignored
