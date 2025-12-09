#!/bin/bash
set -e

# Arguments
# $1 = working directory
# $2 = number of threads
# $3 = memory (e.g., -Xmx8g)
# $4 = project title
# $5 = input BAM path (used if provided)

bam_input="$5"

# Fall back to default path if empty
if [ -z "$bam_input" ]; then
    bam_input="$1/Results/BAM_rCRS"
fi

echo "Using BAM input directory: $bam_input"

mkdir -p "$1/Results/Sort_rCRS"

for i in "$bam_input"/*.bam; do
    filename=$(basename "$i" .bam)

    java -jar $3 "$1/Software/picard/picard.jar" AddOrReplaceReadGroups \
        I="$i" \
        O="$1/Results/Sort_rCRS/${filename}.sort.bam" \
        SORT_ORDER=coordinate \
        RGID="$4" \
        RGLB="lib-${filename}" \
        RGPL=illumina \
        RGPU=HiSeq \
        RGSM="${filename}" \
        TMP_DIR="$1/Results/Sort_rCRS/"

    samtools index -@"$2" "$1/Results/Sort_rCRS/${filename}.sort.bam"
done
