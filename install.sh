#!/bin/bash -l
LOGFILE="install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1
echo "==== MitoGEx Installation Started $(date) ===="
echo "Logging to: $LOGFILE"
sudo apt-get -y update
sudo apt install -y default-jre
sudo apt install -y default-jdk
sudo apt-get install -y build-essential
sudo apt-get install -y libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff-dev libtiff5-dev libjpeg-dev
sudo apt-get install -y zlib1g-dev libxml2-dev libcurl4-openssl-dev libssl-dev
sudo apt-get install -y jq
sudo apt-get install -y iqtree
sudo apt install -y libgl1-mesa-glx libglx-mesa0 libgl1-mesa-dri mesa-utils
sudo snap install yq
sudo apt install -y r-base-core
#Conda environment
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --add channels etetoolkit
conda config --set channel_priority strict
conda create -y --name mitogex_ete
conda create -y --name mitogex python=3.11
conda init bash
conda activate mitogex_ete
conda install -y -c etetoolkit ete3 ete_toolchain
conda install -y -c conda-forge libstdcxx-ng
conda install -n mitogex_ete -c etetoolkit slr
ete3 build check
conda activate mitogex

#Install with conda packages
conda install -y conda-forge::openjdk=21
conda install -y bioconda::fastqc
conda install -y bioconda::fastp
conda install -y bioconda::qualimap
conda install -y conda-forge::r-ragg
conda install -y bioconda::samtools
conda install -y bioconda::bwa
conda install -y -n mitogex -c conda-forge zlib libxml2 r-base r-xml2 r-haven r-rvest r-dtplyr r-tidyverse r-remotes
#conda install -y -n mitogex -c bioconda bioconductor-repitools || true

#Install with pip
pip install multiqc
pip install https://github.com/etetoolkit/ete/archive/ete4.zip
pip install PyQt6
pip install packaging

#Install packages
sudo apt install -y curl

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
