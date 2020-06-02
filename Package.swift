// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Catbird",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "CatbirdAPI", targets: ["CatbirdAPI"]),
        .executable(name: "catbird", targets: ["CatbirdRun"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),

        // Templete engine
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0"),

        // macOS system logger
        .package(url: "https://github.com/Alexander-Ignition/OSLogging", from: "1.0.0"),
    ],
    targets: [
        // Common API
        .target(name: "CatbirdAPI"),
        .testTarget(name: "CatbirdAPITests", dependencies: ["CatbirdAPI"]),

        // Web Server
        .target(name: "CatbirdApp", dependencies: [
            .target(name: "CatbirdAPI"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Stencil", package: "Stencil"),
            .product(name: "OSLogging", package: "OSLogging"),
        ]),
        .testTarget(name: "CatbirdAppTests", dependencies: [
            .target(name: "CatbirdApp"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),

        // CLI
        .target(name: "CatbirdRun", dependencies: ["CatbirdApp"]),
    ]
)
