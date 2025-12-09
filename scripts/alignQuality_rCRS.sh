#!/bin/bash
set -e

base_dir=$1
threads=$2
bam_subfolder=$3  # Either Main_analysis_pipeline_output/Align or Sort_rCRS

input_path="$base_dir/Results/$bam_subfolder"
output_dir="$base_dir/Results/AlignmentQuality"
multi_sample_path_log="$output_dir/multi_sample_input.txt"


echo $bam_subfolder

# Ensure output directories exist
mkdir -p "$output_dir"

# Remove existing multi-sample file if present
[ -f "$multi_sample_path_log" ] && rm "$multi_sample_path_log"

# Run per-sample BAM QC
for i in "$input_path"/*.bam; do
    filename=$(basename -- "$i" .bam)
    qualimap bamqc -bam "$i" -nt "$threads" -outdir "$output_dir/$filename" -outformat html
    echo "$filename   $output_dir/$filename" >> "$multi_sample_path_log"
done

# Run multi-sample QC if more than one sample
mkdir -p "$base_dir/Results/MultiSample_QC"
if [ "$(wc -l < "$multi_sample_path_log")" -gt 1 ]; then
    qualimap multi-bamqc -d "$multi_sample_path_log" -outdir "$base_dir/Results/MultiSample_QC" -outformat html
else
    echo "Only one sample found; skipping multi-sample QC."
fi
