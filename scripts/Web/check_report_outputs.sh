#!/bin/bash
set -euo pipefail

ROOT="${1:?Usage: check_report_outputs.sh <mitogex-root>}"
RESULTS_DIR="$ROOT/Results"
MISSING=0

require_file() {
    local path="$1"
    if [ ! -f "$path" ]; then
        echo "Missing report output: $path" >&2
        MISSING=1
    fi
}

require_glob() {
    local pattern="$1"
    if ! compgen -G "$pattern" >/dev/null; then
        echo "Missing report output matching: $pattern" >&2
        MISSING=1
    fi
}

require_file "$RESULTS_DIR/Web/index.html"
require_file "$RESULTS_DIR/Haplogroup/haplogroup.html"
require_file "$RESULTS_DIR/Phylogenetic/tree.html"
require_glob "$RESULTS_DIR/Web/sample_*.html"
require_glob "$RESULTS_DIR/ANNOVAR/variants_*.html"

if [ "$MISSING" -ne 0 ]; then
    exit 1
fi

echo "Report output smoke check passed."
