---
name: cg-commit
description: |
  Generate a Conventional Commits message and commit. Suggests 3 subject line
  options, iterates on commit body until approved, then runs git commit.
  Use when the user says "commit", "make a commit", or "/cg-commit".
allowed-tools: Bash, question
---

# Commit

Generate a commit message and commit the current changes.

## Step 1: Gather context

Run all of the following git commands in parallel:

1. Get the user's email:
   ```bash
   git config user.email
   ```

2. Get a summary of changed files:
   ```bash
   git diff HEAD --stat
   ```
   If empty, try staged-only:
   ```bash
   git diff --cached --stat
   ```
   If still empty, stop and tell the user:
   > "No changes detected. Stage or modify files before committing."

3. Get recent branch commits (project style context):
   ```bash
   git log --oneline -10
   ```

4. Get recent commits by the current user (personal style context):
   ```bash
   git log --author="$(git config user.email)" --oneline -10
   ```

5. If the stat summary is ambiguous, fetch the full diff:
   ```bash
   git diff HEAD
   ```
   Skip when the stat clearly describes the changes.

## Step 1b: Stage changes

If `git diff HEAD --stat` showed unstaged changes, stage them before committing:

```bash
git add <files shown in the stat>
```

Prefer staging specific files by name rather than `git add -A` or `git add .` to
avoid accidentally including unrelated files. If it's unclear which files to stage,
ask the user.

Skip this step if all changes are already staged (i.e. `git diff --cached --stat`
already shows the relevant files).

## Step 2: Pick subject line

Generate exactly 3 subject line options following Conventional Commits.

Rules:
- Valid prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `style:`, `perf:`, `ci:`, `build:`
- **Never use a scope** — do not add `(scope)` to the prefix. Use `fix:` not `fix(auth):`
- **HARD LIMIT: 80 characters or less total** — count every character
- Use imperative mood ("add", "fix", "update")
- Match the tone of the user's recent commits
- The 3 options must vary in angle/framing (what was done vs. why vs. which area)

Use the `question` tool to present options:

```
question({
  question: "Pick a subject line",
  options: [
    { label: "feat: add user authentication" },
    { label: "fix: resolve login redirect bug" },
    { label: "chore: update auth dependencies" }
  ]
})
```

## Step 3: Iterate on body

Generate one body suggestion. The body should:
- Be 2-5 sentences of plain prose (no bullet points)
- **HARD LIMIT: wrap every line at 80 characters** — no line in the body may exceed 80 chars
- Explain **what** changed and **why** — enough context for an agent or future reviewer without reading the diff
- Not repeat what the subject line says

Use the `question` tool to present options:

```
question({
  question: "Approve this body or get a new suggestion:\n\n<body text here>",
  options: [
    { label: "Approve" },
    { label: "Next suggestion" },
    { label: "Skip" }
  ]
})
```

If the user picks "Next suggestion", generate a different body and repeat this step.

Loop until the user approves or skips.

## Step 4: Commit

Run git commit using a heredoc to avoid shell escaping issues:

```bash
git commit -m "$(cat <<'EOF'
<subject>
EOF
)" -m "$(cat <<'EOF'
<body>
EOF
)"
```

Omit the `-m "<body>"` part if the user skipped the body.

**On success**: stop silently.

**On error**: report the full error and suggest a concrete fix based on the error content (e.g. pre-commit hook failure → show what the hook checked and how to fix it; nothing staged → run `git add`).
