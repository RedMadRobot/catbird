// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Catbird",
    products: [
        .library(name: "CatbirdAPI", targets: ["CatbirdAPI"]),
        .executable(name: "catbird", targets: ["Catbird"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "CatbirdAPI"),
        .target(name: "CatbirdApp", dependencies: ["Vapor", "CatbirdAPI", "Leaf"]),
        .target(name: "Catbird", dependencies: ["CatbirdApp"]),
        .testTarget(name: "CatbirdAPITests", dependencies: ["CatbirdAPI"]),
        .testTarget(name: "CatbirdAppTests", dependencies: ["CatbirdApp"]),
    ]
)
