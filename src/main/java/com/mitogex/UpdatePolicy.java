package com.mitogex;

import java.util.Map;

public record UpdatePolicy(boolean autoUpdateEnabled) {
    public static final String AUTO_UPDATE_ENV = "MITOGEX_ENABLE_AUTO_UPDATE";

    public static UpdatePolicy fromSystemEnvironment() {
        return fromEnvironment(System.getenv());
    }

    public static UpdatePolicy fromEnvironment(Map<String, String> environment) {
        return new UpdatePolicy("true".equalsIgnoreCase(environment.getOrDefault(AUTO_UPDATE_ENV, "").trim()));
    }
}
