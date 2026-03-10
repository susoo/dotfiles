#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    echo "  backup: $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -s "$src" "$dst"
  echo "  linked: $dst → $src"
}

echo "=== Zsh (Powerlevel10k) ==="
link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

echo ""
echo "=== Tmux ==="
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo ""
echo "=== Worktree Scripts ==="
mkdir -p "$HOME/.local/bin"
link "$DOTFILES_DIR/scripts/wtc.sh" "$HOME/.local/bin/wtc"
link "$DOTFILES_DIR/scripts/wtn.sh" "$HOME/.local/bin/wtn"

echo ""
echo "=== Claude Code ==="
mkdir -p "$HOME/.claude/commands" "$HOME/.claude/agents"
for f in "$DOTFILES_DIR"/claude/commands/*.md; do
  link "$f" "$HOME/.claude/commands/$(basename "$f")"
done
for f in "$DOTFILES_DIR"/claude/agents/*.md; do
  link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

echo ""
echo "Done! Make sure ~/.local/bin is in your PATH."
echo "  e.g. add to ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
