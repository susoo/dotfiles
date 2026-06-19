#!/bin/bash
set -euo pipefail

# wtn <branch> [-p initial-prompt]
# Thin launcher over Claude Code NATIVE worktrees. Claude creates the worktree
# (at .claude/worktrees/<branch>); wtn just opens a tmux window, starts the native
# session, and drops a helper shell pane inside the worktree once it exists.
# Provisioning is NOT wtn's job anymore — .worktreeinclude copies .env, and the
# project's stack-start entrypoint runs scripts/setup-worktree.sh.

branch="${1:?Usage: wtn <branch> [-p initial-prompt]}"
shift
prompt=""
while getopts "p:" opt; do
  case "$opt" in
    p) prompt="$OPTARG" ;;
    *) echo "Usage: wtn <branch> [-p initial-prompt]" >&2; exit 1 ;;
  esac
done

[ -n "${TMUX:-}" ] || { echo "wtn: must be run inside a tmux session." >&2; exit 1; }

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "wtn: not inside a git repo." >&2
  exit 1
}
wtpath="$repo_root/.claude/worktrees/${branch//\//+}"   # native path + sanitization

# New tmux window rooted at the repo; capture the pane id (pane-base-index agnostic).
pane=$(tmux new-window -n "$branch" -c "$repo_root" -P -F '#{pane_id}')
cmd="claude --dangerously-skip-permissions --worktree $(printf %q "$branch")"
[ -n "$prompt" ] && cmd+=" $(printf %q "$prompt")"
tmux send-keys -t "$pane" "$cmd" Enter

# Claude creates the worktree only AFTER its trust check passes. Poll (bounded)
# until it exists, then split a helper shell INTO it (deterministic -c, no
# cwd-inherit race). If it never appears the dir is probably untrusted — fail
# loud rather than hang forever.
for _ in $(seq 1 80); do [ -d "$wtpath" ] && break; sleep 0.25; done
if [ ! -d "$wtpath" ]; then
  echo "wtn: worktree $wtpath did not appear within 20s." >&2
  echo "  → if this repo is untrusted, run 'claude' here once and accept the trust dialog, then retry." >&2
  exit 1
fi
tmux split-window -h -t "$pane" -c "$wtpath"
tmux select-pane -t "$pane"
