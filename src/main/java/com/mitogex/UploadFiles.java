package com.mitogex;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Stream;

public final class UploadFiles {
    private static final Set<String> UPLOAD_EXTENSIONS = Set.of(
            ".html", ".htm", ".txt", ".pdf", ".css", ".gif", ".png", ".jpg", ".jpeg", ".js"
    );

    private UploadFiles() {
    }

    public static List<Path> collectUploadFiles(Path baseDir) throws IOException {
        try (Stream<Path> files = Files.walk(baseDir)) {
            return files
                    .filter(Files::isRegularFile)
                    .filter(UploadFiles::isUploadable)
                    .toList();
        }
    }

    public static String relativeUploadPath(Path baseDir, Path filePath) {
        return baseDir.relativize(filePath).toString().replace("\\", "/");
    }

    static boolean isUploadable(Path path) {
        String name = path.getFileName().toString().toLowerCase(Locale.ROOT);
        return UPLOAD_EXTENSIONS.stream().anyMatch(name::endsWith);
    }
}
