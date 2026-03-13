Run `scripts/diff_upstream.sh` and summarize the results. The script clones upstream to `.tmp/` relative to the repo root it's run from.

If there are modified files, highlight what changed. If there are upstream-only files we're missing, flag those. If everything is identical, say so.

Pass through any arguments the user provides (e.g., cohort names, `--full`, `--refresh`).

$ARGUMENTS
