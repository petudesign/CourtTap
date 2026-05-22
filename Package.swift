// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CourtTap",
    platforms: [
        .watchOS(.v10),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CourtTapCore", targets: ["CourtTapCore"]),
        .library(name: "CourtTapWatchUI", targets: ["CourtTapWatchUI"])
    ],
    targets: [
        .target(name: "CourtTapCore"),
        .target(
            name: "CourtTapWatchUI",
            dependencies: ["CourtTapCore"]
        ),
        .testTarget(
            name: "CourtTapCoreTests",
            dependencies: ["CourtTapCore"]
        )
    ]
)
