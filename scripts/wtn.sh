#!/bin/bash
set -euo pipefail

branch="${1:?Usage: wtn <branch>}"

# Must be inside a git repo
repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Not inside a git repo, dumbass." >&2
  exit 1
}
repo_name=$(basename "$repo_root")

worktree_path="$HOME/Development/worktrees/$repo_name/$branch"

# Create worktree — use existing branch or create new one off master
if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
  git worktree add "$worktree_path" "$branch"
else
  git worktree add -b "$branch" "$worktree_path" master
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

# Create tmux window with the layout
tmux new-window -n "$branch" -c "$worktree_path"
tmux send-keys -t ":$branch" "claude --dangerously-skip-permissions" Enter
tmux split-window -h -t ":$branch" -c "$worktree_path"
tmux select-pane -t ":$branch.0"
