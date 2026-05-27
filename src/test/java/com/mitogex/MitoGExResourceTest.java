package com.mitogex;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class MitoGExResourceTest {
    @Test
    void splashImageResourceIsPackaged() {
        assertNotNull(MitoGEx.class.getResource("/images/mitogex.png"));
    }
}
