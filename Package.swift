// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyCollections",
    products: [
        .library(name: "EasyCollections", targets: ["EasyCollections"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "EasyCollections", dependencies: []),
        .testTarget(name: "EasyCollectionsTests", dependencies: ["EasyCollections"]),
    ]
)
