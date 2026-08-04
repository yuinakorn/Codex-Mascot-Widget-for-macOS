// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CodexMascotWidget",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CodexMascotWidget",
            targets: ["CodexMascotWidget"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CodexMascotWidget",
            dependencies: [],
            path: "Sources/CodexMascotWidget",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
