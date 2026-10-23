---
name: git-add
description: |
  Stage only the working-tree changes related to what we're currently working
  on, then report what was staged and what was left. Use when the user says
  "git-add", "/git-add", "git add", or "stage these changes".
allowed-tools: Bash
---

# /git-add

Stage the working-tree changes that belong to **what we're currently working
on**, and leave everything unrelated alone. Stage immediately, then report —
no approval step (staging is fully reversible).

## Step 1: Survey the working tree

Run these in parallel:

```bash
git status --short
git diff --stat
```

`git status --short` lists every changed path with its index/worktree state,
including untracked files (`??`); `git diff --stat` summarizes the unstaged
edits to tracked files (it does **not** list untracked files).

If there is nothing to stage — no unstaged or untracked changes — **stop** and
tell the user there is nothing to add. If everything relevant is already staged,
say so.

## Step 2: Select the related files

Judge each unstaged or untracked path against **what we're currently doing**,
using this session's context — the files we've been editing or discussing and
the task at hand.

- When a file's relevance is unclear from its path alone, look at its contents
  before deciding:

  ```bash
  git diff -- <path>                  # tracked file with unstaged edits
  git diff --no-index -- /dev/null <path>   # untracked file (shows full contents)
  ```

  Plain `git diff -- <path>` prints nothing for an untracked file, so use the
  `--no-index` form (or just read the file) for anything marked `??`.

- When you're still uncertain whether a file belongs to the current task,
  **leave it unstaged**. Prefer under-staging over sweeping in unrelated edits.

Never stage everything blindly.

## Step 3: Stage

Stage the selected files with explicit pathspecs:

```bash
git add -- <path> [<path>...]
```

- Use explicit paths only. **Never** `git add -A`, `git add .`, or `git add -u`
  — those would pull in unrelated changes.

## Step 4: Report

- State what was staged.
- Briefly note what was left unstaged and why (e.g. "unrelated to the current
  change").
- Remind the user that `git restore --staged <path>` un-stages anything you
  added.

Do not commit — that's `/git-commit`.
