import CatbirdApp
import Vapor
import Foundation

/*
 curl http://icanhazdadjoke.com/j/R7UfaahVfFd
 curl http://icanhazdadjoke.com/j/R7UfaahVfFd --proxy http://127.0.0.1:8080
 */

/// https://icanhazdadjoke.com/api
struct JokeAPI {
    struct Joke {
        let id: String
        let text: String
        var path: String { "/j/\(id)" }
    }

    /// API url.
    let url = URL(string: "https://icanhazdadjoke.com")!

    /// API host.
    var host: String { url.host! }

    /// API root directory.
    let root = "/j"

    /// Required headers for all requests.
    let headers: HTTPHeaders = [
        "Host": "127.0.0.1:8080",
        "Accept": "text/plain",
        "User-Agent": "Catbird (\(CatbirdInfo.current.github)"
    ]

    /// All jokes.
    let jokes = [
        Joke(
            id: "R7UfaahVfFd",
            text: "My dog used to chase people on a bike a lot. It got so bad I had to take his bike away."),
        Joke(
            id: "0ozAXv4Mmjb",
            text: "Why did the tomato blush? Because it saw the salad dressing.")
    ]
}
