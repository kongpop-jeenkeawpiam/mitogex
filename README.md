# 🧬 Mitochondrial Genome Exploration (MitoGEx)

### Mitochondrial Genome Explorer: An Integrated Platform for Streamlined Human Mitochondrial Genome Analysis
**MitoGEx** is a user-friendly tool designed for comprehensive mtDNA analysis, including quality control, alignment, variant calling, annotation, haplogroup classification, and phylogenetic visualization, all in one pipeline.

---

## 📌 What is it?

**MitoGEx** is a platform application for mitochondrial DNA analysis.  
It integrates:
- Quality control
- Alignment
- Alignment Quality
- Variant calling
- Annotation
- Visualization
  
Supports **WGS** and **WES**.

---

## ⚙️ How does it work?
![MitoGEx Pipeline](https://mitogex.com/img/pipeline2.png)
MitoGEx automates sequencing data analysis using:
- FastQC, Fastp
- BWA
- GATK Mutect2 (Mitochondrial mode)
- Qualimap 2
- HaploGrep 3
- IQ-TREE 2, Phylocanvas.gl, ETEToolkit

**Output includes:**
- QC report
- VCFs
- Annotated variants
- Haplogroup classifications
- Phylogenetic trees

---
  ## ⚠️ Important: ANNOVAR License
MitoGEx utilizes **ANNOVAR** for variant annotation. Due to licensing restrictions:
1. ANNOVAR is **free only for personal, academic, and non-profit use**.
2. **Registration:** [Download ANNOVAR here](https://www.openbioinformatics.org/annovar/annovar_download_form.php).


---

## ✅ Installation (Docker)

### Requirements
- Docker
- Linux desktop with X11 (for GUI). WSLg also works on Windows 11.

### Steps
```bash
git clone https://github.com/kongpop-jeenkeawpiam/mitogex.git
cd mitogex
```
Prepare ANNOVAR:
Place your downloaded annovar.latest.tar.gz in the project root directory (the same folder as the Dockerfile)
Build the image:
```bash
docker compose build
```

Run the GUI (X11 forwarding):
```bash
./run-gui-x11.sh
```

### Input/Output folders
These folders are mounted by default and are safe to use:
- `data/` → input FASTQ/BAM files
- `Results/` → pipeline results
- `Logs/` → logs
- `references/` → reference genomes

---

## ✅ Installation (Non-Docker)

### Requirements
- Linux (tested on Ubuntu 22.04)
- Miniconda or Anaconda installed

### Steps
```bash
git clone https://github.com/kongpop-jeenkeawpiam/mitogex.git
cd mitogex


source install.sh

Prepare ANNOVAR:
Register and download annovar.latest.tar.gz from the official website.
Place the file into the Software/ folder.
```

Run the GUI:
```bash
source run.sh
```

### Input/Output folders
These folders are mounted by default and are safe to use:
- Input FASTQ or BAM → users can select entire directory with GUI application
- `Results/` → pipeline results
- `Logs/` → logs
---


## 🚀 Features

- Pipeline with minimal user input
- Multi-sample support and comparative reports
- Static HTML output for sharing and review
- Supports both FastQ and BAM files
- Interactive phylogenetic visualization

---


## 💻 System Requirements

- **OS**: Linux (tested on Ubuntu 22.04) and Windows (WSLg: Windows Subsystem for Linux GUI) 
- **CPU**: 4 Core minimum  
- **RAM**: 8 GB minimum  
- **Disk Space**: ≥15 GB  
- **Internet**: For updates and external databases

---

## 📬 Contact

**Team**: Kongpop Jeenkeawpiam, Surasak Sangkhathat, Pemikar Srifa, hGATC Team    
**Email**: kongpop.je@gmail.com

---
---

## 💰 Funding

This research was supported by the **Graduate Scholarship from the Faculty of Medicine, Prince of Songkla University**.

---

---

## 📢 Citation
If you use MitoGEx in your research, please cite our paper in **Genes**:
> *Jeenkeawpiam K, Srifa P, Nokchan N, Khongcharoen N, Binkasem A, Sangkhathat S. MitoGEx: An Integrated Platform for Streamlined Human Mitochondrial Genome Analysis. Genes. * [[Link to Paper](https://www.mdpi.com/2073-4425/17/3/338)]

---

