#!/usr/bin/env bash
# tmux capped-width popup — width is min(300, 90% of client width) so it never
# exceeds the terminal (a fixed `-w 300` errors "width too large" on narrow
# screens) yet stays sane on ultrawides.
# $1 = start dir ('' to skip -d)   $2 = command to run in the popup
set -euo pipefail

dir="$1"
cmd="${2:?command required}"

width=$(tmux display-message -p '#{client_width}')
width=$(( width * 90 / 100 ))
(( width > 300 )) && width=300

if [[ -n "$dir" ]]; then
  tmux display-popup -d "$dir" -w "$width" -h 95% -E "$cmd"
else
  tmux display-popup -w "$width" -h 95% -E "$cmd"
fi
