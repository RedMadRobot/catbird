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
        app.launchArguments = ["-url_key", catbird.url.absoluteString]
        app.launch()
    }

    override func tearDown() {
        XCTAssertNoThrow(try catbird.send(.clear), "Remove all requests")
        super.tearDown()
    }

    func testLogin() {
        XCTAssertNoThrow(try catbird.send(.add(LoginMock.success)))

        app.textFields["login"].tap()
        app.textFields["login"].typeText("john@example.com")
        app.secureTextFields["password"].tap()
        app.secureTextFields["password"].typeText("qwerty")
        app.buttons["Done"].tap()

        XCTAssert(app.staticTexts["Main Screen"].waitForExistence(timeout: 3))
    }

    func testBlockedUserError() {
        XCTAssertNoThrow(try catbird.send(.add(LoginMock.blockedUserError)))

        app.textFields["login"].tap()
        app.textFields["login"].typeText("peter@example.com")
        app.secureTextFields["password"].tap()
        app.secureTextFields["password"].typeText("burger")
        app.buttons["Done"].tap()

        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 3))
    }
}
