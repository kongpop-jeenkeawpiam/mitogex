package com.mitogex;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Path;
import java.time.Duration;
import java.util.List;
import java.util.concurrent.TimeUnit;

public final class CommandRunner {
    public Result run(List<String> command, Path workingDirectory, Duration timeout, BufferedWriter logWriter)
            throws IOException, InterruptedException {
        if (command == null || command.isEmpty()) {
            throw new IllegalArgumentException("Command must contain at least one argument.");
        }

        ProcessBuilder processBuilder = new ProcessBuilder(command);
        if (workingDirectory != null) {
            processBuilder.directory(workingDirectory.toFile());
        }
        processBuilder.redirectErrorStream(true);

        Process process = processBuilder.start();
        IOException[] readerError = new IOException[1];
        Thread outputThread = new Thread(() -> {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println(line);
                    if (logWriter != null) {
                        logWriter.write(line);
                        logWriter.newLine();
                    }
                }
            } catch (IOException e) {
                readerError[0] = e;
            }
        }, "mitogex-command-output");
        outputThread.start();

        boolean finished = process.waitFor(timeout.toMillis(), TimeUnit.MILLISECONDS);
        if (!finished) {
            process.destroyForcibly();
            outputThread.join(1000);
            return new Result(-1, true);
        }
        outputThread.join();
        if (readerError[0] != null) {
            throw readerError[0];
        }

        if (logWriter != null) {
            logWriter.flush();
        }
        return new Result(process.exitValue(), false);
    }

    public record Result(int exitCode, boolean timedOut) {
        public boolean success() {
            return exitCode == 0 && !timedOut;
        }
    }
}
