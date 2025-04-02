// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "IzziSession",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "IzziSession", targets: ["IzziSession"])
    ],
    targets: [
        .binaryTarget(
            name: "IzziSession",
            url: "https://github.com/Desp0o/IzziSession/releases/download/v1.0.0/IzziSession.xcframework.zip",
            checksum: "7fd6ecd104a14a3d66f14db731a29cfacfe021ffa52e8da1fb3646fc5955142e"
        )
    ]
)
