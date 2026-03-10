# Dotfiles

My shared dev configs: tmux, git worktree scripts, and Claude Code agents/commands.

## What's Included

### Tmux
Catppuccin-themed tmux config with vi keys, Alt-based pane/window navigation, and popup shortcuts for lazygit, gh-dash, and lazydocker.

### Worktree Scripts
- **`wtn <branch>`** — Create a new git worktree with a dedicated tmux window and Claude Code session
- **`wtc`** — Close the current worktree, clean up docker containers, tmux window, and branch

### Claude Code Agents & Commands
Custom slash commands and subagents for Claude Code:

**Commands** (invoke with `/command-name`):
- `/audit` — Audit implementation against a requirements spec with auto-fix cycle
- `/commit` — Pre-commit quality checks + conventional commit
- `/review` — Run 4 review agents in parallel, triage findings, optionally auto-fix
- `/test` — Browser test pipeline (QA research → browser automation with GIF recording)
- `/handoff` — Generate a self-contained handoff prompt for another AI agent
- `/docker-compose-logs` — Quick docker compose log viewer

**Agents** (used by commands, or spawned directly):
- `architect` — Deep-thinking code review: spec alignment, test coverage, architectural correctness
- `skeptic` — Adversarial reviewer: logic flaws, auth gaps, race conditions, security vulns
- `simplifier` — Complexity reviewer: dead code, duplication, convention violations
- `rule-reviewer` — Mechanical anti-pattern scanner (secrets, debug statements, magic numbers, etc.)
- `triage` — Engineering manager that classifies and routes review findings
- `requirements-checker` — Audits codebase against spec documents
- `qa` — Pre-flight research for browser testing (routes, selectors, fixtures)
- `browser-tester` — Executes browser test flows with Chrome automation and GIF recording

## Install

```bash
git clone https://github.com/susodotdev/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
chmod +x install.sh scripts/*.sh
./install.sh
```

The install script symlinks everything into place. Existing files get backed up as `.bak`.

Make sure `~/.local/bin` is in your `PATH`:

```bash
# Add to ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

## Prerequisites

- [tmux](https://github.com/tmux/tmux) + [tpm](https://github.com/tmux-plugins/tpm)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [lazygit](https://github.com/jesseduffield/lazygit) (for tmux popup)
- [gh-dash](https://github.com/dlvhdr/gh-dash) (for tmux popup)
- [lazydocker](https://github.com/jesseduffield/lazydocker) (for tmux popup)
