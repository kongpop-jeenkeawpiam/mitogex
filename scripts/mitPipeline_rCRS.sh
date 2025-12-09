#!/bin/bash
set -e  # Exit script if any command fails

# Define necessary directories and constants for the pipeline
INPUT_DIR="${1}/Results/Sort_rCRS"
OUTPUT_JSON_DIR="$1/Software/file_log/json"
TEMPLATE_JSON="template.json"

# Check if OUTPUT_JSON_DIR exists
if [ -d "$OUTPUT_JSON_DIR" ]; then
    # If the directory exists, remove its contents
    echo "Directory $OUTPUT_JSON_DIR exists. Removing old files..."
    rm -r ${OUTPUT_JSON_DIR}/
else
    echo "Directory $OUTPUT_JSON_DIR does not exist. Skipping removal of old files."
fi

# Ensure output directory exists and create it if necessary
mkdir -p "$OUTPUT_JSON_DIR"

GATK_PATH="${1}/Software/gatk/gatk"
GATK_LOCAL_PATH="${1}/Software/gatk/gatk-package-4.6.0.0-local.jar"
PICARD_PATH="${1}/Software/picard/picard.jar"
HAPLOCHECK_PATH="${1}/Software/mtdnaserver/haplocheckCLI.jar"
REF_FASTA="${1}/Software/References/hg38/Homo_sapiens_assembly38.fasta"
REF_DICT="${1}/Software/References/hg38/Homo_sapiens_assembly38.dict"
REF_FASTA_INDEX="${1}/Software/References/hg38/Homo_sapiens_assembly38.fasta.fai"
MT_DICT="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.dict"
MT_FASTA="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta"
MT_FASTA_INDEX="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.fai"
MT_AMB="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.amb"
MT_ANN="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.ann"
MT_BWT="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.bwt"
MT_PAC="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.pac"
MT_SA="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.fasta.sa"
BLACKLISTED_SITES="${1}/Software/References/chrM/blacklist_sites.hg38.chrM.bed"
BLACKLISTED_SITES_INDEX="${1}/Software/References/chrM/blacklist_sites.hg38.chrM.bed.idx"
MT_SHIFTED_DICT="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.dict"
MT_SHIFTED_FASTA="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta"
MT_SHIFTED_FASTA_INDEX="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.fai"
MT_SHIFTED_AMB="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.amb"
MT_SHIFTED_ANN="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.ann"
MT_SHIFTED_BWT="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.bwt"
MT_SHIFTED_PAC="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.pac"
MT_SHIFTED_SA="${1}/Software/References/chrM/Homo_sapiens_assembly38.chrM.shifted_by_8000_bases.fasta.sa"
SHIFT_BACK_CHAIN="${1}/Software/References/chrM/ShiftBack.chain"
CONTROL_REGION_SHIFTED_REFERENCE_INTERVAL_LIST="${1}/Software/References/chrM/control_region_shifted.chrM.interval_list"
NON_CONTROL_REGION_INTERVAL_LIST="${1}/Software/References/chrM/non_control_region.chrM.interval_list"

# Ensure directories for BAM/CRAM and SAM/BAM processing exist
mkdir -p $1/Results/SAM_rCRS/
mkdir -p $1/Results/BAM_rCRS/
mkdir -p $1/Results/Sort_rCRS/

