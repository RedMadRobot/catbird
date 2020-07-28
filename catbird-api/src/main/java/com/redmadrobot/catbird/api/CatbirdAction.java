package com.redmadrobot.catbird.api;

public final class CatbirdAction {
    private static final String TYPE_UPDATE = "update";
    private static final String TYPE_REMOVE = "remove";
    private static final String TYPE_REMOVE_ALL = "removeAll";

    private final String type;
    private final RequestPattern pattern;
    private final ResponseMock response;

    public String type() {
        return this.type;
    }

    public RequestPattern pattern() {
        return this.pattern;
    }

    public ResponseMock response() {
        return this.response;
    }

    private CatbirdAction(String type, RequestPattern pattern, ResponseMock response) {
        this.type = type;
        this.pattern = pattern;
        this.response = response;
    }

    public static CatbirdAction update(RequestPattern pattern, ResponseMock response) {
        return new CatbirdAction(TYPE_UPDATE, pattern, response);
    }

    public static CatbirdAction remove(RequestPattern pattern) {
        return new CatbirdAction(TYPE_REMOVE, pattern, null);
    }

    public static CatbirdAction removeAll() {
        return new CatbirdAction(TYPE_REMOVE_ALL, null, null);
    }
}