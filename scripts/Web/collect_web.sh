#!/bin/bash

mkdir -p $1/Results/Web_online

# Generate tree.html for each contree file
for FILE in "$1/Results/Phylogenetic/"*.fasta.contree; do
    BASENAME=$(basename "$FILE" .fasta.contree)
    bash "$1/Software/scripts/Web/web_tree.sh" "$1" "$BASENAME" "$FILE" > "$1/Results/Web_online/tree.html"
done


bash $1/Software/scripts/Web/web_index.sh "${1}" > $1/Results/Web_online/index.html

# Generate sample.html for each BASENAME in the loop
for FILE in "$1/Results/ANNOVAR"/*.hg38_multianno.txt; do
    BASENAME=$(basename "$FILE" .hg38_multianno.txt)
    bash $1/Software/scripts/Web/online/web_sample.sh "${1}" "${BASENAME}" > "$1/Results/Web_online/sample_${BASENAME}.html"
    # bash $1/Software/scripts/Web/web_variants.sh "${1}" "${BASENAME}" > "$1/Results/ANNOVAR/variants_${BASENAME}.html"
    bash $1/Software/scripts/Web/web_variants.sh "${1}" "${BASENAME}" > "$1/Results/Web_online/variants_${BASENAME}.html"
done



bash $1/Software/scripts/Web/web_haplogroup.sh "${1}" > "$1/Results/Web_online/haplogroup.html"

#MultiQC
cp ${1}/Results/MultiQC/multiqc_report.html $1/Results/Web_online/

#Multi Sample BAM
mkdir -p $1/Results/Web_online/MultiSample_QC
cp -r ${1}/Results/MultiSample_QC/* $1/Results/Web_online/MultiSample_QC

#FastQC
if [ -d "$1/Results/FastQC" ]; then
    for i in "$1/Results/FastQC"/*/*.html; do
        [ -f "$i" ] && cp "$i" "$1/Results/Web_online/"
    done
fi

#Fastp
if [ -d "$1/Results/Fastp" ]; then
    for i in "$1/Results/Fastp"/*/*.html; do
        [ -f "$i" ] && cp "$i" "$1/Results/Web_online/"
    done
fi

#Alignment Quality
cp -r "$1/Results/AlignmentQuality" "$1/Results/Web_online/"
