#!/usr/bin/env bash
# tmux fuzzy command picker — fzf a command, send it to the originating pane.
# $1 = target pane id (passed from tmux binding via #{pane_id})
set -euo pipefail

target="${1:?pane id required}"

# label <TAB> command   — edit this list freely.
commands=$(cat <<'EOF'
zed here	zed .
lazygit	lazygit
git status	git status
git log	git log --oneline --graph --decorate -20
git pull	git pull
git push	git push
docker compose up	docker compose up -d
docker compose logs	docker compose logs -f
docker ps	docker ps
EOF
)

choice=$(printf '%s\n' "$commands" \
  | fzf --with-nth=1 --delimiter='\t' --prompt='cmd> ' --reverse --height=100%) || exit 0

cmd=$(printf '%s' "$choice" | cut -f2-)
tmux send-keys -t "$target" "$cmd" Enter
