# Morning Briefing Routine — Trevor Anderson, Data Engineering @ Fluent
# Generated for: {{DATE}}

You are executing Trevor Anderson's daily morning briefing routine. Your job is to:
1. Pull data from Jira, Confluence, Slack, and Microsoft 365 Calendar **in parallel where possible**
2. Synthesize the results into a concise briefing
3. Send the briefing as a Slack DM to Trevor Anderson

Follow all steps below exactly. Do not skip any step. If a data source fails or returns no results, note it inline and continue.

---

## TEAM MEMBERS

Trevor's team (for Jira queries):
- Trevor Anderson
- Kapil Sreedharan
- Ahkil Gonna
- Joseph Melkin
- Vani Kaithi
- Venkatesh Mannam
- Manav Paul

Key stakeholders (for Confluence):
- Jean Carlo Camacho
- Dave Van Herten
- Rami Labana
- Andrew Chalk
- Jack Hall
- Arbi Anjargholi

Known knowledge gap areas to flag (🔴):
- TUNE attribution
- Syndication source systems
- EDM identity matching
- partner-advertiser blocking

---

## STEP 1: FETCH DATA IN PARALLEL

Execute the following four data pulls. Where tool calls do not depend on each other, run them simultaneously.

### 1A — JIRA

Use `mcp__Atlassian__searchJiraIssuesUsingJql` with the following queries. Run both queries:

**Query 1 — Open issues assigned to team (blockers, impediments, due today/overdue):**
```
JQL: assignee in (currentUser(), "Kapil Sreedharan", "Ahkil Gonna", "Joseph Melkin", "Vani Kaithi", "Venkatesh Mannam", "Manav Paul")
     AND statusCategory != Done
     ORDER BY priority DESC, updated DESC
```
Request fields: summary, status, priority, assignee, duedate, labels, issuetype, issuelinks

**Query 2 — Issues with status change in last 24 hours:**
```
JQL: assignee in (currentUser(), "Kapil Sreedharan", "Ahkil Gonna", "Joseph Melkin", "Vani Kaithi", "Venkatesh Mannam", "Manav Paul")
     AND updated >= -1d
     AND statusCategory != Done
     ORDER BY updated DESC
```
Request fields: summary, status, assignee, updated, changelog

From Jira results, identify and categorize:
- **BLOCKERS**: tickets with status "Impediment", priority "Blocker", or with "blocks" issuelinks
- **DUE TODAY**: duedate == {{DATE_ISO}} 
- **OVERDUE**: duedate < {{DATE_ISO}} AND statusCategory != Done
- **RECENTLY MOVED**: status changed in last 24 hours (from Query 2)

### 1B — CONFLUENCE

Use `mcp__Atlassian__searchConfluenceUsingCql` with:

```
CQL: space.key in ("DE", "DATA") AND lastModified >= now("-1d") ORDER BY lastModified DESC
```

If you cannot determine the Data Engineering space key, use `mcp__Atlassian__getConfluenceSpaces` first to find spaces named "Data Engineering" or owned/frequented by the team, then query those space keys.

Also run a broader stakeholder search:
```
CQL: contributor in ("jean.carlo.camacho", "dave.van.herten", "rami.labana", "andrew.chalk", "jack.hall", "arbi.anjargholi") AND lastModified >= now("-1d") ORDER BY lastModified DESC
```

For each result, note:
- Page title, space, last modifier, whether it is new (created in last 24h) or updated
- Flag with 🔴 if the page title or content excerpt contains any of: "TUNE attribution", "Syndication", "EDM", "identity matching", "partner-advertiser", "blocking"

### 1C — SLACK

Run the following in parallel:

**Direct mentions and DMs:**
Use `mcp__Slack__slack_search_public_and_private` with query: `@Trevor` to find recent direct mentions.
Use `mcp__Slack__slack_search_public_and_private` with query: `to:Trevor` or similar to surface DMs.

