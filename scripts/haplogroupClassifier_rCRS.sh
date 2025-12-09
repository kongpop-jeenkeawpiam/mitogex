#!/bin/bash
set -e  # Exit script if any command fails

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

#bash $1/Software/scripts/Web/web_haplogroup.sh "${1}" > "$1/Results/Haplogroup/haplogroup.html"
bash $1/Software/scripts/Web/web_haplogroup.sh "${1}" > "$1/Results/Web/haplogroup.html"
