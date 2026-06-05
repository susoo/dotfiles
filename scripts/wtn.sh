#!/bin/bash
set -euo pipefail

branch="${1:?Usage: wtn <branch> [base-branch] [-p initial-prompt]}"
shift
base="HEAD"
prompt=""

# Accept optional positional base-branch for backwards compat
if [[ $# -gt 0 && "${1:0:1}" != "-" ]]; then
  base="$1"
  shift
fi

while getopts "p:" opt; do
  case "$opt" in
    p) prompt="$OPTARG" ;;
    *) echo "Usage: wtn <branch> [base-branch] [-p initial-prompt]" >&2; exit 1 ;;
  esac
done

# Must be inside a git repo
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Not inside a git repo, dumbass." >&2
  exit 1
}
worktree_path="$repo_root/.worktrees/$branch"

# Create worktree — use existing branch or create new one off $base
if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
  git worktree add "$worktree_path" "$branch"
else
  git worktree add -b "$branch" "$worktree_path" "$base"
fi

# Set COMPOSE_PROJECT_NAME so docker containers don't collide between worktrees
compose_name="${branch//\//-}"
echo "COMPOSE_PROJECT_NAME=$compose_name" >> "$worktree_path/.env"

# Copy worktree env if it exists (appends to .env so COMPOSE_PROJECT_NAME is preserved)
if [[ -f "$repo_root/.env.wt" ]]; then
  cat "$repo_root/.env.wt" >> "$worktree_path/.env"
fi

# Run setup script if it exists in the project
if [[ -x "$repo_root/scripts/setup-worktree.sh" ]]; then
  (cd "$worktree_path" && "./scripts/setup-worktree.sh")
fi

# Create tmux window with the layout. Capture the pane ID so subsequent
# commands work regardless of the user's pane-base-index (0 or 1).
first_pane=$(tmux new-window -n "$branch" -c "$worktree_path" -P -F '#{pane_id}')
if [[ -n "$prompt" ]]; then
  tmux send-keys -t "$first_pane" "claude --dangerously-skip-permissions $(printf '%q' "$prompt")" Enter
else
  tmux send-keys -t "$first_pane" "claude --dangerously-skip-permissions" Enter
fi
tmux split-window -h -t "$first_pane" -c "$worktree_path"
tmux select-pane -t "$first_pane"
