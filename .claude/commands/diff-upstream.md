Run `scripts/diff_upstream.sh` from the repo root (not from a worktree — the `.tmp/` cache lives in the main clone) and summarize the results.

If there are modified files, highlight what changed. If there are upstream-only files we're missing, flag those. If everything is identical, say so.

Pass through any arguments the user provides (e.g., cohort names, `--full`, `--refresh`).

$ARGUMENTS
