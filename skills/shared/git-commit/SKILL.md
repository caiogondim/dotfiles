---
name: git-commit
description: |
  Generate a Conventional Commits message and commit the staged changes.
  Proposes one subject line, then one body, getting approval at each step,
  then runs git commit. Use when the user says "git-commit", "/git-commit",
  "commit", or "make a commit".
allowed-tools: Bash, AskUserQuestion, Skill
---

# /git-commit

Generate a Conventional Commits message for the **staged** changes and commit
them. One proposal per step — the user approves the subject, then the body,
then the commit runs.

## Humanizer pass

Before presenting any proposed subject or body, run the text through the
`humanizer` skill (via the Skill tool) to strip AI writing tells —
significance inflation, rule of three, em dashes, filler phrases, copula
avoidance, AI vocabulary, and the like. Do this **silently**: use only the
humanizer's final cleaned output. Do not surface its draft or its "what makes
this AI generated?" audit in the commit flow, and do not let it break the
Conventional Commits format — Step 2's type and 72-character rules still win
for the subject.

## Step 1: Gather context (staged only)

Run these in parallel:

1. Staged file summary:

   ```bash
   git diff --cached --stat
   ```

   If the output is empty, **stop** and tell the user:

   > Nothing staged. Stage changes with `/git-add` or `git add` before
   > running /git-commit.

   Never auto-stage. Only already-staged changes are committed.

2. The user's email (for style context):

   ```bash
   git config user.email
   ```

3. Recent project commits (project commit-style context):

   ```bash
   git log --oneline -10
   ```

4. Recent commits by this user (personal style context):

   ```bash
   git log --author="$(git config user.email)" --oneline -10
   ```

5. Only if the stat is ambiguous about what changed, fetch the full staged
   diff:

   ```bash
   git diff --cached
   ```

   Skip this when the stat already makes the change clear.

## Step 2: Propose the subject

Generate **one** subject line following Conventional Commits.

Rules:

- Format: `type: description`
- Valid types: `feat` `fix` `chore` `refactor` `docs` `test` `style` `perf`
  `ci` `build`
- **Never use a scope** — `fix:` not `fix(auth):`
- Imperative mood (`add`, `fix`, `update` — not `added`, `fixes`)
- **HARD LIMIT: 72 characters** for the whole subject line — count every
  character
- Match the tone and granularity of the user's recent commits

Apply the **Humanizer pass** to the subject, then re-check the hard rules
above (type prefix, no scope, imperative mood, 72-char limit) since
humanizing can change wording. The subject is terse and format-constrained,
so this is a light touch — mostly dropping AI vocabulary and em dashes.

Present the proposal for approval.

**Preferred — if the `AskUserQuestion` tool is available**, call it with one
single-select question:

- `header`: `Subject`
- `question`: the literal proposed subject, then a prompt to act, e.g.
  `` Proposed subject: `feat: add user authentication` — approve, regenerate, or pick Other to type your own. ``
- `options`:
  - `Approve` — use this subject as-is.
  - `Regenerate` — produce a different subject (different angle or type).

The widget's built-in **Other** free-text entry (or `notes` on a selection)
is the **Edit** path. List `Approve` first; do **not** mark it
"(Recommended)" — never nudge the user to rubber-stamp an unreviewed
message.

**Fallback — if the widget is not available**, present it as text and wait:

> Proposed subject: `feat: add user authentication`
>
> Approve, edit, or regenerate?

Then act on the result:

- **Approve** → go to Step 3.
- **Edit** (Other / `notes` free text, or the typed reply in the fallback) →
  use the user's wording (lightly fix it only if it breaks the format rules
  above; otherwise keep it verbatim), then continue.
- **Regenerate** → produce a *different* subject (different angle or type),
  present again the same way. Loop until approved.

## Step 3: Propose the body

Generate **one** body suggestion. It should:

- Be 2–5 sentences of plain prose — no bullet points
- **Wrap every line at 80 characters** — no line may exceed 80 chars
- Explain **what** changed and **why**, enough for a future reader without the
  diff
- Not repeat what the subject already says

Apply the **Humanizer pass** to the body, then re-wrap to 80 columns since
humanizing rewrites lines. This is where the pass does most of its work.

Present the proposal for approval.

**Preferred — if the `AskUserQuestion` tool is available**, call it with one
single-select question:

- `header`: `Body`
- `question`: the full proposed body text, then
  `approve, regenerate, skip, or pick Other to type your own.`
- `options`:
  - `Approve` — commit with this body.
  - `Regenerate` — produce a different body.
  - `Skip` — commit with no body.

The widget's built-in **Other** free-text entry (or `notes` on a selection)
is the **Edit** path. List `Approve` first; do **not** mark it
"(Recommended)".

**Fallback — if the widget is not available**, present it as text and wait:

> Proposed body:
>
> <body text>
>
> Approve, edit, regenerate, or skip?

Then act on the result:

- **Approve** → go to Step 4 with this body.
- **Edit** (Other / `notes` free text, or the typed reply in the fallback) →
  use the user's text (re-wrap to 80 cols), then continue.
- **Regenerate** → produce a different body, present again the same way.
  Loop.
- **Skip** → go to Step 4 with no body.

## Step 4: Commit

Use a heredoc to avoid shell-escaping issues:

```bash
git commit -m "$(cat <<'EOF'
<subject>
EOF
)" -m "$(cat <<'EOF'
<body>
EOF
)"
```

If the body was skipped, omit the second `-m "..."` entirely.

- **On success:** stop silently (no summary needed).
- **On error:** report the full error and give a concrete fix based on it —
  e.g. a pre-commit hook failure → state what the hook checked and how to
  satisfy it; "nothing to commit" → the staged set changed, re-run from
  Step 1.

Do **not** add a `Co-Authored-By` or any AI-attribution trailer. The commit
message is exactly the approved subject and body.
