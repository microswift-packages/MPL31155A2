// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MPL31155A2",
    products: [
        .library(
            name: "MPL31155A2",
            targets: ["MPL31155A2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/microswift-packages/i2c", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/i2c-buffers", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/delay", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MPL31155A2",
            dependencies: [],
            path: ".",
            sources: ["MPL31155A2.swift"]),
    ]
)