# Loop through Fastp FASTQ files and process them in one step
for i in $1/Results/BAM_rCRS/*.bam; do
    filename=$(basename "$i" .bam)
    filename1="${filename%%_*}"    # Extract the base name

    # Create JSON configuration for the pipeline
    bam_file="$1/Results/Sort_rCRS/${filename1}.sort.bam"
    bam_index="${bam_file}.bai"
    output_json="${OUTPUT_JSON_DIR}/${filename1}_inputs.json"

    # Create the JSON file with appropriate content
    cat <<EOF > "$output_json"
{
  "MitochondriaPipeline.gatk_path": "$GATK_PATH",
  "MitochondriaPipeline.gatk_local_path": "$GATK_LOCAL_PATH",
  "MitochondriaPipeline.AlignAndCall.picard_path": "$PICARD_PATH",
  "MitochondriaPipeline.picard_path": "$PICARD_PATH",
  "MitochondriaPipeline.haplocheck_path": "$HAPLOCHECK_PATH",
  "MitochondriaPipeline.wgs_aligned_input_bam_or_cram": "$bam_file",
  "MitochondriaPipeline.wgs_aligned_input_bam_or_cram_index": "$bam_index",
  "MitochondriaPipeline.ref_fasta": "$REF_FASTA",
  "MitochondriaPipeline.ref_dict": "$REF_DICT",
  "MitochondriaPipeline.ref_fasta_index": "$REF_FASTA_INDEX",
  "MitochondriaPipeline.mt_dict": "$MT_DICT",
  "MitochondriaPipeline.mt_fasta": "$MT_FASTA",
  "MitochondriaPipeline.mt_fasta_index": "$MT_FASTA_INDEX",
  "MitochondriaPipeline.mt_amb": "$MT_AMB",
  "MitochondriaPipeline.mt_ann": "$MT_ANN",
  "MitochondriaPipeline.mt_bwt": "$MT_BWT",
  "MitochondriaPipeline.mt_pac": "$MT_PAC",
  "MitochondriaPipeline.mt_sa": "$MT_SA",
  "MitochondriaPipeline.blacklisted_sites": "$BLACKLISTED_SITES",
  "MitochondriaPipeline.blacklisted_sites_index": "$BLACKLISTED_SITES_INDEX",
  "MitochondriaPipeline.mt_shifted_dict": "$MT_SHIFTED_DICT",
  "MitochondriaPipeline.mt_shifted_fasta": "$MT_SHIFTED_FASTA",
  "MitochondriaPipeline.mt_shifted_fasta_index": "$MT_SHIFTED_FASTA_INDEX",
  "MitochondriaPipeline.mt_shifted_amb": "$MT_SHIFTED_AMB",
  "MitochondriaPipeline.mt_shifted_ann": "$MT_SHIFTED_ANN",
  "MitochondriaPipeline.mt_shifted_bwt": "$MT_SHIFTED_BWT",
  "MitochondriaPipeline.mt_shifted_pac": "$MT_SHIFTED_PAC",
  "MitochondriaPipeline.mt_shifted_sa": "$MT_SHIFTED_SA",
  "MitochondriaPipeline.shift_back_chain": "$SHIFT_BACK_CHAIN",
  "MitochondriaPipeline.control_region_shifted_reference_interval_list": "$CONTROL_REGION_SHIFTED_REFERENCE_INTERVAL_LIST",
  "MitochondriaPipeline.non_control_region_interval_list": "$NON_CONTROL_REGION_INTERVAL_LIST"
}
EOF

    echo "Created JSON file: $output_json"
done

# Check if files exist in $1/Results/SAM_rCRS directory and remove them
if [ "$(ls -A $1/Results/SAM_rCRS)" ]; then
  echo "Removing files in $1/Results/SAM_rCRS"
  rm -r $1/Results/SAM_rCRS
else
  echo "No files to remove in $1/Results/SAM_rCRS"
fi



echo "All JSON files generated."

# Mitochondrial Analysis Pipeline with Cromwell
for jsonFile in $1/Software/file_log/json/*.json; do
    if [ ! -d "$1/Results/JSON_output/" ]; then
        echo "Directory $1/Results/JSON_output/ does not exist, Creating Directory..."
        mkdir -p "$1/Results/JSON_output/"
    fi

    cd $1/Results/
    filename=$(basename -- "$jsonFile" _inputs.json)
    java -jar ${1}/Software/cromwell-87.jar run ${1}/Software/scripts/WDL/MitochondriaPipeline.wdl --inputs ${jsonFile} -m $1/Results/JSON_output/${filename}_output.json

    # Define the output directories and create them if they don't exist
    output_dirs=("Main_analysis_pipeline_output/Align" 
                 "Main_analysis_pipeline_output/Sort" 
                 "Main_analysis_pipeline_output/Statistics" 
                 "Main_analysis_pipeline_output/VCF" 
                 "Main_analysis_pipeline_output/Haplogroup_check")

    for dir in "${output_dirs[@]}"; do
        if [ ! -d "$1/Results/$dir" ]; then
            echo "Directory $1/Results/$dir does not exist, Creating Directory..."
            mkdir -p "$1/Results/$dir"
        fi
    done

    # Parse the output JSON and move files if they exist
    json_output="$1/Results/JSON_output/${filename}_output.json"
    declare -A paths=(
        ["MitochondriaPipeline.mt_aligned_bai"]="Main_analysis_pipeline_output/Align"
        ["MitochondriaPipeline.subset_bai"]="Main_analysis_pipeline_output/Sort"
        ["MitochondriaPipeline.base_level_coverage_metrics"]="Main_analysis_pipeline_output/Statistics/${filename}_per_base_coverage.tsv"
        ["MitochondriaPipeline.subset_bam"]="Main_analysis_pipeline_output/Sort"
        ["MitochondriaPipeline.theoretical_sensitivity_metrics"]="Main_analysis_pipeline_output/Statistics/${filename}_theoretical_sensitivity.txt"
        ["MitochondriaPipeline.coverage_metrics"]="Main_analysis_pipeline_output/Statistics/${filename}_metrics.txt"
        ["MitochondriaPipeline.split_vcf"]="Main_analysis_pipeline_output/VCF/${filename}.sort.final.split.vcf"
        ["MitochondriaPipeline.split_vcf_index"]="Main_analysis_pipeline_output/VCF/${filename}.index.sort.final.split.vcf"
        ["MitochondriaPipeline.duplicate_metrics"]="Main_analysis_pipeline_output/Statistics"
        ["MitochondriaPipeline.input_vcf_for_haplochecker"]="Main_analysis_pipeline_output/Haplogroup_check/${filename}_splitAndPassOnly.vcf"
        ["MitochondriaPipeline.mt_aligned_bam"]="Main_analysis_pipeline_output/Align"
        ["MitochondriaPipeline.out_vcf_index"]="Main_analysis_pipeline_output/Sort"
        ["MitochondriaPipeline.out_vcf"]="Main_analysis_pipeline_output/Sort"
        ["MitochondriaPipeline.contamination_metrics"]="Main_analysis_pipeline_output/Statistics/${filename}.contamination_metrics.txt"
    )

    for key in "${!paths[@]}"; do
        file_path=$(jq -r ".outputs[\"$key\"] // empty" "$json_output")
        dest_dir="${paths[$key]}"

        if [[ -n "$file_path" && -f "$file_path" ]]; then
            cp "$file_path" "$1/Results/$dest_dir"
            echo "Moved $file_path to $1/Results/$dest_dir"
        else
            echo "Key '$key' not found in the JSON or the file does not exist."
        fi
    done

 # Cleanup cromwell directories after processing each JSON file
    echo "Cleaning up cromwell directories..."
    rm -r $1/Results/cromwell-executions/
    rm -r $1/Results/cromwell-workflow-logs/
    echo "Cleanup complete."

done