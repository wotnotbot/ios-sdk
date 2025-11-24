// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WotNotSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WotNotSDK",
            targets: ["WotNotSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
       .binaryTarget(
            name: "WotNotSDK",
            url: "https://github.com/wotnotbot/test-ios-chatbot/releases/download/v1.0.0/WotNotSDK.xcframework.zip",
            checksum: "c3a758bf79e493860d4ff3b195f4cd990a5b7a5b961b011e172e426671d22de3"
        ),
    ]
)