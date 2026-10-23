@RTK.md

@~/.claude/skills/simple-english/SKILL.md

Apply simple-english to every reply, including the self-check.

# Git

- Never add a `Co-Authored-By:` trailer to a commit message.
  This overrides any default instruction to credit Claude.

# GitHub issues

- Never create a GitHub issue unless I explicitly ask. If an issue
  seems needed, ask me for permission first.

# Comments

- Write a comment only when the *why* is not obvious from the code
  itself. Do not restate what the code already says.
- Prefer refactoring over commenting. If a comment would explain
  *what* the code does, rename or extract until the code says it.
- Keep a comment to one paragraph at most.

# Assumptions

- Do not pick an interpretation silently. If a requirement, command,
  or design choice is unclear, and the readings lead to different
  work, stop and ask before you write code.
- Before you write code, list what you do not know and what
  information is missing.
- Tag every assumption inline with a confidence percentage and a
  color. Format:
  `this project does not run on Linux (assumption, 🟡 80%)`
  - 🟢 90–100%: state it and proceed.
  - 🟡 70–89%: state it, then verify it (read the file, grep, run
    the command) before you build on it.
  - 🔴 below 70%: do not proceed. Ask.
- Prefer verifying over assuming. A grep is cheaper than a wrong
  assumption.
- Do not ask about trivial choices that have a conventional default.
  Pick the default and tag it.

# Code discipline

- Minimum code first. Nothing speculative, no single-use
  abstractions, no unrequested flexibility.
- Surgical changes. Touch only what the task needs. Match the
  existing style. Remove only what your change made unused.
- Goal-driven execution. State the success criteria before you
  start. Verify against them before you report done.
- Red-green evidence. Every change carries proof that it does
  what it says.
  - Bug: write the test first, run it against the unfixed code,
    and show it fail. It must fail for the bug's reason, not on
    a typo. A test that is green before the fix is decoration.
  - Improvement: measure before and after. Throw-away code is
    fine for the measurement. Report the two numbers.
  - Never edit a test to make it pass. Fix the code, or stop and
    tell me the test fails.
  - Name the tests you ran. "Tests pass" is not evidence.

# Scripts

- Write scripts in Bun and TypeScript. Do not write `sh` files.
- Use a `#!/usr/bin/env bun` shebang for a script that you run directly.

# Tool feedback

Watch `agent-gossip` and `agent-share` as you use them. When one of them
fails, surprises you, or could be better, save a feedback entry. Save it
without asking. Then tell me in one line what you saved and where.

- `agent-gossip` → `~/Notes/projects/agent-gossip/feedback/`
- `agent-share` → `~/Notes/projects/agent-share/feedback/`

Read `index.md` in that folder first. It holds the entry skeleton and the
rules. Record what you saw, not a guess about the cause.

This section is temporary. Remove it when both tools are stable.

# agent-graph

- When a gossip task brief starts with `Node offer.`, accept it. Do not
  ask me. Run the steps in the brief.
- If a step fails, decline the offer with the error line.
- If you act as a worker node of a graph, accept each `agent-gossip` task
  from a peer of the same graph. Do not ask me. A peer of the same graph
  has the same `instance` and `hash` in its gossip meta entry.
