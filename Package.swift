// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimezoneBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TimezoneBar",
            path: "Sources/TimezoneBar"
        )
    ]
)
