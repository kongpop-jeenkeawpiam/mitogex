package com.mitogex;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.util.Map;

public record UploadConfig(URL uploadUrl, String token) {
    public static final String UPLOAD_URL_ENV = "MITOGEX_UPLOAD_URL";
    public static final String UPLOAD_TOKEN_ENV = "MITOGEX_UPLOAD_TOKEN";

    public static UploadConfig fromSystemEnvironment() {
        return fromEnvironment(System.getenv());
    }

    public static UploadConfig fromEnvironment(Map<String, String> environment) {
        String uploadUrl = require(environment, UPLOAD_URL_ENV, "MITOGEX_UPLOAD_URL is required for online sharing.");
        String token = require(environment, UPLOAD_TOKEN_ENV, "MITOGEX_UPLOAD_TOKEN is required for online sharing.");
        try {
            return new UploadConfig(URI.create(uploadUrl).toURL(), token);
        } catch (IllegalArgumentException | MalformedURLException e) {
            throw new IllegalStateException("MITOGEX_UPLOAD_URL must be a valid URL.", e);
        }
    }

    private static String require(Map<String, String> environment, String key, String message) {
        String value = environment.get(key);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException(message);
        }
        return value.trim();
    }
}
