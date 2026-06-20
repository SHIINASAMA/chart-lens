// swift-tools-version: 5.9
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
