#!/bin/bash
set -e  # Exit script if any command fails

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



# Generate sample.html for each BASENAME in the loop
for FILE in "$1/Results/ANNOVAR"/*.hg38_multianno.txt; do
    BASENAME=$(basename "$FILE" .hg38_multianno.txt)
    bash $1/Software/scripts/Web/web_sample.sh "${1}" "${BASENAME}" > "$1/Results/Web/sample_${BASENAME}.html"
    bash $1/Software/scripts/Web/web_variants.sh "${1}" "${BASENAME}" > "$1/Results/Web/variants_${BASENAME}.html"
done
