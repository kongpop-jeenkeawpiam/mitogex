package com.mitogex;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLStreamHandler;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class HTMLUploaderTest {
    @Test
    void returnsShareUrlFromSuccessfulUploadResponse() throws Exception {
        UploadConfig config = uploadConfig(200, "ok https://example.test/shared/project_abc");
        File file = uploadFile();

        String result = HTMLUploader.uploadReport(file, "project", "session", "index.html", config);

        assertEquals("https://example.test/shared/project_abc", result);
    }

    @Test
    void throwsWhenServerReturnsErrorStatus() throws Exception {
        UploadConfig config = uploadConfig(500, "server failed");
        File file = uploadFile();

        IOException error = assertThrows(IOException.class,
                () -> HTMLUploader.uploadReport(file, "project", "session", "index.html", config));

        assertEquals("Upload failed with HTTP 500: server failed", error.getMessage());
    }

    @Test
    void throwsWhenSuccessfulResponseDoesNotContainShareUrl() throws Exception {
        UploadConfig config = uploadConfig(200, "ok");
        File file = uploadFile();

        IOException error = assertThrows(IOException.class,
                () -> HTMLUploader.uploadReport(file, "project", "session", "index.html", config));

        assertEquals("Upload failed with HTTP 200: ok", error.getMessage());
    }

    private static File uploadFile() throws IOException {
        File file = Files.createTempFile("mitogex-upload", ".html").toFile();
        Files.writeString(file.toPath(), "<html></html>");
        return file;
    }

    private static UploadConfig uploadConfig(int responseCode, String responseBody) throws IOException {
        FakeHttpURLConnection connection = new FakeHttpURLConnection(responseCode, responseBody);
        URL url = new URL(null, "http://upload.test/report", new URLStreamHandler() {
            @Override
            protected URLConnection openConnection(URL url) {
                return connection;
            }
        });
        return new UploadConfig(url, "secret-token");
    }

    private static final class FakeHttpURLConnection extends HttpURLConnection {
        private final int responseCode;
        private final byte[] responseBody;
        private final ByteArrayOutputStream requestBody = new ByteArrayOutputStream();

        private FakeHttpURLConnection(int responseCode, String responseBody) throws IOException {
            super(new URL("http://upload.test/report"));
            this.responseCode = responseCode;
            this.responseBody = responseBody.getBytes(StandardCharsets.UTF_8);
        }

        @Override
        public void disconnect() {
        }

        @Override
        public boolean usingProxy() {
            return false;
        }

        @Override
        public void connect() {
        }

        @Override
        public OutputStream getOutputStream() {
            return requestBody;
        }

        @Override
        public int getResponseCode() {
            return responseCode;
        }

        @Override
        public InputStream getInputStream() {
            return new ByteArrayInputStream(responseBody);
        }

        @Override
        public InputStream getErrorStream() {
            return new ByteArrayInputStream(responseBody);
        }
    }
}
