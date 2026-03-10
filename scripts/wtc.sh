#!/bin/bash
set -euo pipefail

# Must be inside a worktree (not the main repo)
wt_path=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Not inside a git repo, dumbass." >&2
  exit 1
}

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
  echo "Can't figure out what branch you're on." >&2
  exit 1
}

# Verify this is actually a worktree, not the main repo
if ! git rev-parse --git-common-dir &>/dev/null || [[ "$(git rev-parse --git-common-dir)" == "$(git rev-parse --git-dir)" ]]; then
  echo "You're in the main repo, not a worktree. Get into a worktree first." >&2
  exit 1
fi

# Bail if there are uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "Dirty working tree. Commit or stash your shit first." >&2
  exit 1
fi

# Check if branch has any commits ahead of master
main_dir=$(git rev-parse --git-common-dir)
main_dir="${main_dir%/.git}"
has_changes=false
if [[ -n $(git log master.."$branch" --oneline 2>/dev/null) ]]; then
  has_changes=true
fi

echo "Closing worktree for branch '$branch':"
echo "  Remove worktree:  $wt_path"
echo "  Kill tmux window: :$branch"
if $has_changes; then
  echo "  (branch '$branch' has commits — keeping it)"
else
  echo "  Delete branch:    $branch (no changes)"
fi
echo ""
read -rp "Press Enter to confirm, Ctrl-C to bail..."

# Tear down containers for this worktree
if [[ -f "$wt_path/docker-compose.yml" ]] || [[ -f "$wt_path/compose.yml" ]]; then
  (cd "$wt_path" && docker compose down -v)
  echo "Docker containers nuked."
fi

git worktree remove "$wt_path"
echo "Worktree removed."

if ! $has_changes; then
  git -C "$main_dir" branch -d "$branch" 2>/dev/null && echo "Branch '$branch' deleted." || echo "Couldn't delete branch '$branch' (maybe already gone)."
fi

tmux kill-window -t ":$branch" 2>/dev/null && echo "Tmux window killed." || echo "No tmux window ':$branch' found (maybe already closed)."
