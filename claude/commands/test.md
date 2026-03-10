---
description: Run browser test pipeline — qa research then browser-tester execution with GIF recording
---

# Browser Test Pipeline

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Scope

$ARGUMENTS

If no arguments provided, test the main user-facing flows of the application.

## Task

Run the browser test pipeline in two stages: research then execution.

### Stage 1: Pre-flight Research

Spawn the **qa** agent (sonnet) to do pre-flight research on the codebase. Pass it the test scope from the arguments (or "main user-facing flows" if no arguments).

The qa agent will return a structured test context report containing:
- App info (framework, base URL, start command)
- Routes under test with selectors
- Test data from fixtures/seeds
- Step-by-step test flows with expected outcomes
- Prerequisites (running services, env vars, etc.)

### Stage 2: Verify Prerequisites

Before spawning the browser-tester, check the prerequisites from the qa report:
- Is the dev server running? If not, inform the user and ask if they want to start it.
- Are there any missing env vars or setup steps?

### Stage 3: Browser Test Execution

Spawn the **browser-tester** agent (sonnet, foreground — NOT background since it needs MCP tools) with the full test context report from Stage 1.

The browser-tester will:
- Execute each test flow in a real browser
- Record GIFs of each flow
- Report pass/fail for each step

**Important**: The browser-tester agent must run in the foreground because MCP tools (claude-in-chrome) are not available to background agents.

### Stage 4: Results

Present the combined results:

```
## Browser Test Results

### Environment
- App: [framework] at [URL]
- Branch: [branch name]

### Results
| Flow | Status | GIF |
|------|--------|-----|
| Login flow | PASS | login_flow.gif |
| Dashboard load | FAIL | dashboard_flow.gif |

### Failures
[Details of any failed flows with screenshots and error descriptions]

### Coverage
- Flows tested: N
- Passed: N
- Failed: N
- Skipped: N
```
