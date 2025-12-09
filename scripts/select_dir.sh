#!/bin/bash

now=$(date '+%d.%m.%Y.time.%H.%M.%S')
result_file=$1/Results/results.html
fasta_check=$1/Results/Fasta/


# Check if the directory exists, and if not, create it
if [ ! -d "$1/Software/file_log" ]; then
  mkdir -p $1/Software/file_log
  echo "Directory $1/Software/file_log created."
fi

# Check and remove log files only if they exist
if [ -f $1/Software/file_log/file_log.txt ]; then
  rm -r $1/Software/file_log/file_log.txt
fi

if [ -f $1/Software/file_log/all_file_log.txt ]; then
  rm -r $1/Software/file_log/all_file_log.txt
fi

if [ -f $1/Software/file_log/file_log_R1.txt ]; then
  rm -r $1/Software/file_log/file_log_R1.txt
fi

if [ -f $1/Software/file_log/file_log_R2.txt ]; then
  rm -r $1/Software/file_log/file_log_R2.txt
fi


for file1 in "$3"/*; do
  # Check if it's a regular file (not a directory or special file)
  if [[ -f "$file1" ]]; then
    # Check if the file ends with .gz, .fastq, or .bam
    if [[ "$file1" == *.gz ]] || [[ "$file1" == *.fastq ]] || [[ "$file1" == *.bam ]]; then
      # Log the file to all_file_log.txt
      echo "$file1" >> "$1/Software/file_log/all_file_log.txt"
    else
      echo "Not a valid file type: $file1"
    fi
  fi
done

for file2 in "$3"/*_1*.gz "$3"/*_1*.fastq; do
  if [[ -f "$file2" ]]; then
    echo "$file2" >> "$1/Software/file_log/file_log.txt"
  fi
done

for file3 in "$3"/*_1*.gz "$3"/*_1*.fastq; do
  if [[ -f "$file3" ]]; then
    echo "$file3" >> "$1/Software/file_log/file_log_R1.txt"
  fi
done

for file4 in "$3"/*_2*.gz "$3"/*_2*.fastq; do
  if [[ -f "$file4" ]]; then
    echo "$file4" >> "$1/Software/file_log/file_log_R2.txt"
  fi
done

