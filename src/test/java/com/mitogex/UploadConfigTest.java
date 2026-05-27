package com.mitogex;

import org.junit.jupiter.api.Test;

import java.net.URI;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class UploadConfigTest {
    @Test
    void readsUploadUrlAndTokenFromEnvironmentValues() throws Exception {
        UploadConfig config = UploadConfig.fromEnvironment(Map.of(
                "MITOGEX_UPLOAD_URL", "https://example.test/upload.php",
                "MITOGEX_UPLOAD_TOKEN", "secret-token"
        ));

        assertEquals(URI.create("https://example.test/upload.php").toURL(), config.uploadUrl());
        assertEquals("secret-token", config.token());
    }

    @Test
    void rejectsMissingUploadToken() {
        IllegalStateException error = assertThrows(IllegalStateException.class, () ->
                UploadConfig.fromEnvironment(Map.of("MITOGEX_UPLOAD_URL", "https://example.test/upload.php")));

        assertEquals("MITOGEX_UPLOAD_TOKEN is required for online sharing.", error.getMessage());
    }

    @Test
    void rejectsMissingUploadUrl() {
        IllegalStateException error = assertThrows(IllegalStateException.class, () ->
                UploadConfig.fromEnvironment(Map.of("MITOGEX_UPLOAD_TOKEN", "secret-token")));

        assertEquals("MITOGEX_UPLOAD_URL is required for online sharing.", error.getMessage());
    }
}
