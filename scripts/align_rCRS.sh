#!/bin/bash
set -e  # Exit script if any command fails


# Arguments
# $1 = new_workingDir
# $2 = thread count
# $3 = inputDir (used when Fastp not selected)

# Directories
fastp_dir="$1/Results/Fastp"
sam_dir="$1/Results/SAM_rCRS"
bam_dir="$1/Results/BAM_rCRS"
hg38_ref="$1/Software/References/hg38/Homo_sapiens_assembly38.fasta"

mkdir -p "$sam_dir"
mkdir -p "$bam_dir"

# Check if Fastp directory has processed files (.fastq.gz or .fastq)
if compgen -G "$fastp_dir/*/*_1.fastq.gz" > /dev/null || compgen -G "$fastp_dir/*/*_1.fastq" > /dev/null; then
    echo "[INFO] Using Fastp processed files..."
    input_pattern="$fastp_dir/*/*_1.fastq.gz $fastp_dir/*/*_1.fastq"
else
    echo "[INFO] Using original FASTQ files from: $3"
    input_pattern="$3/*_1.fastq.gz $3/*_1.fastq"
fi

# Loop through R1 files
for i in $input_pattern; do
    filename=$(basename -- "$i")
    filename1="${filename%%_*}"      # Extract sample name
    file2=${i/_1.fastq.gz/_2.fastq.gz}

    if [[ ! -f "$file2" ]]; then
        echo "[WARNING] Missing R2 pair for: $i — skipping."
        continue
    fi

    echo "[INFO] Processing sample: $filename1"

    # Run BWA MEM
    bwa mem -t "$2" -T $4 -M -P "$hg38_ref" "$i" "$file2" > "$sam_dir/${filename1}.sam"

    # Convert SAM to BAM
    samtools view -@${2} -bS "$sam_dir/${filename1}.sam" > "$bam_dir/${filename1}.bam"

# Cleanup SAM
    rm "$sam_dir/${filename1}.sam"


done