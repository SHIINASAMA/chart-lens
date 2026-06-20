// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChartLens",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ChartLens",
            targets: ["ChartLens"]
        ),
    ],
    targets: [
        .target(
            name: "ChartLens"
        ),
        .testTarget(
            name: "ChartLensTests",
            dependencies: ["ChartLens"]
        ),
    ]
)
