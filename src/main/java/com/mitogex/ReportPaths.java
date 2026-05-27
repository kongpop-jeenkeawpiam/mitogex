package com.mitogex;

public final class ReportPaths {
    public static final String FASTQC_DIR = "FastQC";
    public static final String FASTP_DIR = "Fastp";
    public static final String MULTIQC_DIR = "MultiQC";
    public static final String ALIGNMENT_QUALITY_DIR = "AlignmentQuality";
    public static final String MULTI_SAMPLE_QC_DIR = "MultiSample_QC";
    public static final String WEB_DIR = "Web";
    public static final String PHYLOGENETIC_DIR = "Phylogenetic";

    public static final String MULTIQC_REPORT = "multiqc_report.html";
    public static final String FASTP_REPORT = ".html";
    public static final String QUALIMAP_REPORT = "qualimapReport.html";
    public static final String MULTI_SAMPLE_QC_REPORT = "multisampleBamQcReport.html";
    public static final String HAPLOGROUP_REPORT = "haplogroup.html";
    public static final String TREE_REPORT = "tree.html";

    private ReportPaths() {
    }

    public static String fastqcRead1(String sample) {
        return sample + "_1_fastqc.html";
    }

    public static String fastqcRead2(String sample) {
        return sample + "_2_fastqc.html";
    }

    public static String fastpReport(String sample) {
        return sample + FASTP_REPORT;
    }

    public static String variantsReport(String sample) {
        return "variants_" + sample + ".html";
    }
}
