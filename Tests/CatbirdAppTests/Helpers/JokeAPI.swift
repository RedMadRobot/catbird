import CatbirdApp
import Vapor

/// https://icanhazdadjoke.com/api
struct JokeAPI {
    struct Joke {
        let id: String
        let text: String
        var path: String { "/j/\(id)" }
    }

    /// API host.
    let host = URL(string: "https://icanhazdadjoke.com")!

    /// API root directory.
    let root = "/j"

    /// Required headers for all requests.
    let headers: HTTPHeaders = [
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
