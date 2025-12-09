#!/bin/bash
set -e  # Exit script if any command fails

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
