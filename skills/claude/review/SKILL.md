---
name: review
description: |
  Code review skill with two modes: give feedback on a PR or local changes,
  or analyze received feedback on a PR comment. Input determines mode:
  - PR URL (github.com/.../pull/123) → give feedback
  - PR comment URL (github.com/.../pull/123#discussion_r...) → analyze received feedback
  - Empty / no URL → review local changes (asks: changed files / changed files + PR / changed files + PR + base PR)
allowed-tools: Bash, Read, Grep, Glob, Agent, AskUserQuestion, Edit
---

# Feedback

Code review skill that gives or analyzes feedback.

## Step 1: Determine mode

Parse the input to determine the mode:

- **Give feedback**: Input is a PR URL (`github.com/.../pull/NNN`) or empty (local changes)
- **Analyze received feedback**: Input is a PR comment URL (contains `#discussion_r`, `#issuecomment-`, or `#pullrequestreview-`)

---

## Mode A: Give Feedback

### A1: Get the diff

**If input is a PR URL:**

Extract owner, repo, and PR number from the URL. Fetch the diff:

```bash
gh pr diff <PR_NUMBER> --repo <OWNER>/<REPO>
```

Also fetch PR metadata for context:

```bash
gh pr view <PR_NUMBER> --repo <OWNER>/<REPO> --json title,body,baseRefName,headRefName,files
```

**If input is empty (local changes):**

Ask the user what to review using `AskUserQuestion` with header "Scope" and question "What should I review?":

- **Changed files**: `git diff HEAD` (uncommitted changes only)
- **Changed files + PR**: `git diff HEAD` plus `git diff $(git merge-base HEAD main)...HEAD` (all commits on this branch)
- **Changed files + PR + base PR**: same as above, plus fetch and diff the target/base PR branch against its own merge base

Collect the appropriate diffs and file lists based on the user's choice.

### A2: Read project context

Before launching agents, gather context they'll need:

1. Read CLAUDE.md files in the repo root and any modified directories
2. Read tsconfig.json / .eslintrc if they exist (for type/style context)
3. Get the list of modified files from the diff

### A3: Launch 3 review agents in parallel

Launch exactly 3 agents using the Agent tool. Each agent receives:
- The full diff (or file list + repo path if diff is large — see note below)
- The list of modified files
- The project context from A2
- Their specific review focus (below)
- Instruction to score each finding with confidence 0-100

> **Large diff note**: If the diff exceeds ~5KB, do not pass the raw diff to agents. Instead pass the list of modified files and the repo path, and instruct agents to read the relevant files directly.

**Agent 1: Correctness**

Focus areas:
- **Type safety**: Missing type annotations, unsafe casts, `any` usage, nullable values not handled
- **Schema compliance**: Verify that code using API responses, database models, or GraphQL queries matches the actual type/schema definitions. Read the relevant type files to compare.
- **Bugs**: Logic errors, off-by-one, race conditions, missing error handling, unreachable code

Instruction: "You are a correctness reviewer. Focus on type safety, schema compliance, and bugs. For schema compliance, READ the actual type definition files referenced in the code and verify the usage matches. Score each finding 0-100 confidence. Only report findings with confidence >= 80."

**Agent 2: Style**

Focus areas:
- **Naming**: No single-letter variables (except `i`/`j`/`k` in short loops), descriptive names, consistent casing conventions
- **Idiomatic patterns**: Code should follow existing patterns in the codebase. Read nearby files to understand local conventions. Flag deviations.
- **Cyclomatic complexity**: Flag functions with cyclomatic complexity >= 10. Count: each `if`, `else if`, `&&`, `||`, `??`, `?.`, ternary, `case`, `catch`, and loop adds 1 to a base of 1.

Instruction: "You are a style reviewer. Focus on naming conventions, idiomatic patterns, and cyclomatic complexity. For idiomatic patterns, READ nearby files in the same directory to understand existing conventions — flag code that doesn't follow them. For naming, single-letter variables are not acceptable except i/j/k in short loops. For complexity, count cyclomatic complexity and flag >= 10. Score each finding 0-100 confidence. Only report findings with confidence >= 80."

**Agent 3: Architecture**

Focus areas:
- **Architecture**: Describe the overall design of the change. Is it well-structured? Does it introduce coupling or layering violations?
- **Reuse**: Search the codebase for existing utilities, helpers, or patterns that could replace new code. Use `Grep` and `Glob` to find similar implementations.

Instruction: "You are an architecture reviewer. First, write a 2-3 sentence description of what this change does architecturally. Then review for architectural quality and reuse opportunities. For reuse, actively SEARCH the codebase with Grep and Glob for existing utilities that do similar things to the new code. Score each finding 0-100 confidence. Only report findings with confidence >= 80."

### A4: Consolidate and present

Collect findings from all 3 agents. Deduplicate (same file + same line + same issue = one finding). Group by severity:

```
## Architecture Summary
[Agent 3's 2-3 sentence description of the change]

## Critical (90-100)
- `file.ts:42` — **[type-safety]** Unhandled null case in `fetchUser` return value
- `file.ts:88` — **[bug]** Off-by-one in loop boundary

## Important (80-89)
- `file.ts:15` — **[naming]** Variable `d` should describe what it holds
- `file.ts:60` — **[reuse]** Similar debounce logic exists in `src/utils/timing.ts:23`

## Summary
- **X** critical, **Y** important findings across **Z** files
- Agents: Correctness, Style, Architecture
```

If there are no findings at confidence >= 80, say: "No significant issues found."

---

## Mode B: Analyze Received Feedback

### B1: Fetch the feedback

Extract owner, repo, and PR number from the URL.

Fetch all review comments on the PR:

```bash
gh api repos/<OWNER>/<REPO>/pulls/<PR_NUMBER>/comments --paginate
```

Also fetch issue-level comments:

```bash
gh api repos/<OWNER>/<REPO>/issues/<PR_NUMBER>/comments --paginate
```

And fetch the PR diff for context:

```bash
gh pr diff <PR_NUMBER> --repo <OWNER>/<REPO>
```

### B2: Summarize and prioritize

Parse all comments. For each comment:
1. Identify the reviewer
2. Identify the file and line
3. Classify severity: **Must fix** (blocking, correctness issue), **Should fix** (quality improvement), **Optional** (style nit, suggestion)
4. Summarize the feedback in one line

Present grouped by severity:

```
## Feedback Summary

### Must Fix
- `file.ts:42` — @reviewer: "Null check missing here" → Unhandled null on fetchUser return

### Should Fix
- `file.ts:15` — @reviewer: "Use a descriptive name" → Rename `d` to `debounceDuration`

### Optional
- `file.ts:100` — @reviewer: "Could extract this" → Consider extracting to utility
```

### B3: Draft responses and fixes

For each comment:

1. **Read the code** at the referenced file and line
2. **Draft a code fix** if actionable — use `Edit` to apply it locally
3. **Draft a response** to the reviewer explaining what was changed

Present all fixes to the user before applying:

```
### Fix for file.ts:42 (@reviewer: "Null check missing")
[Show the proposed edit]
Response: "Good catch — added a null check with early return."

### Fix for file.ts:15 (@reviewer: "Use a descriptive name")
[Show the proposed edit]
Response: "Renamed to `debounceDuration`, thanks."
```

Use `AskUserQuestion` to confirm: "Apply these fixes?" with options:
- **Apply all** — apply all edits
- **Review one by one** — approve/reject each fix individually
- **Skip** — don't apply any fixes

### B4: Apply approved fixes

Apply the approved edits using `Edit`. After all edits are applied, show a summary:

```
## Applied Fixes
- file.ts:42 — Added null check
- file.ts:15 — Renamed `d` → `debounceDuration`

## Draft Responses (copy to PR)
- @reviewer on file.ts:42: "Good catch — added a null check with early return."
- @reviewer on file.ts:15: "Renamed to `debounceDuration`, thanks."
```

---

## Final Step: Self-Improvement

After completing the skill, invoke `/self-improve` for `review`.
