// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatBotSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ChatBotSDK",
            targets: ["ChatBotSDK"]),
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
            name: "ChatBotSDK",
            url: "https://github.com/MahekkumarChaniyara/PrivateSpecs/releases/download/1.0.3/ChatBotSDK.xcframework.zip",
            checksum: "548686ba6d40ce402d9139608e289d6ed8d4da02d6c85750181c72c28e723a91"
        ),
    ]
)