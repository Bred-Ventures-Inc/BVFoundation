// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BVFoundation",
    platforms: [
        .iOS(.v15),
        .tvOS(.v13),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BVFoundation",
            targets: ["BVFoundation"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BVFoundation",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack")
            ],
            path: "Sources",
            resources: [
                
            ]),
        .testTarget(
            name: "BVFoundationTests",
            dependencies: ["BVFoundation"]),
    ]
)
