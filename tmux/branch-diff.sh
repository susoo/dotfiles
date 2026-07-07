#!/usr/bin/env bash
# tmux popup: syntax-highlighted diff of the current branch vs master, paged.
# Excludes markdown and tests. Launched from the M-d binding via popup.sh.
set -euo pipefail

GIT_EXTERNAL_DIFF=difft DFT_COLOR=always \
  git diff master...HEAD -- . ':(exclude)*.md' ':(exclude)tests/' | less -R
