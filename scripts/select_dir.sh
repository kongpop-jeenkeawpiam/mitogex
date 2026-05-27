#!/bin/bash
set -euo pipefail

ROOT="${1:?Usage: select_dir.sh <mitogex-root> <threads> <input-dir>}"
INPUT_DIR="${3:?Usage: select_dir.sh <mitogex-root> <threads> <input-dir>}"

# Check if the directory exists, and if not, create it
if [ ! -d "$ROOT/Software/file_log" ]; then
  mkdir -p "$ROOT/Software/file_log"
  echo "Directory $ROOT/Software/file_log created."
fi

# Check and remove log files only if they exist
if [ -f "$ROOT/Software/file_log/file_log.txt" ]; then
  rm -f "$ROOT/Software/file_log/file_log.txt"
fi

if [ -f "$ROOT/Software/file_log/all_file_log.txt" ]; then
  rm -f "$ROOT/Software/file_log/all_file_log.txt"
fi

if [ -f "$ROOT/Software/file_log/file_log_R1.txt" ]; then
  rm -f "$ROOT/Software/file_log/file_log_R1.txt"
fi

if [ -f "$ROOT/Software/file_log/file_log_R2.txt" ]; then
  rm -f "$ROOT/Software/file_log/file_log_R2.txt"
fi


for file1 in "$INPUT_DIR"/*; do
  # Check if it's a regular file (not a directory or special file)
  if [[ -f "$file1" ]]; then
    # Check if the file ends with .gz, .fastq, or .bam
    if [[ "$file1" == *.gz ]] || [[ "$file1" == *.fastq ]] || [[ "$file1" == *.bam ]]; then
      # Log the file to all_file_log.txt
      echo "$file1" >> "$ROOT/Software/file_log/all_file_log.txt"
    else
      echo "Not a valid file type: $file1"
    fi
  fi
done

for file2 in "$INPUT_DIR"/*_1*.gz "$INPUT_DIR"/*_1*.fastq; do
  if [[ -f "$file2" ]]; then
    echo "$file2" >> "$ROOT/Software/file_log/file_log.txt"
  fi
done

for file3 in "$INPUT_DIR"/*_1*.gz "$INPUT_DIR"/*_1*.fastq; do
  if [[ -f "$file3" ]]; then
    echo "$file3" >> "$ROOT/Software/file_log/file_log_R1.txt"
  fi
done

for file4 in "$INPUT_DIR"/*_2*.gz "$INPUT_DIR"/*_2*.fastq; do
  if [[ -f "$file4" ]]; then
    echo "$file4" >> "$ROOT/Software/file_log/file_log_R2.txt"
  fi
done
