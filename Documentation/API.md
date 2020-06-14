# Catbird API

- [Actions](#Actions)
  - [Update](#Update)
  - [Remove All](#remove-all)
- [Objects](#Objects)
  - [CatbirdAction](#CatbirdAction)
  - [RequestPattern](#RequestPattern)
  - [ResponseMock](#ResponseMock)
  - [PatternMatch](#PatternMatch)

## Actions

### Update

Add or update `ResponseMock` for `RequestPattern`

```json
POST /catbird/api/mocks
{
  "type": "update",
  "pattern": {
    "method": "POST",
    "url": {
      "kind": "equal",
      "value": "/api/login"
    }
  },
  "response": {
    "status": 200
  }
}
```

`RequestPattern` acts as a unique identifier or key for `ResponseMock`, so that it can be used to remove mock

Remove `ResponseMock` for `RequestPattern`

```json
POST /catbird/api/mocks
{
  "type": "update",
  "pattern": {
    "method": "POST",
    "url": {
      "kind": "equal",
      "value": "/api/login"
    }
  }
}
```

### Remove All

```json
POST /catbird/api/mocks
{
  "type": "removeAll"
}
```

## Objects

### CatbirdAction

Name     | Required | Type
---------|----------|-------
type     | true     | String enum (update, removeAll)
pattern  | false    | RequestPattern
response | false    | ResponseMock

### RequestPattern

`RequestPattern` is a description of the requests to be intercepted and to which the mock should be returned.

Name    | Required | Type
--------|----------|-------
method  | true     | String
url     | true     | PatternMatch
headers | true     | [String: PatternMatch]

### ResponseMock

`ResponseMock` is a description of the http response.

Name    | Required | Type
--------|----------|-------
status  | true     | Int
headers | true     | [String: String]
body    | false    | Base 64 encoded data
limit   | false    | Int
delay   | false    | Int

### PatternMatch

Name  | Required | Type
------|----------|-------
kind  | true     | String enum (equal, wildcard, regexp)
value | true     | String
