# Claude-Routines

Automated routines that run via the Claude Code CLI using connected MCP servers.

## Routines

### morning-briefing

Daily weekday briefing delivered as a Slack DM to Trevor Anderson at 8:30 AM ET.
Pulls from Jira, Confluence, Slack, and Microsoft 365 Calendar, synthesizes key
signals, and sends a formatted summary.

**Canonical location:** `routines/morning-briefing/`

**Prerequisites**
- Claude Code CLI (`claude`) installed and in `$PATH`
- MCP servers configured in Claude Code settings:
  - Atlassian MCP (Jira + Confluence)
  - Slack MCP
  - Microsoft 365 MCP

**Setup**
```bash
cd routines/morning-briefing
chmod +x run.sh install_cron.sh
./install_cron.sh
```

**Manual run (for testing)**
```bash
bash routines/morning-briefing/run.sh
```

**Files**

| File | Purpose |
|------|---------|
| `prompt.md` | Briefing prompt — data-pull, synthesis, and delivery instructions |
| `run.sh` | Shell wrapper for cron — date injection, holiday skip, logging, CLI invocation |
| `install_cron.sh` | One-time cron registration, idempotent |
| `holidays.txt` | US federal holiday dates — update annually |
| `logs/` | Per-run logs, gitignored, retained for 30 runs |

See [`routines/morning-briefing/README.md`](routines/morning-briefing/README.md)
for full setup documentation including systemd timer and launchd plist alternatives.
