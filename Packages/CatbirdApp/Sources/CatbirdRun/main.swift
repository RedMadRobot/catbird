import CatbirdApp
import Vapor

var env = try Environment.detect()
let config = try AppConfiguration.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }
try configure(app, config)
try app.run()
