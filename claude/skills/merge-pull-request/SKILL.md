---
name: merge-pull-request
description: Use when asked to merge a pull request ("merge PR #N", "PR is done, land it", "merge and clean up") — especially when the branch lives in a wtn-created git worktree with its own tmux window.
---

# Merge Pull Request

## Overview

Land a PR with a merge commit, then leave zero residue: remote branch, local branch, worktree, docker stack, iOS sim, and tmux window all gone. CI gating is YOUR job — `gh pr merge` happily merges over red checks when branch protection doesn't block.

## Steps

1. **Identify the PR.** `gh pr view <n> --json state,headRefName,mergeable,mergeStateStatus`. No number given → `gh pr list` and match by topic. Must be OPEN and MERGEABLE; conflicts → stop, report.
2. **Gate on CI:** `gh pr checks <n> --watch --fail-fast`. Waits out pending checks; any failure → STOP and report. Never merge over failing checks, never rationalize "that check is flaky".
3. **Worktree safety** (worktree = `<repo>/.worktrees/<branch with / → +>`, if it exists):
   - `git -C <wt> status --porcelain` non-empty → stop, ask user (uncommitted work would be destroyed).
   - `git -C <wt> rev-list --count origin/<branch>..<branch>` > 0 → stop, ask (the PR is missing local commits).
4. **Push local master first:** `git fetch origin master && git rev-list --count origin/master..master`. If > 0 → `git push origin master` before merging, so the merge commit lands on top and master never diverges.
5. **Merge:** `gh pr merge <n> --merge`. Always a merge commit — never `--squash`/`--rebase`. Never `--delete-branch` (the branch is checked out in the worktree; local delete would error).
6. **Sync master:** `git pull --ff-only origin master` in the canonical checkout (also lets `git branch -d` later see the branch as merged).
7. **Delete remote branch:** `git push origin --delete <branch>` then `git fetch --prune`. GitHub won't do it (check `gh repo view --json deleteBranchOnMerge` if unsure).
8. **Cleanup — check each independently, "if still exists":**
   - Worktree exists → first replicate the repo's WorktreeRemove hook manually: `make -C <wt> cleanup` (Bash `git worktree remove` does NOT fire Claude hooks; wtc's `docker compose down -v` alone misses the iOS sim and `--remove-orphans`). Then `cd <wt> && printf '\n' | wtc` (`wtc` is on PATH, shipped in the komandant repo's worktree-tools plugin, `plugins/worktree-tools/bin/wtc`; the piped newline answers its confirm prompt) — removes worktree, deletes local branch, kills the tmux window.
   - Worktree gone but tmux window remains → `tmux kill-window -t ":<branch>"` (window name = raw branch name, slashes intact).
   - Local branch remains → `git branch -d <branch>`.
9. **Report:** merged PR URL, merge commit sha, what was cleaned up.

## Self-Kill Guard

If YOU are running inside the PR's worktree (`git rev-parse --git-common-dir` ≠ `git rev-parse --git-dir`): do steps 1–7, then STOP — running `wtc` would delete your cwd and kill your own tmux window mid-turn. Tell the user to run `wtc` from the helper pane (or exit the session — native worktree removal fires the cleanup hook — then kill the window).

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Squash or rebase merge | User preference is merge commits. Always `--merge`. |
| `gh pr merge --delete-branch` | Errors: local branch is checked out in the worktree. Delete remote/local separately. |
| Bare `git worktree remove` | Skips docker + iOS sim teardown — the WorktreeRemove hook only fires on Claude-native removal. `make cleanup` first, then `wtc`. |
| Skipping step 4 | Unpushed master commits → non-fast-forward rejection after merge, messy divergence. |
| "Checks are pending, merge anyway" | `--watch` exists precisely for this. Wait or stop. |
| Killing the tmux window you're in | See Self-Kill Guard. |
