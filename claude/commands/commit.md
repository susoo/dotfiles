---
allowed-tools: Bash(uv:*), Bash(git:*), Bash(find:*), Bash(grep:*), Bash(awk:*)
description: Comprehensive pre-commit quality checks and automated committing with conventional commit format
---

# Custom Commit Command

## Context

- Current git status: !`git status --porcelain`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -5`

## Your task

Perform comprehensive pre-commit quality checks and create a conventional commit. Steps:

1. **Gather Context**
   - Check git status, current branch, and changes
   - Review recent commits for context

2. Run Linting

3. Think deeply about code that is beeing commited. Skip this step if changes are small or if or not significant. Spawn opus subagents:
   - code-simplifier:code-simplifier
   - DRY adherance
   - usage of mock or sample data outside of tests
   - adherance to best practices
   - hacky code not addressing the root cause
If any of these checks fail abort the commit task and report the problem

1. **Automated Commit (Only if all checks pass)**: 
   If all checks pass, stage changes and create a conventional commit (use multiple lines if needed):
   - if unrelated changes, split into multiple commits
   - follow conventional commit format, use multiple lines in message if needed
   - DO NOT add Claude Code footer to the commit message

## Quality Gate Behavior
- **Step 3 is quality gate** - failure stops execution
- **No commit happens** if any quality check fails
- **Clear error messages** explain what needs to be fixed
- **Only successful runs** result in commits

## Features
- **Fail-fast execution** - stops immediately on quality violations
- **Conventional commits** - generates proper commit message format
- **Smart commit detection** - analyzes changes to determine commit type
- **Custom messages** - supports user-provided commit messages via arguments
- **Comprehensive checks** - linting, mock data, complexity, security patterns
