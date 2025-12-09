#!/bin/bash
set -e  # Exit script if any command fails

echo "Starting the pipeline..."

filename="$1/Software/file_log/all_file_log.txt"
filename2="$1/Software/file_log/file_log.txt"
file_long="$1/Software/file_log/file_long.txt"
qc_fol=$1/Results/FastQC
rCRS_ref=$1/Software/References/rCRS/rCRS.fasta
hg38_ref=$1/Software/References/hg38/Homo_sapiens_assembly38.fasta
dbSNP_ref=$1/Software/References/dbSNP_b156/GCF_000001405.40.gz
fasta_check=$1/Software/fasta/
project_title=${3}
qc_tool=${4}
files_dir=${5}
echo "Project name : ${project_title}"
echo "`date`"

mkdir -p $1/Results/

echo "Selected QC tool: $qc_tool"

# FastQC

if [ "$qc_tool" == "fastqc" ]; then
    echo "Running FastQC..."
    mkdir -p "$qc_fol"

    # Iterate through .fastq and .fastq.gz files in the selected input directory
    for p in "$files_dir"/*.fastq "$files_dir"/*.fastq.gz; do
        if [ -f "$p" ]; then
            filename=$(basename -- "$p")
            filename1="${filename%%_*}"
            mkdir -p "$qc_fol/${filename1}"
            fastqc -t ${2} "$p" --outdir="$qc_fol/${filename1}"
        fi
    done

    # MultiQC step for FastQC
    mkdir -p "$1/Results/MultiQC/"
    multiqc "$qc_fol" -f -o "$1/Results/MultiQC/"
fi


##Fastp
if [ ! -f "$filename2" ]; then
    echo "Error: Input file list $filename2 not found."
    exit 1
fi
if [ "$qc_tool" == "fastp" ]; then
    echo "Running Fastp..."
    mkdir -p "$1/Results/Fastp/"

    while read p; do
        counter=$((counter+1))
        filename=$(basename -- "$p")
        filename1="${filename%%_*}"

        mkdir -p "$1/Results/Fastp/${filename1}"
        file2="${p/_1/_2}"
        
        echo "$p $file2"
        cd "$1/Results/Fastp/${filename1}"
        fastp -i "$p" -I "$file2" -o "${filename1}_1.fastq.gz" -O "${filename1}_2.fastq.gz" \
              -w "${2}" --verbose --html "${filename1}.html" --json "${filename1}.json"

    done < "${filename2}"

    # ✅ Add MultiQC step for Fastp results
    if [ -d "$1/Results/MultiQC/" ]; then
        echo "Directory $1/Results/MultiQC/ exists."
    else
        echo "Directory $1/Results/MultiQC/ does not exists, Creating Directory..."
        mkdir -p "$1/Results/MultiQC/"
    fi

    multiqc "$1/Results/Fastp/" -f -o "$1/Results/MultiQC/"
fi




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
if [ "$qc_tool" == "fastp" ]; then
    input_loop_path="$1/Results/Fastp/*/*_1.fastq.gz"
else
    input_loop_path="${files_dir}/*_1.fastq.gz ${files_dir}/*_1.fq.gz"
