package com.mitogex;

import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class InputDirectorySummaryTest {
    @Test
    void detectsSupportedInputTypesInSelectedDirectory() throws Exception {
        Path inputDir = Files.createTempDirectory("mitogex-input");
        Files.writeString(inputDir.resolve("sample_1.fastq.gz"), "fastq");
        Files.writeString(inputDir.resolve("aligned.bam"), "bam");
        Files.writeString(inputDir.resolve("sequence.fasta"), "fasta");
        Files.createDirectories(inputDir.resolve("nested"));

        InputDirectorySummary summary = InputDirectorySummary.scan(inputDir);

        assertTrue(summary.containsGz());
        assertTrue(summary.containsBam());
        assertTrue(summary.containsFasta());
    }

    @Test
    void leavesFlagsFalseWhenNoSupportedInputsExist() throws Exception {
        Path inputDir = Files.createTempDirectory("mitogex-input");
        Files.writeString(inputDir.resolve("notes.txt"), "notes");

        InputDirectorySummary summary = InputDirectorySummary.scan(inputDir);

        assertFalse(summary.containsGz());
        assertFalse(summary.containsBam());
        assertFalse(summary.containsFasta());
    }

    @Test
    void copiesOnlyFastaFilesToDestination() throws Exception {
        Path inputDir = Files.createTempDirectory("mitogex-input");
        Path destinationDir = Files.createTempDirectory("mitogex-fasta");
        Files.writeString(inputDir.resolve("a.fasta"), "a");
        Files.writeString(inputDir.resolve("b.FASTA"), "b");
        Files.writeString(inputDir.resolve("notes.txt"), "notes");

        int copied = new InputDirectorySummary(false, false, true)
                .copyFastaFiles(inputDir, destinationDir);

        assertEquals(2, copied);
        assertTrue(Files.exists(destinationDir.resolve("a.fasta")));
        assertTrue(Files.exists(destinationDir.resolve("b.FASTA")));
        assertFalse(Files.exists(destinationDir.resolve("notes.txt")));
    }
}
