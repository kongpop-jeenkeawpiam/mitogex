package com.mitogex;

import org.junit.jupiter.api.Test;

import java.io.BufferedWriter;
import java.io.StringWriter;
import java.nio.file.Path;
import java.time.Duration;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;

class CommandRunnerTest {
    @Test
    void passesShellMetacharactersAsLiteralArguments() throws Exception {
        StringWriter output = new StringWriter();
        CommandRunner runner = new CommandRunner();

        CommandRunner.Result result = runner.run(
                List.of("/usr/bin/printf", "%s", "literal;$(not-a-command)"),
                Path.of("."),
                Duration.ofSeconds(5),
                new BufferedWriter(output)
        );

        assertEquals(0, result.exitCode());
        assertFalse(result.timedOut());
        assertEquals("literal;$(not-a-command)" + System.lineSeparator(), output.toString());
    }
}
