package com.mitogex;

import org.junit.jupiter.api.Test;

import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;

class RuntimePathsTest {
    @Test
    void resolvesRepositoryRootFromNormalWorkingDirectory() {
        Path root = Path.of("/work/mitogex");

        RuntimePaths paths = RuntimePaths.fromWorkingDirectory(root);

        assertEquals(root, paths.appRoot());
        assertEquals(root.resolve("Results"), paths.resultsDir());
        assertEquals(root.resolve("Software").resolve("scripts"), paths.scriptsDir());
    }

    @Test
    void resolvesRepositoryRootFromMavenTargetDirectory() {
        Path root = Path.of("/work/mitogex");

        RuntimePaths paths = RuntimePaths.fromWorkingDirectory(root.resolve("target").resolve("classes"));

        assertEquals(root, paths.appRoot());
        assertEquals(root.resolve("Software").resolve("file_log"), paths.fileLogDir());
    }

    @Test
    void preservesDockerStyleRoot() {
        Path root = Path.of("/opt/mitogex");

        RuntimePaths paths = RuntimePaths.fromWorkingDirectory(root);

        assertEquals(root, paths.appRoot());
        assertEquals(root.resolve("Logs"), paths.logsDir());
    }
}
