// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "CatbirdApp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "catbird", targets: ["CatbirdRun"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),

        // Templete engine
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.14.0"),

        // CatbirdAPI
        .package(name: "Catbird", path: "../../")
    ],
    targets: [
        // Web Server
        .target(name: "CatbirdApp", dependencies: [
            .product(name: "CatbirdAPI", package: "Catbird"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Stencil", package: "Stencil"),
        ]),
        .testTarget(name: "CatbirdAppTests", dependencies: [
            .target(name: "CatbirdApp"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),

        // CLI
        .target(name: "CatbirdRun", dependencies: ["CatbirdApp"]),
    ]
)
