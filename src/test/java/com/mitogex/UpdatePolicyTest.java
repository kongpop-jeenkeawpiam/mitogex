package com.mitogex;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class UpdatePolicyTest {
    @Test
    void disablesAutoUpdateByDefault() {
        assertFalse(UpdatePolicy.fromEnvironment(Map.of()).autoUpdateEnabled());
    }

    @Test
    void enablesAutoUpdateOnlyWhenExplicitlyTrue() {
        assertTrue(UpdatePolicy.fromEnvironment(Map.of("MITOGEX_ENABLE_AUTO_UPDATE", "true")).autoUpdateEnabled());
    }

    @Test
    void treatsOtherValuesAsDisabled() {
        assertFalse(UpdatePolicy.fromEnvironment(Map.of("MITOGEX_ENABLE_AUTO_UPDATE", "yes")).autoUpdateEnabled());
    }
}
