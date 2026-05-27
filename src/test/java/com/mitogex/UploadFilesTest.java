package com.mitogex;

import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UploadFilesTest {
    @Test
    void collectsOnlyUploadableFiles() throws Exception {
        Path baseDir = Files.createTempDirectory("mitogex-upload-files");
        Path nestedDir = Files.createDirectories(baseDir.resolve("assets"));
        Path html = Files.writeString(baseDir.resolve("index.html"), "html");
        Path image = Files.writeString(nestedDir.resolve("logo.PNG"), "png");
        Files.writeString(baseDir.resolve("raw.vcf"), "vcf");

        List<Path> uploadFiles = UploadFiles.collectUploadFiles(baseDir);

        assertEquals(2, uploadFiles.size());
        assertTrue(uploadFiles.containsAll(List.of(html, image)));
    }

    @Test
    void convertsRelativeUploadPathToForwardSlashes() throws Exception {
        Path baseDir = Files.createTempDirectory("mitogex-upload-files");
        Path nestedDir = Files.createDirectories(baseDir.resolve("assets"));
        Path css = Files.writeString(nestedDir.resolve("style.css"), "css");

        assertEquals("assets/style.css", UploadFiles.relativeUploadPath(baseDir, css));
    }
}
