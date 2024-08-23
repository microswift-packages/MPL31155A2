// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "b3",
    products: [
        .executable(
            name: "b3",
            targets: ["b3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/microswift-packages/delay", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/i2c", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/i2c-buffers", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/serial", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/ATmega328P", from: "1.0.0"),
        .package(url: "https://github.com/microswift-packages/MPL31155A2", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "b3",
            dependencies: [],
            path: ".",
            sources: ["main.swift"]),
    ]
)
