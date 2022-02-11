// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Master",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Master",
            targets: ["Master"]),
    ],
    targets: [
        .target(
            name: "Master",
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Master"],
            path: "Tests"),
    ]
)
