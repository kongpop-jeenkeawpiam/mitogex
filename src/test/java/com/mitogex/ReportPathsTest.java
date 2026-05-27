package com.mitogex;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ReportPathsTest {
    @Test
    void exposesCanonicalGeneratedReportNames() {
        assertEquals("Web", ReportPaths.WEB_DIR);
        assertEquals("Phylogenetic", ReportPaths.PHYLOGENETIC_DIR);
        assertEquals("haplogroup.html", ReportPaths.HAPLOGROUP_REPORT);
        assertEquals("tree.html", ReportPaths.TREE_REPORT);
        assertEquals("variants_sampleA.html", ReportPaths.variantsReport("sampleA"));
    }
}
