# Catbird API

- [Actions](##Actions)
  - [Update](###Update)
  - [Remove All](###remove-all)
- [Objects](##Objects)
  - [CatbirdAction](###CatbirdAction)
  - [RequestPattern](###RequestPattern)
  - [ResponseMock](###ResponseMock)
  - [Pattern](###Pattern)

## Actions

### Update

Add or update `ResponseMock` for `RequestPattern`

```json
POST /catbird/api/mocks
{
  "pattern": {
    "method": "POST",
    "url": "/api/login"
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
  "pattern": {
    "method": "POST",
    "url": "/api/login"
  }
}
```

### Remove All

Request with empty body.

```
POST /catbird/api/mocks
```

## Objects

### CatbirdAction

Name     | Optional | Type
---------|----------|-------
pattern  | true     | RequestPattern
response | true     | ResponseMock

### RequestPattern

`RequestPattern` is a description of the requests to be intercepted and to which the mock should be returned.

Name    | Optional | Type
--------|----------|-------
method  | false    | String
url     | false    | Pattern
headers | false    | [String: Pattern]

### ResponseMock

`ResponseMock` is a description of the http response.

Name    | Optional | Type
--------|----------|-------
status  | false    | Int
headers | false    | [String: String]
body    | true     | Base 64 encoded data
limit   | true     | Int
delay   | true     | Int

### Pattern

Name  | Optional | Type
------|----------|-------
kind  | false    | String enum (equal, wildcard, regexp)
value | false    | String
