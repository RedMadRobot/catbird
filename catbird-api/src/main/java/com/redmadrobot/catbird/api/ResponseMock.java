package com.redmadrobot.catbird.api;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public final class ResponseMock {
    private final int status;
    private final Map<String, String> headers;
    private final String body;

    public ResponseMock(final int status, final Map<String, String> headers, final String body) {
        this.status = status;
        this.headers = headers;
        this.body = body;
    }

    public int status() {
        return status;
    }

    public Map<String, String> headers() {
        return headers;
    }

    public String body() {
        return body;
    }

    public static Builder newBuilder() {
        return new Builder();
    }

    public static final class Builder {
        private int status = 200;
        private Map<String, String> headers = new HashMap<String, String>();
        private String body;

        public Builder status(final int status) {
            this.status = status;
            return this;
        }

        public Builder body(final String body) {
            this.body = body;
            return this;
        }

        public Builder file(final String path) throws IOException {
            byte[] fileBytes = Files.readAllBytes(Paths.get(path));
            byte[] encodedBytes = Base64.getEncoder().encode(fileBytes);
            this.body = new String(encodedBytes);;
            return this;
        }

        public Builder header(final String name, final String value) {
            this.headers.put(name, value);
            return this;
        }

        public Builder headers(final Map<String, String> headers) {
            this.headers = headers;
            return this;
        }

        public ResponseMock build() {
            return new ResponseMock(status, headers, body);
        }
    }
}