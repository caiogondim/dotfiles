---
name: qa
description: |
  Run a QA test session against a web UI. Gathers context from git, notes, and memory,
  creates a test plan, gets user approval, then executes tests autonomously using agent-browser.
  Use when the user says "qa", "test the app", "run qa", or "/qa".
allowed-tools: Bash, Read, Edit, Grep, Glob, Bash(agent-browser:*), Bash(npx agent-browser:*)
---

# QA

Automated QA testing for web UIs using agent-browser.

## Step 1: Gather Context

### 1a. Git context
```bash
git log --oneline -20
git diff --stat main..HEAD 2>/dev/null || git diff --stat -10
git branch --show-current
```

### 1b. Notes
Check if notes exist for this project:
```bash
ls ~/Notes/projects/*/meta.md 2>/dev/null
```
If found, run `/notes query` for relevant context (blockers, gotchas, decisions).

### 1c. CLAUDE.md
Check if `CLAUDE.md` exists in the project root:
```bash
test -f CLAUDE.md && cat CLAUDE.md
```

### 1d. Memory
Check for available memory-related skills:
- Search installed skills for names containing "memory", "remember", "recall", "context"
- If found, ask user: "Found a memory skill. Want me to use it to retrieve additional context?"
- If user confirms, invoke that skill
- If no memory skill found, skip silently

## Step 2: Detect URL

Try to infer the base URL in this order:
1. Check `agent-browser.json` for config
2. Check `CLAUDE.md` for dev server URL or port
3. Check `package.json` scripts for dev server (e.g. `next dev -p 3000`, `vite --port 5173`)
4. Check `.env` / `.env.local` for `BASE_URL`, `APP_URL`, `NEXT_PUBLIC_URL`, `VITE_*`
5. If found, use it. If not, ask user: "What's the URL to test?"

## Step 3: Create QA Plan

Based on context gathered, generate a test plan:

```
## QA Plan

Target: <url>
Branch: <branch>
Recent changes: <summary of what changed>

### Test Steps

1. [Navigate to /path]
   - Verify: [expected outcome]
   - Verify: [expected outcome]

2. [Click element / Fill form]
   - Verify: [expected outcome]

...
```

Present the plan to the user:
- "Here's the QA plan. Want to adjust anything before I start?"

Iterate on feedback until user approves.

## Step 4: Execute Tests

For each test step, execute using agent-browser:

```
▶ Step N: <action description>
```

Then run the agent-browser commands:
```bash
agent-browser open <url>
agent-browser wait --load networkidle
agent-browser snapshot -i
# ... interact based on refs ...
```

After each step, report result:
```
  ✓ <verification that passed>
  ✗ <verification that failed> — <reason>
```

Re-snapshot after every navigation or DOM change. Use refs from snapshots.

If a step fails:
- Note the failure
- Continue to next step (don't abort)

## Step 5: Report

After all steps complete:

```
## QA Report

Branch: <branch>
Target: <url>
Date: <date>

### Summary
Passed: X/Y
Failed: Z/Y

### Results
✓ Step 1: Navigate to /dashboard
  ✓ User name displays in header
  ✓ Stats cards render with data

✗ Step 2: Click "Create New"
  ✗ Modal didn't open — timeout waiting for element

...

### Failed Steps Detail
**Step 2: Click "Create New"**
- Expected: modal opens with form
- Actual: nothing happened after click
- Element: @e5 button "Create New"

### Recommendations
- <suggestions based on failures>
```

## Self-Improvement

After completing, invoke `/self-improve` for `qa`.
