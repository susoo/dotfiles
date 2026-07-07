---
name: installing-dotfiles
description: Use when setting up these dotfiles on a fresh machine (macOS or Linux), bootstrapping a new dev box, validating a dotfiles install, or debugging a degraded shell after cloning (missing p10k prompt, "command not found: pyenv", "unknown option: --zsh", fd/bat not found, lazygit ignoring config).
---

# Installing Dotfiles (Cross-Platform)

## Overview

These dotfiles are **two layers**, and only one of them is automated:

1. **Symlink layer** — `install.sh` links configs into place. Portable, runs anywhere.
2. **Dependency + platform layer** — prerequisites and macOS-specific paths baked into `.zshrc`/`install.sh`. **Manual.** This is where a fresh machine breaks.

`install.sh` **only symlinks**. It installs nothing and detects no OS. Run it on bare Linux and the shell loads degraded (no prompt theme, no fzf keybinds, no pyenv). This runbook fills the gap: install deps, apply platform fixups, then validate every piece actually works.

**Core principle: a clean exit from `install.sh` is not a working setup. Validate, don't assume.**

## Prerequisites

| Tool | macOS (brew) | Debian/Ubuntu (apt) | Notes |
|---|---|---|---|
| zsh | preinstalled | `zsh` | login shell |
| tmux | `tmux` | `tmux` | |
| neovim | `neovim` | `neovim` | config is `init.lua` |
| fzf | `fzf` | ⚠ see gotcha — apt version too old | needs ≥ 0.48 for `--zsh` |
| fd | `fd` | `fd-find` → binary `fdfind` | ⚠ rename needed |
| bat | `bat` | `bat` → binary `batcat` | ⚠ rename needed |
| ripgrep | `ripgrep` | `ripgrep` | nvim live-grep |
| lazygit | `lazygit` | not in apt — GitHub release | tmux `M-f` popup |
| gh + gh-dash | `gh` `gh-dash` | gh apt repo; `gh extension install dlvhdr/gh-dash` | tmux `M-i` popup |
| lazydocker | `lazydocker` | GitHub release / script | tmux `M-p` popup |
| pyenv | `pyenv` | `curl https://pyenv.run \| bash` | `.zshrc:13` sources it |
| uv | `brew install uv` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` | creates `~/.local/bin/env` (`.zshrc:22`) |
| powerlevel10k | `brew install powerlevel10k` | git clone (see gotcha) | `.zshrc:8` |
| tpm | `git clone tmux-plugins/tpm ~/.tmux/plugins/tpm` | same | tmux plugin mgr |

## Install Steps

1. **Clone** to the exact expected path (aliases + tmux popups hardcode it):
   `git clone <repo> ~/Development/dotfiles && cd ~/Development/dotfiles`

2. **Install prerequisites** for your OS from the table above.

3. **Linux-only fixups** (skip on macOS):
   - Alias fd/bat to the names `.zshrc` expects:
     `mkdir -p ~/.local/bin && ln -s "$(command -v fdfind)" ~/.local/bin/fd && ln -s "$(command -v batcat)" ~/.local/bin/bat`
   - Get a modern fzf (apt's is too old for `--zsh`): `git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --bin`, then put `~/.fzf/bin` on PATH.
   - Powerlevel10k: `.zshrc:8` hardcodes the Homebrew path `/opt/homebrew/share/powerlevel10k/`. To keep `.zshrc` unedited, recreate that path: `sudo mkdir -p /opt/homebrew/share && sudo git clone --depth 1 https://github.com/romkatv/powerlevel10k.git /opt/homebrew/share/powerlevel10k`. *(Cleaner long-term: make `.zshrc` OS-detect — out of scope for this runbook.)*
   - pyenv on PATH before `.zshrc` runs: ensure `~/.pyenv/bin` is on PATH.

4. **Run the symlinker:** `chmod +x install.sh tmux/*.sh && ./install.sh`

5. **Fix the lazygit path on Linux.** `install.sh:38` links into the macOS-only `~/Library/Application Support/lazygit/`. Linux lazygit reads `~/.config/lazygit/`:
   `mkdir -p ~/.config/lazygit && ln -sf ~/Development/dotfiles/lazygit/config.yml ~/.config/lazygit/config.yml`

