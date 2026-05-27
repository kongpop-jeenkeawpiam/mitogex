package com.mitogex;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.stream.Stream;

public record InputDirectorySummary(boolean containsGz, boolean containsBam, boolean containsFasta) {
    public static InputDirectorySummary scan(Path inputDir) throws IOException {
        boolean containsGz = false;
        boolean containsBam = false;
        boolean containsFasta = false;

        try (Stream<Path> files = Files.list(inputDir)) {
            for (Path file : files.toList()) {
                if (!Files.isRegularFile(file)) {
                    continue;
                }
                String fileName = file.getFileName().toString().toLowerCase(Locale.ROOT);
                if (fileName.endsWith(".gz")) {
                    containsGz = true;
                } else if (fileName.endsWith(".bam")) {
                    containsBam = true;
                } else if (fileName.endsWith(".fasta")) {
                    containsFasta = true;
                }
            }
        }

        return new InputDirectorySummary(containsGz, containsBam, containsFasta);
    }

    public int copyFastaFiles(Path sourceDir, Path destinationDir) throws IOException {
        Files.createDirectories(destinationDir);
        int copied = 0;
        try (Stream<Path> files = Files.list(sourceDir)) {
            for (Path file : files.toList()) {
                if (Files.isRegularFile(file)
                        && file.getFileName().toString().toLowerCase(Locale.ROOT).endsWith(".fasta")) {
                    Files.copy(file, destinationDir.resolve(file.getFileName()), StandardCopyOption.REPLACE_EXISTING);
                    copied++;
                }
            }
        }
        return copied;
    }
}
