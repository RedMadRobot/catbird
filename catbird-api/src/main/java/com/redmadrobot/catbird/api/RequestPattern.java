package com.redmadrobot.catbird.api;

import java.util.HashMap;
import java.util.Map;

public final class RequestPattern {
    private final String method;
    private final PatternMatch url;
    private final Map<String, PatternMatch> headers;

    private RequestPattern(final String method, final PatternMatch url, final Map<String, PatternMatch> headers) {
        this.method = method;
        this.url = url;
        this.headers = headers;
    }

    public String method() {
        return this.method;
    }

    public PatternMatch url() {
        return this.url;
    }

    public Map<String, PatternMatch> headers() {
        return headers;
    }

    public static Builder newBuilder() {
        return new Builder();
    }

    public static final class Builder {
        private String method = "GET";
        private PatternMatch url;
        private Map<String, PatternMatch> headers = new HashMap<String, PatternMatch>();

        public Builder method(final String method) {
            this.method = method;
            return this;
        }

        public Builder url(final PatternMatch url) {
            this.url = url;
            return this;
        }

        public Builder header(final String name, final PatternMatch value) {
            this.headers.put(name, value);
            return this;
        }

        public Builder headers(final Map<String, PatternMatch> headers) {
            this.headers = headers;
            return this;
        }

        public RequestPattern build() {
            return new RequestPattern(method, url, headers);
        }
    }
}
