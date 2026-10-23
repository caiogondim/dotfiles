---
name: notes
description: |
  Capture, query, and maintain notes about projects and tasks.
  Notes live in ~/Notes/ following a PARA-like structure.
  Use when user says "notes", "/notes log", "/notes query", "/notes save", "/notes ingest", "/notes inbox", etc.
allowed-tools: Bash, Read, Write, Edit
---

# Notes

Capture and query knowledge about projects and tasks.

## Setup

Notes live in `~/Notes/`. The folder structure:

```
~/Notes/
├── areas/
├── areas-archive/
├── inbox/
├── projects/
│   └── <project>/
│       ├── meta.md
│       ├── log.md
│       ├── knowledge.md
│       ├── todo.md
│       ├── index.md
│       └── raw/
├── projects-archive/
└── someday/
```

## Conventions

**Atomic writes:** Always write to a temp file first, then rename. This prevents
corruption if the write is interrupted.
```bash
cat > /tmp/notes-tmp-$$ << 'EOF'
<content>
EOF
mv /tmp/notes-tmp-$$ <target-file>
```

**Log order:** Newest entries always on top. Prepend new entries after the header,
don't append at the end.

## Context Detection

Find which notes folder the user is working on:

1. Check if cwd is inside `~/Notes/` — use that folder
2. If not, ask user which project/task

Cache the result for the session.

## Commands

### /notes init

Initialize notes for a code project.

**Steps:**
1. Get the current git root: `git rev-parse --show-toplevel`
2. Ask user: "Which area/project/task should this map to?"
3. List options from `ls ~/Notes/projects/` and `ls ~/Notes/areas/`
4. Create `meta.md` in the selected folder:
   ```markdown
   ---
   codeProject: <git root path>
   ---
   ```
5. Confirm done

### /notes log [message]

Update the log for current project/task.

**Steps:**
1. Detect notes folder (context detection)
2. Read `log.md` (always read before write)
3. Get timestamp: `date '+%Y-%m-%d %H:%M'`

**If 0 args:**
4. Get last log entry timestamp from `log.md`
5. Run `git log --since="<last timestamp>" --oneline` in the code project
6. LLM summarizes what happened since last entry
7. Show summary to user, ask for confirmation
8. Prepend to `log.md` (newest on top)

**If message provided:**
4. Check if similar entry already exists (dedup)
5. Prepend to `log.md` (newest on top):
   ```markdown
   ## YYYY-MM-DD HH:MM

   <message>
   ```

**Rules:**
- Keep entries concise — one line when possible
- No duplicates
- Always read before write

### /notes save <fact>

Save a finding to knowledge.md.

**Steps:**
1. Detect notes folder
2. Read `knowledge.md`
3. LLM classifies the fact into one of: Decisions, Patterns, Gotchas, Blockers, Dependencies, People
4. **Ask user for authorization**: "I'd add this to **Decisions**: '<fact>'. OK?"
5. If approved, check for duplicates
6. Append to the confirmed section in `knowledge.md` with date:
   ```markdown
   - <fact> [2026-04-08]
   ```
7. Confirm saved

### /notes todo [action] [task]

List or manage todos.

**Actions:**
- No args: list all todos
- `<task>`: add new todo
- `done <task>`: mark todo as completed
- `undone <task>`: mark todo as not completed
- `delete <task>`: remove todo

**Steps:**
1. Detect notes folder
2. Read `todo.md` (create if missing)

**If 0 args:**
3. Display all todos with status

**If adding:**
3. Append `- [ ] <task>` to `todo.md`
4. Confirm added
5. Log: `Todo added: <task>`

**If completing:**
3. Find `- [ ] <task>` and change to `- [x] <task>`
4. Confirm completed
5. Log: `Todo completed: <task>`

**If uncompleting:**
3. Find `- [x] <task>` and change to `- [ ] <task>`
4. Confirm uncompleted
5. Log: `Todo uncompleted: <task>`

**If deleting:**
3. Remove the todo line from `todo.md`
4. Confirm deleted
5. Log: `Todo deleted: <task>`

**Logging format (all actions):**
Prepend to `log.md` (newest on top):
```markdown
## YYYY-MM-DD HH:MM

Todo <action>: <task>
```

