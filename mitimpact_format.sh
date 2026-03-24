#!/bin/bash


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_mitimpact_file>"
    echo "Example: bash $0 mitimpact2.txt > hg38_MitImpact313.txt"
    exit 1
fi

INPUT_FILE=$1


if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found."
    exit 1
fi


awk 'BEGIN {FS="\t"; OFS="\t"} 
{
    if (NR == 1) {

        printf "#Chr\tStart\tEnd"
        for(i=5; i<=NF; i++) printf "\t%s", $i
        printf "\n"
    } else {

        printf "%s\t%s\t%s", $3, $4, $4
        for(i=5; i<=NF; i++) printf "\t%s", $i
        printf "\n"
    }
}' "$INPUT_FILE"