**Key channel activity:**
Use `mcp__Slack__slack_search_channels` to locate these channels if needed, then use `mcp__Slack__slack_read_channel` for each:
- #data-engineering (or similar team channel)
- #de-leads
- #analytics
- #data-platform
- Any other high-signal channels you can identify

For each channel, only surface:
- Messages from Dan Duling or senior stakeholders
- Threads with 5 or more replies
- Direct @Trevor mentions
- DMs to Trevor that are unread

Do NOT summarize every message — only flag high-signal items from the last 18 hours.

**Find Trevor's Slack user ID** using `mcp__Slack__slack_search_users` with query "Trevor Anderson" so you can send the DM in Step 3.

### 1D — MICROSOFT 365 CALENDAR

Use `mcp__Microsoft-365__outlook_calendar_search` to fetch today's meetings for {{DATE_ISO}}.

For each meeting, collect:
- Title, start time, end time
- Attendees list
- Whether there is an agenda attached or a meeting description/body

Identify:
- Meetings with no agenda or empty body
- Back-to-back blocks (meetings with < 15 min gap between them)
- Focus time blocks

---

## STEP 2: SYNTHESIZE THE BRIEFING

Using all data collected above, compose the briefing below. Use Slack mrkdwn formatting.
Bullets use `•` character. Bold uses `*text*`. Section headers use `*HEADER*`.
Keep every bullet to one line. Total briefing should be readable in under 2 minutes.

Use this exact structure:

```
☀️ *Good morning, Trevor. Here's your briefing for {{DATE}}.*

📅 *TODAY'S CALENDAR*
• [HH:MM AM/PM] — [Meeting Title] | [Key attendees, max 3 names] | Agenda: [yes/no]
• [repeat for each meeting]
[If any meeting has no agenda attached, add:] ⚠️ [Meeting Title] has no agenda doc.
[If calendar data unavailable:] ⚠️ Calendar could not be reached.

🎯 *JIRA — ACTION NEEDED*
• [[TICKET-ID]] [Title] — [reason: Blocker / Due today / Overdue / Status moved to X]
[If nothing urgent:] No blockers or due-today tickets. ✓
[If Jira unavailable:] ⚠️ Jira could not be reached.

📄 *CONFLUENCE — RECENT UPDATES*
• [Page Title] — updated by [Name] ([Space name]) [🔴 if gap-area match]
• [NEW] [Page Title] — created by [Name] ([Space name]) [🔴 if gap-area match]
[If nothing:] No Confluence updates in the last 24 hours.
[If Confluence unavailable:] ⚠️ Confluence could not be reached.

💬 *SLACK — HEADS UP*
• [#channel or DM] — [1-line summary of what needs attention]
[If nothing:] No unread mentions or high-signal threads.
[If Slack read failed:] ⚠️ Slack data could not be retrieved.

🧠 *ONE THING TO KEEP IN MIND TODAY*
[Single sentence — the most important thing Trevor should not let slip through the cracks today, synthesized from all of the above.]
```

---

## STEP 3: SEND AS SLACK DM

1. Use `mcp__Slack__slack_search_users` to confirm Trevor Anderson's Slack user ID (if not already retrieved in Step 1C).
2. Use `mcp__Slack__slack_send_message` to send the briefing as a **direct message** to Trevor Anderson's user ID.
   - Do NOT post to any channel.
   - Set the channel parameter to Trevor's user ID (starts with `U`).
3. If the Slack DM send fails on first attempt, retry once.
4. If it still fails after one retry, print the briefing to stdout so it is captured in the log.

---

## EXECUTION NOTES

- Keep total execution time under 60 seconds.
- Do not retry any data source more than once.
- If a source returns empty results (no issues, no pages, no messages), that is valid — report "nothing to flag" for that section.
- Today's date for filtering: {{DATE_ISO}} (ISO format) / {{DATE}} (display format)
- Current time context: 8:30 AM Eastern Time
