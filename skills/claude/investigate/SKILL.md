---
name: investigate
description: Use when the user wants to deeply investigate a problem, bug, behavior, or question using three parallel agents with contrasting mindsets that debate and consolidate findings.
---

# Investigate

Deep investigation skill that spawns three agents with contrasting mindsets to analyze a problem from multiple angles, debate findings, and produce a consolidated opinion.

## Step 1: Capture current state

Before any investigation, snapshot the current state so it can be restored later:

1. Record the current git branch: `git branch --show-current`
2. Record the current working directory
3. Record any uncommitted changes: `git status --short`

Store these values — you MUST restore them in the final step.

## Step 2: Understand the investigation target

Read the user's input carefully. The investigation target is whatever the user presented after invoking this skill. Think hard about what they're asking — consider:

- What is the actual problem or question?
- What area of the codebase is involved?
- What context clues are in the input?

## Step 3: Launch three investigation agents in parallel

Launch exactly 3 agents simultaneously using the Agent tool. Each agent is read-only — they may use `ls`, `cat`, `git log`, `git blame`, `git show`, `grep`, `find`, `Read`, `Glob`, `Grep`, and similar read-only operations. They may checkout branches or files temporarily as long as they restore state before finishing.

**All three agents receive the same investigation prompt** (the user's input), but each has a distinct mindset:

### Agent 1: "The Explorer" (Open-minded, creative)
- Welcomes unconventional ideas
- Looks for non-obvious connections and patterns
- Explores edge cases and unusual code paths
- Considers "what if" scenarios
- Checks for subtle interactions between systems
- Personality: curious, creative, lateral thinker
- Instruction: "You are The Explorer. You are open-minded, creative, and love to find non-obvious connections. Explore unconventional angles. Look at edge cases, unusual code paths, and subtle interactions. Think laterally. Don't dismiss any idea too early. Present your findings and your opinion on the root cause or answer."

### Agent 2: "The Pragmatist" (Conservative, methodical)
- Follows tried-and-true debugging/investigation methods
- Checks the most common causes first
- Reads docs, tests, and recent changes
- Looks at git history for relevant commits
- Focuses on what has worked before
- Personality: methodical, practical, experience-driven
- Instruction: "You are The Pragmatist. You are conservative and methodical. Start with the most likely explanations. Check recent changes, test files, documentation, and git history. Follow tried-and-true investigation methods. Focus on practical, evidence-based findings. Present your findings and your opinion on the root cause or answer."

### Agent 3: "The Classicist" (Old-school, fundamentals-focused)
- Uses only classical methods and first-principles thinking
- Reads the actual source code line by line
- Traces execution flow manually
- Checks types, contracts, and invariants
- Distrusts abstractions — looks at what the code actually does
- Personality: rigorous, skeptical, fundamentals-first
- Instruction: "You are The Classicist. You are old-school and rigorous. Use classical methods: read the source code line by line, trace execution flow manually, check types and invariants. Distrust abstractions — look at what the code *actually* does, not what it claims to do. Think from first principles. Present your findings and your opinion on the root cause or answer."

Each agent prompt must include:
1. Their personality/mindset instruction (above)
2. The full investigation target from the user
3. Instruction to be thorough and present findings clearly
4. Instruction that they are READ-ONLY — no modifications to files
5. The current working directory and repo context

## Step 4: Report individual findings

Once all three agents complete, report each agent's findings in this format:

```
## The Explorer's Findings
[Summary of what they found and their opinion]

## The Pragmatist's Findings
[Summary of what they found and their opinion]

## The Classicist's Findings
[Summary of what they found and their opinion]
```

## Step 5: Debate and consolidation

Now YOU act as the moderator. Analyze the three opinions:

1. **Where do they agree?** — These are high-confidence findings
2. **Where do they disagree?** — Examine the evidence each side presents
3. **Who has the strongest evidence?** — Weigh code evidence > speculation
4. **What did one agent find that others missed?** — Incorporate unique insights

Synthesize into a single consolidated opinion. If the agents fundamentally disagree on something, note the disagreement and explain which side you find more compelling and why.

## Step 6: Present consolidated opinion

Present the final answer in this format:

```
## Consolidated Finding

[The single, unified answer to the investigation]

### Key Evidence
- [Most important piece of evidence 1]
- [Most important piece of evidence 2]
- ...

### Points of Agreement
- [What all three agents agreed on]

### Points of Debate
- [Where they disagreed and how it was resolved]

### Recommended Next Steps
- [What the user should do with this information]
```

## Step 7: Restore state

Restore the exact state captured in Step 1:

1. Checkout the original branch: `git checkout <original_branch>`
2. Verify working directory is the same
3. Verify uncommitted changes are intact: `git status --short` should match the snapshot

If state cannot be fully restored, warn the user explicitly about what changed.

## Step 8: Self-Improvement

After completing the skill, invoke `/self-improve` for `investigate`.
