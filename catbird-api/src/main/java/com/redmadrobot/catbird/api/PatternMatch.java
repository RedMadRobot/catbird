package com.redmadrobot.catbird.api;

public final class PatternMatch {
    private static final String TYPE_EQUAL = "equal";
    private static final String TYPE_WILDCARD = "wildcard";

    private final String kind;
    private final String value;

    private PatternMatch(final String kind, final String value) {
        this.kind = kind;
        this.value = value;
    }

    public String kind() {
        return kind;
    }

    public String value() {
        return value;
    }

    public static PatternMatch string(final String value) {
        return new PatternMatch(TYPE_EQUAL, value);
    }

    public static PatternMatch wildcard(final String value) {
        return new PatternMatch(TYPE_WILDCARD, value);
    }

}