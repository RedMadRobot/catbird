# Catbird

> Catbird | Drozd | Дрозд

Mock server for ui tests

## Features

- Dynamic mock server
- Static file mock server
- Proxy server with writing response files

## Requirements

Install `libressl` for `swift-nio`

```bash
$ brew install libressl
```

## Installation

### Cocoapods

Add `Catbird` to UI tests target.

```ruby
target 'App' do
  use_frameworks!

  target 'AppUITests' do
    inherit! :search_paths

    pod 'Catbird'
  end
end
```

## Setup in Xcode project

- Open `Schema/Edit scheme...`
- Select Test action
- Select `Pre-Actions`
  - Add `New Run Script action`
  - Provide build setting from `<YOUR_APP_TARGET>`
  - `${PODS_ROOT}/Catbird/start.sh`
- Select `Post-Actions`
  - Add `New Run Script action`
  - Provide build setting from `<YOUR_APP_TARGET>`
  - `${PODS_ROOT}/Catbird/stop.sh`

## Usage

```swift
import XCTest
import Catbird

enum LoginMock: RequestBagConvertible {
    case success
    case blockedUserError

    var pattern: RequestPattern {
        return RequestPattern.post(URL(string: "/login")!)
    }

    var responseData: ResponseData {
        switch self {
        case .success:
            let json: [String: Any] = [
                "data": [
                    "access_token": "abc",
                    "refresh_token": "xyz",
                    "expired_in": "123",
                ]
            ]
            return ResponseData(
                statusCode: 200,
                headerFields: ["Content-Type": "application/json"],
                body: try! JSONSerialization.data(withJSONObject: json))

        case .blockedUserError:
            let json: [String: Any] = [
                "error": [
                    "code": "user_blocked",
                    "message": "user blocked"
                ]
            ]
            return ResponseData(
                statusCode: 400,
                headerFields: ["Content-Type": "application/json"],
                body: try! JSONSerialization.data(withJSONObject: json))
        }
    }
}

final class LoginUITests: XCTestCase {

    private let catbird = Catbird()
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()

        // Base URL in app `UserDefaults.standard.url(forKey: "url_key")`
        let url = catbird.url.appendingPathComponent("api")
        app.launchArguments = ["-url_key", url.absoluteString]
        app.launch()
    }

    override func tearDown() {
        XCTAssertNoThrow(try catbird.send(.clear), "Remove all requests")
        super.tearDown()
    }

    func testLogin() {
        XCTAssertNoThrow(try catbird.send(.add(LoginMock.success)))

        app.textFields["login"].typeText("john@example.com")
        app.secureTextFields["password"].typeText("qwerty")
        app.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Main Screen"].exists)
    }

    func testBlockedUserError() {
        XCTAssertNoThrow(try catbird.send(.add(LoginMock.blockedUserError)))

        app.textFields["login"].typeText("peter@example.com")
        app.secureTextFields["password"].typeText("burger")
        app.buttons["Done"].tap()

        XCTAssertTrue(app.alerts["Error"].exists)
    }

}
```

## Example project

```bash
$ cd Example/CatbirdX
$ bundle exec pod install
$ xed .
```

## Logs

Logs can be viewed in the `Console.app` with subsystem `com.redmadrobot.catbird`

Don't forget to include the message in the action menu

- [x] Include Info Messages
- [x] Include Debug Messages

Without this, only error messages will be visible

## Web

You can view a list of all intercepted requests on the page http://127.0.0.1:8080/catbird
