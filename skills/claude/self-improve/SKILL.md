---
name: self-improve
description: |
  Reflect on a skill's execution and propose improvements to its SKILL.md.
  Invoked automatically at the end of other skills. Can also be called
  directly with /self-improve <skill-name>.
allowed-tools: Read, Edit, Write, AskUserQuestion, Bash
---

# Self-Improve

Reflect on a skill that just ran, compare execution against its definition, and propose concrete improvements.

## Step 1: Identify the skill

Determine which skill just ran:
- If invoked from another skill's "Final Step", the calling skill's name is the target.
- If invoked directly via `/self-improve <skill-name>`, use the provided name.
- If no name is provided, stop and ask the user: "Which skill should I reflect on?"

The skill directory is: `~/.claude/skills/<skill-name>/`

## Step 2: Read the skill definition

Read `~/.claude/skills/<skill-name>/SKILL.md` in full. This is the prescribed behavior.

## Step 3: Read the improvement log

Read `~/.claude/skills/<skill-name>/improvements.log` if it exists. This contains previously proposed improvements and whether they were accepted or rejected.

If the file doesn't exist, that's fine — there's no history yet.

## Step 4: Reflect

Compare what the skill prescribes vs. what actually happened during execution. Consider:

1. **Gaps** — Were any prescribed steps skipped, reordered, or unnecessary?
2. **Friction** — Were any steps awkward, slow, or error-prone?
3. **Missing steps** — Did you have to improvise something not covered by the skill?
4. **Output quality** — Did the output match what the user likely expected?
5. **Scope** — Are the allowed-tools sufficient? Too broad? Is the description accurate?
6. **Anything in the SKILL.md** — Frontmatter, description, steps, tools, notes are all fair game.

Cross-reference against the improvement log: do NOT re-propose something that was already rejected (unless circumstances have clearly changed).

## Step 5: Propose or stay silent

**If no improvement is found**: Say nothing. Do not force a suggestion.

**If a concrete improvement is found**: Present it to the user using `AskUserQuestion`:

- **Header**: "Skill improvement"
- **Question**: A clear description of what to change and why.
- **Options**:
  - "Accept" — Apply the change now
  - "Reject" — Log it as rejected and move on
  - "Skip" — Don't apply and don't log (maybe later)

## Step 6: Apply and log

**If accepted**:
1. Edit the SKILL.md to apply the improvement.
2. Append to `~/.claude/skills/<skill-name>/improvements.log`:
   ```
   [YYYY-MM-DD] ACCEPTED: <one-line description of the change>
   ```

**If rejected**:
1. Do NOT edit the SKILL.md.
2. Append to `~/.claude/skills/<skill-name>/improvements.log`:
   ```
   [YYYY-MM-DD] REJECTED: <one-line description of the proposed change>
   ```

**If skipped**: Do nothing. No log entry, no edit.
