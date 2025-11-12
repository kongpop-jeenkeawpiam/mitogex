# 🧬 Mitochondrial Genome Exploration (MitoGEx)

### Mitochondrial Genome Explorer: A User-Friendly Computational Pipeline for Comprehensive Mitochondrial Genome Analysis

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
![MitoGEx Pipeline](https://mitogex.com/img/pipeline.png)
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
## 🚀 Installation Guide
To get started with **MitoGEx**, make sure you have **Miniconda** (or Anaconda) installed on your system. 
```bash
git clone https://github.com/kongpop-jeenkeawpiam/mitogex.git
cd mitogex
```
Then, simply run the installation script provided in the repository:
```bash
source install.sh
```
Once the installation is complete, you can launch MitoGEx using:
```bash
source run.sh
```
---

## 🚀 Features

- Pipeline with minimal user input
- Multi-sample support and comparative reports
- Static HTML output for sharing and review
- Supports both FastQ and BAM files
- Interactive phylogenetic visualization

---


## 💻 System Requirements

- **OS**: Linux (tested on Ubuntu 22.04)  
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

