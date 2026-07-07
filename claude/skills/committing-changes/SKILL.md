---
name: committing-changes
description: Use when the user asks to commit, says "/commit", or you are about to create a git commit and want a quality gate before it lands.
---

# Committing Changes

## Overview

Quality-gated commit: review the diff, then create a conventional commit only if the review passes. Fail-fast — a blocking finding stops the commit, nothing is staged.

## When to Use

- User asks to commit, or says `/commit`
- You finished a unit of work and want it committed cleanly
- Skip the review stage (step 3) only when the change is trivial (typo, comment, formatting, single-line config)

## Project rules (auto-injected)

Loaded at skill invocation. Pass this block **verbatim** into the `rule-reviewer` Task prompt under a `PROJECT RULES` header — the agent enforces these without reading any files itself.

```!
echo "=== CLAUDE.md ==="; cat CLAUDE.md 2>/dev/null || echo "(none)"
echo "=== docs/RULES.md ==="; cat docs/RULES.md 2>/dev/null || echo "(none)"
```

## Process

1. **Gather context**
   - `git status --porcelain` — what changed
   - `git branch --show-current` — current branch
   - `git log --oneline -5` — recent commits for message style

2. **Run linting** on the changed files. Lint failure → fix or abort.

3. **Quality review** (quality gate) — skip only if the change is trivial/insignificant. Otherwise dispatch these agents **in parallel** (single message, multiple Task calls), each scoped to the staged/uncommitted diff:
   - `simplifier` — complexity, dead code, DRY/duplication, convention violations, over-engineering
   - `skeptic` — logic flaws, security, edge cases, error handling, hacky code not addressing the root cause
   - `rule-reviewer` — mechanical anti-patterns (incl. mock/sample data outside tests) plus the auto-injected **Project rules** block above, pasted into its Task prompt under a `PROJECT RULES` header
   - `architect` — only for significant/architectural changes: spec alignment, test coverage, root-cause correctness

   If any agent reports a blocking violation, **abort the commit** and report the problem clearly. No commit happens.

4. **Commit** (only if all checks pass)
   - Conventional commit format; multiple lines if needed
   - Split unrelated changes into separate commits
   - Honor a user-provided message if given
   - **Do NOT add a Claude Code footer**

## Quality Gate Behavior

- Step 3 is the gate — failure stops execution, no commit.
- Clear error messages explain what needs fixing.
- Only a clean review results in a commit.

## Common Mistakes

- Committing with the review skipped on a non-trivial change → run the agents.
- Bundling unrelated changes into one commit → split them.
- Adding a Claude/co-authored footer → don't.
- Running agents on the whole repo instead of the diff → scope each to the uncommitted diff.