fi
for i in $input_loop_path; do
    filename=$(basename -- "$i")
    filename1="${filename%%_*}"    # Extract the base name
    file2=${i//_1/_2}              # Replace _1 with _2 for the pair

    # Perform alignment
    bwa mem -t ${2} -M -P ${hg38_ref} $i $file2 > $1/Results/SAM_rCRS/${filename1}.sam

    # Convert SAM to BAM
    samtools view -@${2} -bS $1/Results/SAM_rCRS/${filename1}.sam > $1/Results/BAM_rCRS/${filename1}.bam

    # Remove SAM file after conversion
    rm $1/Results/SAM_rCRS/${filename1}.sam

    # Sort BAM and add read groups
    java -jar -Xmx8g $1/Software/picard/picard.jar AddOrReplaceReadGroups \
    I=$1/Results/BAM_rCRS/${filename1}.bam \
    O=$1/Results/Sort_rCRS/${filename1}.sort.bam \
    SORT_ORDER=coordinate \
    RGID=${project_title} \
    RGLB=lib-${filename1} \
    RGPL=illumina \
    RGPU=HiSeq \
    RGSM=${filename1} \
    TMP_DIR=$1/Results/Sort_rCRS/

    # Index the sorted BAM
    samtools index -@${2} $1/Results/Sort_rCRS/${filename1}.sort.bam

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


# Annotate Variants
for VCFFile in $1/Results/Main_analysis_pipeline_output/VCF/*.sort.final.split.vcf; do
filename=$(basename -- "$VCFFile" .sort.final.split.vcf)
if [ -d "$1/Results/ANNOVAR/" ]
then
    echo "Directory $1/Results/ANNOVAR/ exists."
else
    echo "Directory $1/Results/ANNOVAR/ does not exists, Creating Directory..."
    mkdir $1/Results/ANNOVAR/
fi
cd $1/Results/ANNOVAR
if [[ "$VCFFile" != *"index"* ]]; then
        # Your processing commands go here
        echo "Processing $VCFFile"
        perl $1/Software/annovar/convert2annovar.pl -format vcf4 ${VCFFile} > ${filename}.avinput
        perl $1/Software/annovar/table_annovar.pl ${filename}.avinput $1/Software/annovar/humandb -buildver hg38 -out ${filename} -remove -protocol MitImpact313 -operation f -nastring . -polish
        # Add the rest of your commands to process the file
    else
        echo "Skipping $VCFFile (contains 'index')"
    fi
done


# Alignment quality assessment
if [ -d "$1/Results/AlignmentQuality/" ]
then
    echo "Directory $1/Results/AlignmentQuality/ exists."
else
    echo "Directory $1/Results/AlignmentQuality/ does not exists, Creating Directory..."
    mkdir $1/Results/AlignmentQuality/
fi
multi_sample_path_log="$1/Results/AlignmentQuality/multi_sample_input.txt"

if [ -f "${multi_sample_path_log}" ]; then
    echo "File '${multi_sample_path_log}' exists."
    rm ${multi_sample_path_log}
else
    echo "Pass"
fi
for i in $1/Results/Main_analysis_pipeline_output/Align/*.sort.realigned.bam; do
# for i in $1/Results/Sort_rCRS/*.sort.bam; do
filename=$(basename -- "$i" .sort.realigned.bam)
qualimap bamqc -bam  ${i} -nt ${2} -outdir $1/Results/AlignmentQuality/${filename} -outformat html
echo "${filename}   $1/Results/AlignmentQuality/${filename}" >> ${multi_sample_path_log}
done

# Multi-sample BAM QC
if [ -d "$1/Results/MultiSample_QC/" ]
then
    echo "Directory $1/Results/MultiSample_QC/ exists."
else
    echo "Directory $1/Results/MultiSample_QC/ does not exists, Creating Directory..."
    mkdir $1/Results/MultiSample_QC/
fi

# Check the number of samples in the file before running multi-bamqc
num_samples=$(wc -l < "${multi_sample_path_log}")
if [ "$num_samples" -gt 1 ]; then
qualimap multi-bamqc -d ${multi_sample_path_log} -outdir $1/Results/MultiSample_QC/ -outformat html
else
    echo "Only one sample found in ${multi_sample_path_log}, skipping multi-sample BAM QC."
fi

#Haplogroup Classification
if [ -d "$1/Results/Haplogroup/" ]
then
    echo "Directory $1/Results/Haplogroup/ exists."
else
    echo "Directory $1/Results/Haplogroup/ does not exists, Creating Directory..."
    mkdir $1/Results/Haplogroup/
fi
for VCFFile in $1/Results/Main_analysis_pipeline_output/VCF/*.sort.final.split.vcf; do
filename=$(basename -- "$VCFFile" .sort.final.split.vcf)
if [[ "$VCFFile" != *"index"* ]]; then
        # Your processing commands go here
        echo "Haplogroup processing $VCFFile"
        cd $1/Results/Haplogroup/
        $1/Software/haplogrep3/haplogrep3 classify --tree=phylotree-fu-rcrs@1.2 --input=${VCFFile} --output=$1/Results/Haplogroup/${filename}.txt --write-fasta --write-qc
    else
        echo "Skipping $VCFFile (contains 'index')"
    fi
done

cd $1

if [ -d "$1/Results/Phylogenetic/" ]
then
    echo "Directory $1/Results/Phylogenetic/ exists."
else
    echo "Directory $1/Results/Phylogenetic/ does not exists, Creating Directory..."
    mkdir $1/Results/Phylogenetic/
fi
# Safely count the number of FASTA files in Haplogroup directory
num_fasta_files=$(find "$1/Results/Haplogroup/" -maxdepth 1 -type f -name "*.fasta" | wc -l)

if [ "$num_fasta_files" -lt 3 ]; then
    echo "Error: At least 3 FASTA files are required for phylogenetic analysis, but only $num_fasta_files were found."
    echo "Visualizing..."
    exit 0  # Exit normally without running IQ-TREE
else
    # Concatenate all .fasta files into one file
    cat "$1/Results/Haplogroup/"*.fasta > "$1/Results/Phylogenetic/${project_title}.fasta"

    # Run IQ-TREE2 for phylogenetic analysis
    iqtree2 -s "$1/Results/Phylogenetic/${project_title}.fasta" -m MFP -B 1000 -T AUTO

    # Define the contree path
    contree_path="$1/Results/Phylogenetic/${project_title}.fasta.contree"

    # Check if the tree file was generated before proceeding
    if [ -f "$contree_path" ]; then
        chmod 777 "$contree_path"

        # Find Conda base path and activate the environment
        CONDA_PATH=$(conda info --base)
        if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
            source "$CONDA_PATH/etc/profile.d/conda.sh"
        else
            echo "Conda not found!"
            exit 0  # Exit normally if Conda is missing
        fi

        # Activate Conda environment
        conda activate mitogex_ete

        # Run Python script for tree analysis
        python "$1/Software/scripts/python/tree.py" "$1" "$contree_path"

        # Generate tree.html for each contree file
        for FILE in "$1/Results/Phylogenetic/"*.fasta.contree; do
            BASENAME=$(basename "$FILE" .fasta.contree)
            bash "$1/Software/scripts/Web/web_tree.sh" "$1" "$BASENAME" "$FILE" > "$1/Results/Phylogenetic/tree.html"
        done
    else
        echo "Error: IQ-TREE output file ($contree_path) not found. Skipping further steps."
        exit 0  # Exit normally without running Conda-based steps
    fi
fi



if [ -d "$1/Results/Web/" ]
then
    echo "Directory $1/Results/Web/ exists."
else
    echo "Directory $1/Results/Web/ does not exists, Creating Directory..."
    mkdir $1/Results/Web/
fi
bash $1/Software/scripts/Web/web_index.sh "${1}" > $1/Results/Web/index.html

# Generate sample.html for each BASENAME in the loop
for FILE in "$1/Results/ANNOVAR"/*.hg38_multianno.txt; do
    BASENAME=$(basename "$FILE" .hg38_multianno.txt)
    bash $1/Software/scripts/Web/web_sample.sh "${1}" "${BASENAME}" > "$1/Results/Web/sample_${BASENAME}.html"
    # bash $1/Software/scripts/Web/web_variants.sh "${1}" "${BASENAME}" > "$1/Results/ANNOVAR/variants_${BASENAME}.html"
    bash $1/Software/scripts/Web/web_variants.sh "${1}" "${BASENAME}" > "$1/Results/Web/variants_${BASENAME}.html"
done


    
#  bash $1/Software/scripts/Web/web_haplogroup.sh "${1}" > "$1/Results/Haplogroup/haplogroup.html"
 bash $1/Software/scripts/Web/web_haplogroup.sh "${1}" > "$1/Results/Web/haplogroup.html"