6. **Add `~/.local/bin` to PATH** (the install script reminds you, but doesn't do it): append `export PATH="$HOME/.local/bin:$PATH"` to `.zshrc` *only if not already present* (note: `.zshrc:22` sources `~/.local/bin/env`, which is the uv file from step 2 — keep them straight).

7. **Bootstrap tmux plugins:** clone tpm to `~/.tmux/plugins/tpm`, start tmux, press `prefix + I` to install (tmux-sensible, tmux-resurrect, catppuccin).

8. **Reload + validate** (next section). Open a fresh `zsh -l`.

## Cross-Platform Gotchas (observed on fresh Ubuntu 24.04)

| Symptom | Cause | Fix |
|---|---|---|
| `source:8: no such file ... powerlevel10k.zsh-theme` | `.zshrc:8` hardcodes brew path | step 3 (recreate path) or OS-detect |
| `command not found: pyenv` | pyenv not installed / not on PATH | install pyenv, PATH it before `.zshrc:13` |
| `no such file: ~/.local/bin/env` | uv not installed | install uv (creates the file) |
| `unknown option: --zsh` | apt fzf < 0.48 | install fzf from source (step 3) |
| fzf finds no files / Ctrl-T preview blank | `.zshrc:38,42` call `fd`/`bat`, Linux has `fdfind`/`batcat` | symlink rename (step 3) |
| lazygit ignores theme/config | `install.sh:38` uses macOS path | link into `~/.config/lazygit` (step 5) |
| tmux `M-y` copy does nothing | `.tmux.conf:54` pipes to `pbcopy` (macOS) | alias `pbcopy`→`xclip -sel clip` / `wl-copy` |
| tmux popups `M-f/M-i/M-p` flash + close | lazygit / gh-dash / lazydocker missing | install them (table) |

## Validation Checklist

Run each. **Green exit ≠ working — check the actual output.**

- **Symlinks resolve (not dangling):**
  `for l in ~/.zshrc ~/.p10k.zsh ~/.tmux.conf ~/.config/nvim/init.lua ~/.local/bin/wtc ~/.local/bin/wtn; do [ -e "$l" ] && echo "OK $l" || echo "BROKEN $l"; done`
- **Shell loads with zero errors:** `zsh -i -c 'echo OK'` — any `command not found` / `no such file` / `unknown option` line is a failure, even though exit code is 0. *(`can't change option: zle` only appears when there's no real terminal — CI/`docker exec` — and is harmless.)*
- **Prompt theme renders:** open interactive zsh → Powerlevel10k prompt (not bare `%`).
- **fzf keybinds live:** `Ctrl-R` history, `Ctrl-T` file list with `bat` preview, `Alt-C` dir jump.
- **fd/bat resolve:** `command -v fd && command -v bat` both print a path.
- **pyenv + uv:** `pyenv --version` and `uv --version` both succeed.
- **tmux starts + theme loads:** `tmux new -d -s t && tmux kill-session -t t` clean; interactively confirm catppuccin status bar + popups (`M-f` lazygit, `M-i` gh-dash, `M-p` lazydocker).
- **nvim config loads:** `nvim --headless +q` exits 0; `<leader>f`/`<leader>g` pickers work (needs ripgrep).
- **worktree scripts on PATH:** `command -v wtc wtn`.
- **claude commands/agents/skills linked:** `ls ~/.claude/commands ~/.claude/agents ~/.claude/skills` show symlinks.

## Common Mistakes

- **Trusting `install.sh` exit 0.** It symlinks blindly; the shell can still be broken. Always run the validation checklist.
- **Cloning to the wrong path.** Aliases and tmux popups hardcode `~/Development/dotfiles`. Clone elsewhere and `wtn`/`wtc`/`cmd-picker.sh` break.
- **Skipping the fd/bat rename on Linux.** Everything "installs" but fzf silently finds nothing.
- **Forgetting `prefix + I`** in tmux — config loads but plugins/theme don't until TPM installs them.
- **Editing `.zshrc` per-machine instead of fixing portability.** If you edit it on the box, the symlink means you've edited the repo. Either commit a proper OS-detect change or use the path-recreation workarounds here.

## Real-World Impact

Fresh Ubuntu 24.04 container test: `install.sh` exited 0 and every symlink resolved, yet the shell loaded with 4 errors (p10k, pyenv, uv env, fzf `--zsh`), fzf file source was dead (fd naming), and lazygit silently ignored its config. **The symlink layer passed; the setup did not.** This runbook exists to catch that gap.