### /notes query "<question>"

Query knowledge about current project/task.

**Hierarchical search:** Query searches up the folder hierarchy from most
focused to broadest. Each parent level has broader context but shallower detail.

Example for `~/Notes/projects/skill-notes/`:
1. `~/Notes/projects/skill-notes/` — most focused (project-specific)
2. `~/Notes/projects/` — project-level patterns
3. `~/Notes/` — broadest (cross-project knowledge)

**Steps:**
1. Detect notes folder
2. **Search hierarchy:** Starting from the notes folder, walk up to `~/Notes/`:
   - At each level, read `knowledge.md` if it exists
   - At each level, read relevant files from `raw/` if it exists
   - Stop early if a sufficient answer is found at a focused level
3. Synthesize answer from all sources, citing where info came from
   (e.g. "from skill-notes/knowledge.md: Patterns" or "from projects/raw/api-doc.md")
4. Return answer to user
5. **Ask user:** "Want me to save this finding to knowledge.md?"
6. If yes:
   - Classify into one of: Decisions, Patterns, Gotchas, Blockers, Dependencies, People
   - Ask user: "I'd add this to **<section>**: '<finding>'. OK?"
   - If approved, append to `knowledge.md` with date: `- <finding> [YYYY-MM-DD]`

### /notes ingest [source]

Ingest a source into the knowledge base.

**Source types:**
| Input | Action |
|-------|--------|
| File path | Copy to `raw/` preserving original filename |
| URL | Fetch, extract clean text, save as `.md` in `raw/` |
| No argument | Prompt user to paste text, save as `.txt` in `raw/` |

**Steps:**
1. Detect notes folder (context detection)
2. Save source to `raw/`:
   - **File path:** `cp <path> <notes>/raw/`
   - **URL:** Use browser/fetch to get page content, extract readable text, save as `<basename>.md` in `raw/`
   - **No arg:** Prompt user to paste content, save as `ingest-YYYY-MM-DD-HHMM.txt` in `raw/`
3. **Read the source:**
   - Text/markdown: use Read tool
   - Images: use Read tool (vision)
   - PDFs: use available tools to extract text, or ask user to paste key sections
4. **Discuss takeaways:**
   - Present key takeaways from the source
   - Ask user: "What should we focus on? What's important here? Anything to add or skip?"
5. **Update knowledge.md:**
   - Read `knowledge.md`
   - Propose which sections to update (Decisions, Patterns, Gotchas, Blockers, Dependencies, People)
   - For each proposed update, ask user: "I'd add this to **<section>**: '<fact>'. OK?"
   - Apply confirmed updates
6. **Update index.md:**
   - Read `index.md` (create if missing with map structure)
   - Index is a **map**, not a list — each entry is a context block:
     ```markdown
     ## <Topic>
     **Where:** knowledge.md → Decisions
     **What:** <one-line summary of what's there>
     **When:** 2026-04-08
     ```
   - If new entities/topics emerged, propose index updates
   - Apply confirmed updates
7. **Log it:**
   - Propose entry: `Ingested: <filename> — <one-line summary>`
   - Get timestamp: `date '+%Y-%m-%d %H:%M'`
   - Ask user for confirmation
   - Prepend to `log.md` (newest on top):
     ```markdown
     ## YYYY-MM-DD HH:MM

     Ingested: <filename> — <summary>
     ```

**Rules:**
- Always interactive — discuss before writing
- One source at a time by default
- Always read files before writing
- Keep log entries concise
- No duplicates in knowledge.md

### /notes status

Show current state of project/task.

**Steps:**
1. Detect notes folder
2. Read `log.md` — show last 3 entries
3. Read `knowledge.md` — extract Blockers and Gotchas separately
4. Read `todo.md` — count done vs pending
5. **PR status** (if code project exists):
   - Run `gh pr list --state open --head <branch>` to find current PR
   - Run `gh pr list --state open --search "depends on #<pr>"` for dependent PRs
   - If no `gh` available, skip this section
