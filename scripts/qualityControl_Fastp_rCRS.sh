#!/bin/bash
set -e  # Exit script if any command fails

filename2="$1/Software/file_log/file_log.txt"

##Fastp
if [ -d "$1/Results/Fastp/" ]
then
    echo "Directory $1/Results/Fastp/ exists."
else
    echo "Directory $1/Results/Fastp/ does not exists, Creating Directory..."
    mkdir $1/Results/Fastp/
fi

while read p; do
    counter=$((counter+1))
    filename=$(basename -- "$p")
    extension="${filename##*.}"
    filename="${filename%%.*}"
    filename1="${filename%_*}"
    
    
    for file1 in $p; do
        if [ -d "$1/Results/Fastp/${filename1}" ]
        then
            echo "Directory $1/Results/Fastp/${filename1} exists."
        else
            echo "Directory $1/Results/Fastp/ does not exists, Creating Directory..."
            mkdir $1/Results/Fastp/${filename1}
        fi
        file2=${file1/_1/_2}
        
        echo $file1 $file2
        cd $1/Results/Fastp/${filename1}
        fastp -i ${file1} -I ${file2} -o ${filename1}_1.fastq.gz -O ${filename1}_2.fastq.gz -w ${2}  --verbose --html ${filename1}.html --json ${filename1}.json
        
    done
    
done < ${filename2}

# ✅ Add MultiQC step for Fastp results
    if [ -d "$1/Results/MultiQC/" ]; then
        echo "Directory $1/Results/MultiQC/ exists."
    else
        echo "Directory $1/Results/MultiQC/ does not exists, Creating Directory..."
        mkdir -p "$1/Results/MultiQC/"
    fi

    multiqc "$1/Results/Fastp/" -f -o "$1/Results/MultiQC/"