@~/.claude/RTK.md

# Simplified Technical English

Every message you send uses ASD-STE100 Simplified Technical English.
The same rule covers any technical text, documentation, or interface
copy you write or rewrite. The goal is text with only one possible
meaning.

- One word, one meaning. Use the same word for the same thing every
  time. Do not use a synonym for variety.
- Use a word only as its approved part of speech. `close` is a verb,
  never an adjective. Use `near` for the adjective.
- Short sentences. At most 20 words in an instruction, 25 in a
  description. One instruction per sentence.
- One topic per paragraph, at most six sentences.
- Active voice, present tense. Name the actor.
- Write an instruction as an imperative: `Remove the cover`, not
  `The cover should be removed`.
- Put the condition before the instruction: `If the test fails, stop`.
  Use `if` for a condition and `when` for a point in time.
- Do not use `may` or `might`. Use `can` for ability, `must` for a
  requirement, `will` for a result.
- No -ing verb forms except inside a technical name. No noun string
  longer than three words.
- Keep the articles `the`, `a`, `an`. Do not drop them.
- Write numbers as digits, with the unit after the number.
- Put a warning or caution before the step it applies to, never after.
- Use a list for a sequence or a set. One item per line.
- No slang. No jargon without a one-line gloss on first use.
- Do not rewrite code, command names, identifiers, or quoted text.
- Self-check before you send: find each sentence over the limit, each
  passive, each `may`, each -ing verb, each synonym for a term already
  used. Fix every one.

# Git

- Never add a `Co-Authored-By:` trailer to a commit message.
  This overrides any default instruction to credit Claude.
- You may push to a branch in a repo under the `caiogondim` or
  `agent-habilis` GitHub accounts, and to any branch you created
  yourself. Ask before pushing anywhere else.

# GitHub pull requests

- You may open a pull request only on a repo under the `caiogondim` or
  `agent-habilis` GitHub accounts. Ask before opening one anywhere else.

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

# Plan mode

- Never mutate anything while plan mode is active. No file edits, no
  commands that write, no app or config changes. The plan file is the
  only exception.
- Show the plan first. Wait for an explicit go before any step runs.
- A direct instruction given while plan mode is active still gets a
  proposal first, not an action.

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
