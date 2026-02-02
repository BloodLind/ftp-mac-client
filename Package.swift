// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FTPClient",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "FTPClient", targets: ["FTPClient"]),
    ],
    targets: [
        .executableTarget(
            name: "FTPClient",
            path: "src",
            exclude: []
        ),
    ]
)
