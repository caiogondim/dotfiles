---
name: lint
description: |
  Fix all lint issues on the current branch. Removes all errors repo-wide and all
  warnings in files touched by this branch. Use when the user says "fix lint",
  "lint errors", "clean up lint", or "/lint".
allowed-tools: Bash, Read, Grep, Glob, Edit, Write
---

# Fix Lint

Fix all lint issues scoped by branch impact:
- **Errors** — fix everywhere, regardless of which files were changed
- **Warnings** — fix only in files touched by this branch

Loops until 3 consecutive clean runs confirm stability.

## Step 0: Check permissions mode

Run:
```bash
echo "bypass-check-ok"
```

If Claude Code prompts for permission, stop and tell the user:

> This skill requires bypass permissions mode. Please restart Claude Code with `--dangerously-skip-permissions` before using `/lint`.

## Step 1: Gather context

### 1a. Verify project

Confirm `package.json` exists. If not, stop:

> No package.json found. Navigate to a Node.js project root first.

### 1b. Detect PR-touched files

```bash
BASE_BRANCH=$(gh pr view --json baseRefName --jq '.baseRefName' 2>/dev/null || echo "main")
git diff --name-only "$(git merge-base HEAD "$BASE_BRANCH")...HEAD"
```

Store this list — it scopes which warnings to fix.

## Step 2: The fix loop

Track:
- `consecutive_clean` — starts at 0, target is 3
- `stuck_retries` — per-problem counter, max 10

```
while consecutive_clean < 3:
    run auto-fix
    run lint check
    fix remaining issues
    if clean: consecutive_clean += 1
    else: consecutive_clean = 0
    if stuck for 10 retries: report and stop
```

### Phase: Fix lint

**Run auto-fix first (wait for completion):**
```bash
yarn lint --fix 2>&1
```

**Then check remaining issues — run as a background task:**
```bash
# Use the Bash tool with run_in_background: true
yarn lint 2>&1
# Read output from task file when complete
```

**If clean, done for this iteration.**

**Parse output and categorize each issue:**
- **Error** in any file → fix it (repo-wide, no exceptions)
- **Warning** in a PR-touched file → fix it
- **Warning** in a non-PR file → skip, add to skipped report

**For each fixable issue:**
1. Read the file at the reported line
2. Understand the lint rule (use rule name from output)
3. Fix the code — do NOT suppress with eslint-disable unless the rule is genuinely inapplicable

**Re-run lint after each batch of fixes. Repeat until clean or stuck.**

## Step 3: Completion

### If 3 consecutive clean runs achieved

```
## Lint Fix Complete

All lint checks pass (3 consecutive clean runs).

Review changes with `git diff`.
```

### If stuck (10 retries exhausted)

```
## Lint Fix — Stuck

### Errors remaining
- [file:line — rule — description]

### Warnings remaining (PR-touched files)
- [file:line — rule — description]

### Skipped (warnings in non-PR files)
- [file:line — rule — description]

Review partial fixes with `git diff`.
```

## Rules

| Rule | Detail |
|------|--------|
| Errors | Fix repo-wide, always |
| Warnings | Fix only in PR-touched files |
| No suppression | Don't add `eslint-disable` unless rule is genuinely inapplicable |
| Always use yarn | `yarn lint`, `yarn lint --fix` — never npm or eslint directly |
| No git operations | Never commit, push, or reset. Only edit files. |
| Read before edit | Always read a file before modifying it |
| Clean run target | 3 consecutive fully-clean runs before declaring success |
| Max retries | 10 per stuck problem, then report and stop |
