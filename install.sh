#!/bin/bash -l
LOGFILE="install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "==== MitoGEx Installation Started $(date) ===="

APT_PACKAGES=(
    "default-jre" "default-jdk" "build-essential" "jq" "iqtree" "r-base-core" "curl"
    "libfontconfig1-dev" "libharfbuzz-dev" "libfribidi-dev" "libfreetype6-dev"
    "libpng-dev" "libtiff-dev" "libtiff5-dev" "libjpeg-dev" "zlib1g-dev" "libxml2-dev" 
    "libcurl4-openssl-dev" "libssl-dev" "libgl1-mesa-glx" "libglx-mesa0" 
    "libgl1-mesa-dri" "mesa-utils"
)

MISSING_PKGS=()
echo "Checking system dependencies..."
for pkg in "${APT_PACKAGES[@]}"; do
    # ตรวจสอบว่าลงไว้หรือยัง (ส่ง output ไป /dev/null เพื่อความสะอาด)
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

YQ_MISSING=false
if ! command -v yq &> /dev/null; then
    YQ_MISSING=true
fi

if [ ${#MISSING_PKGS[@]} -eq 0 ] && [ "$YQ_MISSING" = false ]; then
    echo "[OK] All system dependencies are already installed. No sudo needed."
else
    echo "--------------------------------------------------------"
    echo "The following system packages are MISSING:"
    [ ${#MISSING_PKGS[@]} -gt 0 ] && printf "  - %s\n" "${MISSING_PKGS[@]}"
    [ "$YQ_MISSING" = true ] && echo "  - yq (via snap)"
    echo "--------------------------------------------------------"
    echo "Note: Installation of these packages requires 'sudo' privileges."
    read -p "Do you want to proceed with 'sudo apt-get install'? (y/n): " run_sudo

    if [[ "$run_sudo" =~ ^[Yy]$ ]]; then
        echo "Updating repositories..."
        sudo apt-get update
        if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
            echo "Installing missing apt packages..."
            sudo apt-get install -y "${MISSING_PKGS[@]}"
        fi
        if [ "$YQ_MISSING" = true ]; then
            echo "Installing yq via snap..."
            sudo snap install yq
        fi
    else
        echo "[Skip] Skipping sudo-based installation. Some features might not work."
    fi
fi
#Conda environment
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create environments from YAML files
conda env create -f mitogex_ete.yml
conda env create -f mitogex.yml

conda init bash

conda activate mitogex_ete
ete3 build check
conda activate mitogex

#Install R packages
Rscript -e 'if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager", repos = "https://cloud.r-project.org")' 
Rscript -e 'install.packages("gsmoothr", repos="http://R-Forge.R-project.org")'
R --slave -e 'BiocManager::install(version = "3.19",ask=FALSE)'
R --slave -e 'BiocManager::install("Repitools",force=TRUE)' 

mitogex_dir=$(pwd)
mkdir ${mitogex_dir}/Software

#Install bwa-mem2
mkdir ${mitogex_dir}/Software/bwa-mem2
cd ${mitogex_dir}/Software/bwa-mem2
curl -L https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/bwa-mem2-2.2.1_x64-linux.tar.bz2 \
  | tar jxf -

cd bwa-mem2-2.2.1_x64-linux/
mv * ${mitogex_dir}/Software/bwa-mem2
cd ${mitogex_dir}/Software/bwa-mem2
rm -R bwa-mem2-2.2.1_x64-linux/

#Install GATK4.6
mkdir ${mitogex_dir}/Software/gatk
cd ${mitogex_dir}/Software/gatk
wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip
unzip gatk-4.6.0.0.zip && rm gatk-4.6.0.0.zip 
cd gatk-4.6.0.0/
mv * ${mitogex_dir}/Software/gatk
cd ${mitogex_dir}/Software/gatk
rm -R gatk-4.6.0.0/

#Install Picard
mkdir ${mitogex_dir}/Software/picard
cd ${mitogex_dir}/Software/picard
wget https://github.com/broadinstitute/picard/releases/download/3.2.0/picard.jar

#Install Haplogrep3
mkdir ${mitogex_dir}/Software/haplogrep3
cd ${mitogex_dir}/Software/haplogrep3
wget https://github.com/genepi/haplogrep3/releases/download/v3.2.1/haplogrep3-3.2.1-linux.zip
unzip haplogrep3-3.2.1-linux.zip && rm haplogrep3-3.2.1-linux.zip
${mitogex_dir}/Software/haplogrep3/haplogrep3 trees
chmod 777 ${mitogex_dir}/Software/haplogrep3/trees/phylotree-fu-rcrs/1.2/tree.yaml
#Install haplocheckCLI
mkdir ${mitogex_dir}/Software/mtdnaserver
cd ${mitogex_dir}/Software/mtdnaserver
wget https://github.com/leklab/haplocheckCLI/raw/master/haplocheckCLI.jar

#Install ANNOVAR
cd ${mitogex_dir}/Software/
wget http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz
tar -xvf annovar.latest.tar.gz && rm annovar.latest.tar.gz

#Install Cromwell for WDL
wget https://github.com/broadinstitute/cromwell/releases/download/87/cromwell-87.jar

##Download hg38 references
mkdir ${mitogex_dir}/Software/References/
wget https://mitogex.com/references/hg38.zip
unzip hg38.zip && rm hg38.zip
mv hg38/ ${mitogex_dir}/Software/References/
##Download rCRS
wget https://mitogex.com/references/chrM.zip
unzip chrM.zip && rm chrM.zip
mv chrM/ ${mitogex_dir}/Software/References/

#Download MitImpact Database
wget https://mitogex.com/database/annovar/hg38_MitImpact313.txt
mv hg38_MitImpact313.txt ${mitogex_dir}/Software/annovar/humandb/

#Download scripts
wget https://mitogex.com/scripts/scripts.zip
unzip scripts.zip && rm scripts.zip


cd ${mitogex_dir}
wget https://mitogex.com/lib.zip
unzip lib.zip && rm lib.zip
#Checking
bash -l ${mitogex_dir}/check.sh
