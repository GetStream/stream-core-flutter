// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "stream_thumbnail",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "stream-thumbnail", targets: ["stream_thumbnail"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/SDWebImage/libwebp-Xcode.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "stream_thumbnail",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "libwebp", package: "libwebp-Xcode")
            ],
            cSettings: [
                .headerSearchPath("include/stream_thumbnail")
            ]
        )
    ]
)