6. Present summary:
   ```
   ## Status: <project/task>

   ### Recent Activity
   - <last 3 log entries>

   ### Blockers
   - <blockers from knowledge.md>

   ### Warnings
   - <gotchas from knowledge.md>

   ### Todos
   - X done, Y pending

   ### Key People
   - <people from knowledge.md>

   ### Pull Requests
   - Current: #123 — title (open/draft/merged)
   - Depends on:
     - #120 — title (status)
     - #118 — title (status)
   ```
7. **Log it:**
   - Get timestamp: `date '+%Y-%m-%d %H:%M'`
   - Prepend to `log.md` (newest on top):
     ```markdown
     ## YYYY-MM-DD HH:MM

     Status checked — <one-line summary>
     ```

### /notes handoff

Generate handoff summary for next session or person.

**Steps:**
1. Detect notes folder
2. Read all files: `log.md`, `knowledge.md`, `todo.md`, `meta.md`
3. Generate handoff doc:
   ```markdown
   ## Handoff: <project/task>

   ### Current Status
   <summary from log.md>

   ### Key Decisions
   <from knowledge.md Decisions>

   ### Blockers
   <from knowledge.md Gotchas>

   ### Open Todos
   <from todo.md, not done>

   ### Key People
   <from knowledge.md People>

   ### What To Do Next
   <LLM suggests based on context>
   ```
4. Ask user: "Save to handoff.md or just display?"
5. If save, write to `handoff.md` in notes folder

### /notes inbox <text>

Quick capture to inbox. Saves a string as a markdown file in `~/Notes/inbox/`.

**Steps:**
1. Read the input text
2. Suggest a short, descriptive filename (e.g. `idea-auth-refactor.md`, `note-meeting-april.md`)
3. **Ask user:** "Save as `~/Notes/inbox/<filename>.md`?"
4. If user accepts, save the file
5. If user suggests different name, use that instead
6. Confirm saved

**Rules:**
- Filename should be short and descriptive
- Always `.md` extension
- Content is the raw input text
- No project context needed — inbox is global

### /notes progress [time_window]

Show recent log entries across all active areas and projects.

**Time window formats:** `1d`, `3d`, `1w`, `2w`, `1m` (default: `1d`)

**Steps:**
1. Parse time window from args (default: `1d`)
   - `d` = days, `w` = weeks, `m` = months (30 days)
2. Calculate cutoff date: `date -v-<N>d '+%Y-%m-%d'`
3. Find all active areas and projects:
   ```bash
   ls -d ~/Notes/areas/*/ ~/Notes/projects/*/
   ```
   Skip any that are archived (in `areas-archive/` or `projects-archive/`)
4. For each folder, read `log.md` if it exists
5. Parse entries — each starts with `## YYYY-MM-DD HH:MM`
6. Filter entries where date ≥ cutoff
7. Display results grouped by area/project:
   ```
   ## Progress Report (last <window>)

   ### projects/skill-notes
   - 2026-04-08 00:06 — Ingested: llm-wiki.pdf
   - 2026-04-07 23:55 — Added /notes ingest command

   ### areas/professional
   - 2026-04-08 10:30 — Met with team re: Q2 planning

   ### No activity
   - projects/ivf
   - areas/personal
   ```
8. If no args provided and user hasn't specified, ask:
   "What time window? (default: last 1 day)"
   Accept formats above or freeform like "last 3 days", "past week"

**Rules:**
- Show newest entries first within each group
- Groups with no activity listed under "No activity" section
- Keep output scannable — one line per entry (date + summary)
- Don't modify any files — read-only command

### /notes lint

Check consistency across notes files.

**Steps:**
1. Detect notes folder
2. Check folder structure: has meta.md, log.md, knowledge.md, todo.md, raw/
3. Check `knowledge.md` sections exist: Decisions, Patterns, Gotchas, Blockers, Dependencies, People
4. Check for orphaned references in knowledge.md (pointing to non-existent files)
5. Check for stale raw/ files not referenced anywhere
6. Present report:
   ```
   ## Lint Report

   ### Structure
   - [x] meta.md exists
   - [ ] log.md exists
   - ...

   ### Issues
   - knowledge.md references missing file: raw/screenshot.png
   - ...

   ### Warnings
   - todo.md has 15 unchecked items (consider archiving completed)
   ```
7. **Do not modify files** — report only, ask user before fixing
