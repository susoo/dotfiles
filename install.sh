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

echo "=== Zsh ==="
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

echo ""
echo "=== Tmux ==="
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo ""
echo "=== Ghostty ==="
mkdir -p "$HOME/.config/ghostty"
link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

echo ""
echo "=== Neovim ==="
mkdir -p "$HOME/.config/nvim"
link "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

echo ""
echo "=== Worktree Scripts ==="
mkdir -p "$HOME/.local/bin"
link "$HOME/Development/komandant/plugins/worktree-tools/bin/wtc" "$HOME/.local/bin/wtc"
link "$HOME/Development/komandant/plugins/worktree-tools/bin/wtn" "$HOME/.local/bin/wtn"

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
echo "Done! Add this to your ~/.zshrc:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
