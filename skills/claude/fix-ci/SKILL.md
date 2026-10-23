---
name: fix-ci
description: |
  Autonomously fix all CI failures on the current branch: failing unit tests,
  type errors, and lint issues. Loops until 3 consecutive clean runs or 10 retries
  on a stuck problem. Use when CI is red, tests are failing, lint is broken,
  or the user says "fix ci", "fix tests", "fix lint", "fix types", or "/fix-ci".
allowed-tools: Bash, Read, Grep, Glob, Edit, Write, Agent
---

# Fix CI

Autonomously fix all CI failures on the current branch. Runs tests, type-check, and lint
in a loop until 3 consecutive fully-clean runs confirm stability.

## Step 0: Check permissions mode

Run:
```bash
echo "bypass-check-ok"
```

If Claude Code prompts for permission, stop and tell the user:

> This skill requires bypass permissions mode. Please restart Claude Code with `--dangerously-skip-permissions` before using `/fix-ci`.

## Step 1: Gather context

Collect everything needed before entering the fix loop.

### 1a. Verify project

Confirm `package.json` exists in the current working directory. If not, stop:

> No package.json found. Navigate to a Node.js project root first.

### 1b. Detect PR-touched files

```bash
BASE_BRANCH=$(gh pr view --json baseRefName --jq '.baseRefName' 2>/dev/null)
```

If no PR exists, fall back:
```bash
BASE_BRANCH="main"
```

Get touched files:
```bash
git diff --name-only "$(git merge-base HEAD "$BASE_BRANCH")...HEAD"
```

Store this list — it scopes type and lint-warning fixes.

### 1c. Detect available scripts

Check `package.json` for:
- `"test"` script — command will be `TZ=UTC yarn test --watchAll=false`
- `"type-check"` script — if present use `yarn type-check`, else use `hi-type-check --folder .`
- `"lint"` script — command will be `yarn lint`

## Step 2: The fix loop

Track these counters:
- `consecutive_clean` — starts at 0, target is 3
- `stuck_retries` — per-problem counter, max 10
- `last_failure_signature` — fingerprint of the last failure (file + error message)

```
while consecutive_clean < 3:
    run Phase A (tests)
    run Phase B (types)
    run Phase C (lint)

    if all three phases passed clean:
        consecutive_clean += 1
    else:
        consecutive_clean = 0

    if stuck on same problem for 10 retries:
        report and stop
```

### Phase A: Fix tests

**Scope: repo-wide. Fix source code, not test assertions.**

1. Run tests:
   ```bash
   TZ=UTC yarn test --watchAll=false 2>&1
   ```

2. If all tests pass, move to Phase B.

3. If tests fail, parse the output to identify:
   - Which test files failed
   - The assertion errors and expected vs received values
   - The source files being tested

4. Read the failing test files to understand what behavior is expected.

5. Read the source files being tested. Fix the source code so the tests pass.

6. **Constraint**: Do NOT weaken test assertions. Do NOT delete tests. Do NOT change
   expected values in tests to match broken behavior. Fix the source code instead.
   The only exception is if a test itself has a clear bug (e.g., wrong import path,
   typo in test setup) — in that case, fixing the test is acceptable.

7. Re-run tests. If the same test still fails after a fix attempt, increment
   `stuck_retries` for that test. If a different test now fails, reset the counter.

8. Repeat until tests pass or stuck for 10 retries.

### Phase B: Fix types

**Scope: only files touched by the PR.**

1. Run type-check:
   ```bash
   yarn type-check 2>&1
   # or if no type-check script:
   hi-type-check --folder . 2>&1
   ```

2. If clean, move to Phase C.

3. Filter errors to only those in PR-touched files.

4. For each error in a PR-touched file:
   - Read the file and understand the type error
   - Fix the type definition, annotation, or usage
   - **Never use `any` or `@type {any}` casts** — fix the root cause instead (explicit destructuring, proper JSDoc types, correct signatures)

5. If fixing a type error requires editing a file NOT touched by the PR, skip it
   and report it at the end.

6. Re-run type-check. Repeat until PR-touched file errors are resolved or stuck for 10 retries.

### Phase C: Fix lint

**Scope: errors are repo-wide, warnings are PR-touched files only.**

1. First, run auto-fix:
   ```bash
   yarn lint --fix 2>&1
   ```

2. Then run lint again to see remaining issues:
   ```bash
   yarn lint 2>&1
   ```

3. If clean, this phase is done.

4. Parse output. Categorize each issue:
   - **Error** in any file → fix it (repo-wide)
   - **Warning** in a PR-touched file → fix it
   - **Warning** in a non-PR file → skip, report at end

5. For each fixable issue, read the file, understand the lint rule, and apply
   the fix manually.

6. Re-run lint. Repeat until resolved or stuck for 10 retries.

## Step 3: Completion

### If 3 consecutive clean runs achieved

Print:

```
## CI Fix Complete

All checks pass (3 consecutive clean runs).

- Tests: PASS
- Types: PASS
- Lint: PASS

Review changes with `git diff`.
```

### If stuck on a problem (10 retries exhausted)

Print:

```
## CI Fix — Stuck

Fixed what I could, but these problems remain after 10 retries:

### Tests
- [list any still-failing tests with file paths and error messages]

### Types
- [list any unfixed type errors with file paths and error codes]

### Lint
- [list any unfixed lint issues with file paths and rule names]

### Skipped (out of scope)
- [list any issues in non-PR files that were skipped]

Review partial fixes with `git diff`.
```

## Rules

| Rule | Detail |
|------|--------|
| Never weaken tests | Fix source code, not assertions. Exception: clear test bugs (wrong imports, typos). |
| Never use `any` | Fix type errors at the root — explicit types, proper JSDoc, correct signatures. Never use `any` or `@type {any}` casts. |
| Type/lint-warning scope | Only edit files already touched by the PR for type fixes and lint warnings. |
| Lint error scope | Fix lint errors repo-wide. |
| Max retries | 10 per stuck problem, then report and stop. |
| Clean run target | 3 consecutive fully-clean runs before declaring success. |
| Always use yarn | `yarn test`, `yarn lint`, `yarn type-check`. Never npm or npx. |
| No git operations | Never commit, push, or reset. Only edit files. |
| Read before edit | Always read a file before modifying it. Understand context first. |

## Final Step: Self-Improvement

After completing the skill, invoke `/self-improve` for `fix-ci`.
