package com.mitogex;

import java.nio.file.Path;

public final class RuntimePaths {
    private final Path appRoot;

    private RuntimePaths(Path appRoot) {
        this.appRoot = appRoot.normalize();
    }

    public static RuntimePaths fromCurrentWorkingDirectory() {
        return fromWorkingDirectory(Path.of(System.getProperty("user.dir")));
    }

    public static RuntimePaths fromWorkingDirectory(Path workingDirectory) {
        Path normalized = workingDirectory.toAbsolutePath().normalize();
        Path current = normalized;
        while (current != null) {
            Path fileName = current.getFileName();
            if (fileName != null && "target".equals(fileName.toString())) {
                Path parent = current.getParent();
                return new RuntimePaths(parent == null ? normalized : parent);
            }
            current = current.getParent();
        }
        return new RuntimePaths(normalized);
    }

    public Path appRoot() {
        return appRoot;
    }

    public Path softwareDir() {
        return appRoot.resolve("Software");
    }

    public Path scriptsDir() {
        return softwareDir().resolve("scripts");
    }

    public Path fileLogDir() {
        return softwareDir().resolve("file_log");
    }

    public Path resultsDir() {
        return appRoot.resolve("Results");
    }

    public Path logsDir() {
        return appRoot.resolve("Logs");
    }

    public Path script(String relativePath) {
        return scriptsDir().resolve(relativePath).normalize();
    }

    public Path updateScript() {
        return script("update.sh");
    }
}
