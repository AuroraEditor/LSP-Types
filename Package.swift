// swift-tools-version: 5.9.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSP Types",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "LSP Types",
            targets: ["LSP Types"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LSP Types",
            dependencies: []),
    ]
)
