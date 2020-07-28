package com.redmadrobot.catbird.api;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;

import com.google.gson.Gson;

public final class Catbird {
    private final URL url;

    public Catbird(final URL url) {
        this.url = url;
    }

    public URL url() {
        return this.url;
    }

    public void update(final CatbirdMock mock) {
        RequestPattern pattern = mock.pattern();
        ResponseMock response = mock.response();
        CatbirdAction action = CatbirdAction.update(pattern, response);
        perform(action);
    }

    public void remove(final CatbirdMock mock) {
        RequestPattern pattern = mock.pattern();
        CatbirdAction action = CatbirdAction.remove(pattern);
        perform(action);
    }

    public void removeAll() {
        perform(CatbirdAction.removeAll());
    }

    public void perform(CatbirdAction action) {
        try {
            send(action);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void writeMockJson(
        String method, 
        PatternMatch url, 
        HashMap<String, PatternMatch> headerFields, 
        String pathToMock, 
        int statusCode, 
        HashMap<String, String> responseHeaderFields) {
        try {
            RequestPattern pattern = RequestPattern.newBuilder()
                .method(method)
                .url(url)
                .headers(headerFields)
                .build();

            ResponseMock response = ResponseMock.newBuilder()
                .status(statusCode)
                .headers(responseHeaderFields)
                .file(pathToMock)
                .build();

            this.send(CatbirdAction.update(pattern, response));
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    private void send(CatbirdAction action) throws Exception {
        Gson gson = new Gson();
        String body = gson.toJson(action);

        final URI uri = this.url.toURI();
        final URL url = uri.resolve("catbird/api/mocks").toURL();
        final HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");

        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        connection.setDoOutput(true);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setFixedLengthStreamingMode(bytes.length);
        OutputStream outputStream = null;
        try {
            outputStream = connection.getOutputStream();
            outputStream.write(bytes);
        } finally {
            if (outputStream != null) {
                outputStream.close();
            }
        }

        final StringBuilder content = new StringBuilder();
        BufferedReader buffer = null;
        try {
            buffer = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String inputLine;
            while ((inputLine = buffer.readLine()) != null) {
                content.append(inputLine);
            }
        } finally {
            if (buffer != null) {
                buffer.close();
            }
        }
        System.out.println(content);
    }
}