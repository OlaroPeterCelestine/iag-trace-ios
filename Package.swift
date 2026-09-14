// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TraceIOS",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "TraceCore", targets: ["TraceCore"]),
    ],
    targets: [
        .target(name: "TraceCore"),
        .testTarget(name: "TraceCoreTests", dependencies: ["TraceCore"]),
    ]
)
