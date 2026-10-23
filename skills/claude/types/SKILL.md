---
name: types
description: Fix TypeScript type errors in the current branch's scope. Use when the user says "type check", "check types", "fix types", "types", or "/types".
allowed-tools: Bash, Read, Edit, Grep, Glob
---

# types

Fix all TypeScript type errors in the scope of the current branch's changes.

## Step 1: Gather Context

Ask the user which scope to fix (one question, multiple choice):

> **Which scope should I fix types for?**
> 1. **Changed files** — only currently modified/staged files
> 2. **This PR** — all files touched by commits on this branch vs master
> 3. **This PR + target PR** — all files touched by this branch and the branch it targets

Wait for their answer before proceeding.

## Step 2: Collect Changed Files

Based on the chosen scope:

**Option 1 — Changed files only:**
```bash
git diff --name-only HEAD
git diff --name-only --cached
```

**Option 2 — This PR (all commits on branch vs master):**
```bash
git diff --name-only $(git merge-base HEAD master)..HEAD
```

**Option 3 — This PR + target branch:**
```bash
# Files on this branch
git diff --name-only $(git merge-base HEAD master)..HEAD
# Files on target branch (infer from git log or ask if unclear)
git diff --name-only $(git merge-base $TARGET_BRANCH master)..$TARGET_BRANCH
```

Filter to `.js`, `.jsx`, `.ts`, `.tsx` files only. Deduplicate.

## Step 3: Run Type Checker

Check if `package.json` has a `"type-check"` script:
```bash
node -e "const p = require('./package.json'); process.exit(p.scripts?.['type-check'] ? 0 : 1)"
```

- **If `type-check` exists**: `yarn type-check 2>&1`
- **Otherwise**: `hi-type-check --folder . 2>&1`

Output format: `file(line,col): error TSxxxx: message`. Exit code non-zero when errors exist.

## Step 4: Filter to Scope

From the full output, keep only errors in the files from Step 2. Ignore `node_modules/`, `__mocks__/`, `__tests__/`.

If no in-scope errors: tell the user "No type errors in the changed files." and stop.

## Step 5: Fix All Errors

Fix each error directly in the file. Common fixes:

| Error | Fix |
|-------|-----|
| TS2339 — property doesn't exist | Add optional chaining or declare property |
| TS2345 — wrong argument type | Cast, narrow, or fix the value |
| TS2686 — React UMD global | `import React from 'react'` |
| TS2304 — cannot find name | Add missing import |
| TS2322 — type not assignable | Widen type, cast, or fix the value |

Re-run type checker after fixing. Repeat until all in-scope errors are gone.

## Step 6: Report

```
## Type Errors Fixed

### `src/foo/bar.js`
- Line 42: TS2339 — Added optional chaining (`obj?.prop`)
- Line 58: TS2345 — Narrowed type with null check

**Fixed N errors across M files**
```

## Notes

- Only fix errors in scoped files — do not touch files outside the scope
- `hi-type-check` uses sensible defaults when no `tsconfig.json` exists, finding `src/**/*.{js,jsx,d.ts}`
- Errors in `node_modules/`, `__mocks__/`, `__tests__/` are noise — skip unless asked
- **Avoid casts** (`/** @type {Foo} */ (expr)`). Prefer proper type definitions and inference — typed constants, `@typedef` unions, filter/narrowing patterns — so TypeScript derives the correct type naturally.
- **Never use `import(...)` inline inside JSDoc** (e.g. `@type {import('foo').Bar}`). Always define a `@typedef` using `import(...)`, then reference that typedef below.
- **`@typedef` blocks are separate from `import` blocks** — place `@typedef` comments after all `import` statements, separated by a blank line. Never mix them into the import block.

## Final Step: Self-Improvement

After completing, invoke `/self-improve` for `types`.
