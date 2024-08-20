// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "apnswift",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .executable(name: "APNSExample", targets: ["APNSExample"]),
        .library(name: "APNS", targets: ["APNS"]),
        .library(name: "APNSCore", targets: ["APNSCore"]),
        .library(name: "APNSURLSession", targets: ["APNSURLSession"]),
        .library(name: "APNSTestServer", targets: ["APNSTestServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.42.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", from: "1.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "APNSExample",
            dependencies: [
                .target(name: "APNSCore"),
                .target(name: "APNS"),
            ]
        ),
        .testTarget(
            name: "APNSTests",
            dependencies: [
                .target(name: "APNSCore"),
                .target(name: "APNS"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "APNSCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "APNS",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .target(name: "APNSCore"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "APNSTestServer",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOHTTP2", package: "swift-nio-http2"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "APNSURLSession",
            dependencies: [
                .target(name: "APNSCore"),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
