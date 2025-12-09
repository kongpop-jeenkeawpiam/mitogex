#!/bin/bash
set -e  # Exit script if any command fails

filename="$1/Software/file_log/all_file_log.txt"
filename2="$1/Software/file_log/file_log.txt"
file_long="$1/Software/file_log/file_long.txt"
qc_fol=$1/Results/FastQC
project_title=${3}
# FastQC
if [ -d "$1/Results/FastQC/" ]
        then
            echo "Directory $1/Results/FastQC/ exists."
        else
            echo "Directory $1/Results/FastQC/ does not exists, Creating Directory..."
            mkdir $1/Results/FastQC/
        fi
    while read p; do
        counter=$((counter+1))
        
        filename=$(basename -- "$p")
        extension="${filename##*.}"
        filename="${filename%%.*}"
        filename1="${filename%_*}"
        
        
        if [ -d "$1/Results/FastQC/${filename1}" ]
        then
            echo "Directory $1/Results/FastQC/${filename1} exists."
        else
            
            echo "Directory $1/Results/FastQC/${filename1} does not exists, Creating Directory..."
            mkdir $1/Results/FastQC/${filename1}
        fi
        
        fastqc -t ${2} $p --outdir=$1/Results/FastQC/${filename1}
        
        
    done < $filename
    
##Multiqc
if [ -d "$1/Results/MultiQC/" ]
then
    echo "Directory $1/Results/MultiQC/ exists."
    
else
    echo "Directory $1/Results/MultiQC/ does not exists, Creating Directory..."
    mkdir $1/Results/MultiQC/
fi

multiqc ${qc_fol} -f -o $1/Results/MultiQC