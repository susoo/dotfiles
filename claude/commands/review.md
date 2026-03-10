---
description: Run all 4 review agents in parallel, triage findings, and optionally fix auto-fixable issues
---

# Code Review — Full Pipeline

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Scope

$ARGUMENTS

If no arguments provided, review uncommitted changes (git diff HEAD).

## Task

Run the full review pipeline: 4 review agents → triage → optional fix cycle.

### Step 1: Parallel Review

Spawn all 4 review subagents **in parallel** to review the current changes:

1. **architect** (opus) — spec alignment, test coverage, architectural correctness, multi-layer bug tracing
2. **skeptic** (sonnet) — logic flaws, auth gaps, race conditions, edge cases, security vulnerabilities
3. **simplifier** (sonnet) — dead code, complexity, convention violations, duplication
4. **rule-reviewer** (sonnet) — mechanical anti-pattern scan against the hard rule list

Pass the scope to each agent. If arguments were provided, instruct each agent to use that scope instead of the default `git diff HEAD`.

### Step 2: Deduplicate & Merge

After all 4 agents complete, merge their findings into a single unified severity table. Deduplicate overlapping findings — if multiple agents flag the same issue, keep the most detailed description and the highest severity.

### Step 3: Triage

Spawn the **triage** agent (opus) with the combined findings from all 4 agents as input. The triage agent will:
- Classify each finding (implementation bug, spec gap, architecture miss, deferred)
- Assess domain risk (auth, payments, data, infra)
- Route each finding (auto-fixable, manual fix, needs upstream attention)

### Step 4: Present Results

Present the triage results to the user in a clear summary:
- Severity table with classifications and routing
- List of auto-fixable issues
- List of issues needing upstream attention
- Overall risk assessment

Then ask the user:
> "Found N auto-fixable issues. Should I fix them?"

### Step 5: Fix Cycle (if confirmed)

If the user confirms, spawn a **general-purpose** agent to fix the auto-fixable issues. Pass it:
- The specific issues to fix from the triage report
- The file paths and line numbers
- The expected fix for each issue

### Step 6: Verification

After fixes are applied, re-run the relevant review agents (only the ones whose findings were addressed) to verify the fixes are correct and didn't introduce new issues.

### Step 7: Final Report

Present the final report:

```
## Review Summary

### Branch: [branch]
### Scope: [scope]

### Findings
| # | Severity | Classification | Domain | Route | File:Line | Summary | Status |
|---|----------|---------------|--------|-------|-----------|---------|--------|
| 1 | CRITICAL | IMPL_BUG | AUTH | AUTO_FIX | auth.ts:42 | ... | FIXED |
| 2 | WARNING | SPEC_GAP | GENERAL | UPSTREAM | api.ts:10 | ... | OPEN |

### Fixed (N)
- [list of issues that were fixed]

### Open (N)
- [list of issues still needing attention]

### Deferred (N)
- [list of low-priority items]
```
