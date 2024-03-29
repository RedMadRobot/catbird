// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Catbird",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "CatbirdAPI", targets: ["CatbirdAPI"])
    ],
    targets: [
        // Common API
        .target(name: "CatbirdAPI", path: "Packages/CatbirdAPI/Sources"),
        .testTarget(name: "CatbirdAPITests", dependencies: ["CatbirdAPI"], path: "Packages/CatbirdAPI/Tests")
    ]
)
