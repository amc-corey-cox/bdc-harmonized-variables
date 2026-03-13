#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
UPSTREAM_URL="https://github.com/RTIInternational/NHLBI-BDC-DMC-HV.git"
CLONE_DIR="$REPO_ROOT/.tmp/upstream"
UPSTREAM_INGEST="$CLONE_DIR/priority_variables_transform"
LOCAL_SPECS="$REPO_ROOT/trans_specs"

# Cohort → upstream -ingest folder mapping
# Our local version dirs map to <COHORT>-ingest/ upstream.
# FHS-v33-base is the exact upstream baseline; v33/v35 have local enrichments.
declare -A COHORT_MAP=(
    ["ARIC/ARIC-v8"]="ARIC-ingest"
    ["CARDIA/CARDIA-v3"]="CARDIA-ingest"
    ["CHS/CHS-v7"]="CHS-ingest"
    ["COPDGene/COPDGene-v6"]="COPDGene-ingest"
    ["FHS/FHS-v33-base"]="FHS-ingest"
    ["HCHS/HCHS-v2"]="HCHS-ingest"
    ["JHS/JHS-v7"]="JHS-ingest"
    ["MESA/MESA-v13"]="MESA-ingest"
    ["WHI/WHI-v12"]="WHI-ingest"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [COHORT...]

Compare local trans-specs against upstream -ingest files.

Options:
  -f, --full     Show full diff output (default: summary only)
  -r, --refresh  Force re-clone even if .tmp/upstream exists
  -h, --help     Show this help

Arguments:
  COHORT         One or more cohort keys to compare (e.g., ARIC MESA)
                 Default: all cohorts

Available cohort keys: ${!COHORT_MAP[*]}

Examples:
  $(basename "$0")              # Summary of all cohorts
  $(basename "$0") -f CARDIA    # Full diff for CARDIA only
  $(basename "$0") -r           # Re-clone upstream, then summarize all
EOF
}

FULL_DIFF=false
REFRESH=false
COHORTS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--full) FULL_DIFF=true; shift ;;
        -r|--refresh) REFRESH=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) COHORTS+=("$1"); shift ;;
    esac
done

# Clone or update upstream
if [[ "$REFRESH" == true ]] && [[ -d "$CLONE_DIR" ]]; then
    rm -rf "$CLONE_DIR"
fi

if [[ ! -d "$CLONE_DIR" ]]; then
    echo "Cloning upstream (shallow)..."
    mkdir -p "$(dirname "$CLONE_DIR")"
    git clone --depth=1 "$UPSTREAM_URL" "$CLONE_DIR" 2>&1 | tail -1
    echo ""
else
    echo "Updating upstream..."
    git -C "$CLONE_DIR" fetch --depth=1 origin main 2>&1 | tail -1
    git -C "$CLONE_DIR" reset --hard origin/main --quiet
    echo ""
fi

# If no cohorts specified, do all
if [[ ${#COHORTS[@]} -eq 0 ]]; then
    COHORTS=("${!COHORT_MAP[@]}")
fi

# Sort cohorts for consistent output
IFS=$'\n' COHORTS=($(sort <<<"${COHORTS[*]}")); unset IFS

total_identical=0
total_modified=0
total_local_only=0
total_upstream_only=0

for cohort_key in "${COHORTS[@]}"; do
    upstream_dir="${COHORT_MAP[$cohort_key]:-}"
    if [[ -z "$upstream_dir" ]]; then
        echo "Unknown cohort key: $cohort_key"
        echo "Available: ${!COHORT_MAP[*]}"
        exit 1
    fi

    local_dir="$LOCAL_SPECS/$cohort_key"
    remote_dir="$UPSTREAM_INGEST/$upstream_dir"

    if [[ ! -d "$local_dir" ]]; then
        echo "WARNING: Local dir not found: $local_dir"
        continue
    fi
    if [[ ! -d "$remote_dir" ]]; then
        echo "WARNING: Upstream dir not found: $remote_dir"
        continue
    fi

    identical=0
    modified=0
    local_only=0
    upstream_only=0
    modified_files=()

    # Check local files against upstream
    for local_file in "$local_dir"/*.yaml; do
        [[ -f "$local_file" ]] || continue
        filename="$(basename "$local_file")"
        remote_file="$remote_dir/$filename"

        if [[ ! -f "$remote_file" ]]; then
            local_only=$((local_only + 1))
            if [[ "$FULL_DIFF" == true ]]; then
                echo "  LOCAL ONLY: $filename"
            fi
        elif diff -q "$local_file" "$remote_file" >/dev/null 2>&1; then
            identical=$((identical + 1))
        else
            modified=$((modified + 1))
            modified_files+=("$filename")
            if [[ "$FULL_DIFF" == true ]]; then
                echo "--- $cohort_key/$filename"
                diff -u "$remote_file" "$local_file" --label "upstream/$upstream_dir/$filename" --label "local/$cohort_key/$filename" || true
                echo ""
            fi
        fi
    done

    # Check upstream files not in local
    for remote_file in "$remote_dir"/*.yaml; do
        [[ -f "$remote_file" ]] || continue
        filename="$(basename "$remote_file")"
        if [[ ! -f "$local_dir/$filename" ]]; then
            upstream_only=$((upstream_only + 1))
            if [[ "$FULL_DIFF" == true ]]; then
                echo "  UPSTREAM ONLY: $filename"
            fi
        fi
    done

    total_identical=$((total_identical + identical))
    total_modified=$((total_modified + modified))
    total_local_only=$((total_local_only + local_only))
    total_upstream_only=$((total_upstream_only + upstream_only))

    echo "$cohort_key → $upstream_dir"
    echo "  identical: $identical  modified: $modified  local-only: $local_only  upstream-only: $upstream_only"
    if [[ $modified -gt 0 ]] && [[ "$FULL_DIFF" == false ]]; then
        echo "  modified: ${modified_files[*]}"
    fi
    echo ""
done

echo "=== TOTAL ==="
echo "  identical: $total_identical  modified: $total_modified  local-only: $total_local_only  upstream-only: $total_upstream_only"
