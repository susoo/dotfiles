---
description: Audit implementation against requirements spec with auto-fix cycle
---

# Requirements Audit

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Spec Path

$ARGUMENTS

If no arguments provided, look for spec documents in the `plans/` directory.

## Task

Run a requirements audit with a self-healing fix cycle (max 2 iterations).

### Step 1: Audit

Spawn the **requirements-checker** agent (sonnet) with the spec path. Pass the full spec path and any scope constraints from the arguments.

The agent will compare the codebase against the spec and return a gap report with severities.

### Step 2: Evaluate

Present the audit results to the user. Summarize:
- Total requirements checked
- Number of gaps by severity (CRITICAL, HIGH, MEDIUM, LOW)
- Which gaps are fixable in the current codebase vs need upstream decisions

If there are CRITICAL or HIGH gaps, ask the user:
> "Found N critical/high gaps. Should I attempt to fix them?"

### Step 3: Fix (if confirmed)

If the user confirms, spawn a **general-purpose** agent to fix the confirmed gaps. Pass it:
- The specific gaps to fix (from the audit report)
- The relevant file paths
- The spec text for each requirement

### Step 4: Re-audit

After fixes are applied, re-run the **requirements-checker** agent to verify the fixes resolved the gaps.

### Step 5: Report

Present the final results:
- What was fixed
- What gaps remain (if any)
- Whether a second fix iteration is needed

If gaps remain after the first fix cycle, repeat Steps 3-4 **one more time** (max 2 total iterations). After 2 iterations, report any remaining gaps as needing manual attention.

### Final Output

```
## Audit Report

### Spec: [path]
### Iterations: N

### Fixed
- [list of requirements that were successfully fixed]

### Remaining Gaps
- [list of requirements still not met, with severity and recommendation]

### Verified
- [list of requirements confirmed as implemented]
```
