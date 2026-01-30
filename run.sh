#!/bin/bash

# Initialize conda (Docker or local)
if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
    . /opt/conda/etc/profile.d/conda.sh
    conda activate mitogex
elif command -v conda >/dev/null 2>&1; then
    . "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate mitogex
fi

# Detect Docker vs non-Docker
if [ -f /.dockerenv ]; then
    MITOGEX_DIR="/opt/mitogex"
    # Fix runtime dir ownership (Qt)
    RUNTIME_DIR="/tmp/runtime-$(id -u)"
    mkdir -p "$RUNTIME_DIR"
    chmod 700 "$RUNTIME_DIR"
    export XDG_RUNTIME_DIR="$RUNTIME_DIR"
else
    MITOGEX_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Ensure file_log exists (required by GUI)
mkdir -p "$MITOGEX_DIR/Software/file_log"
touch "$MITOGEX_DIR/Software/file_log/all_file_log.txt"

java --module-path "$MITOGEX_DIR/lib" --add-modules javafx.web,javafx.controls,javafx.fxml,javafx.graphics,javafx.base,javafx.swing -jar "$MITOGEX_DIR/MitoGEx-1.0.jar"
