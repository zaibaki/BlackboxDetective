// swift-tools-version: 5.8
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "BlackboxDetective",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "BlackboxDetective",
            targets: ["AppModule"],
            bundleIdentifier: "com.detective.blackbox",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .camera),
            accentColor: .presetColor(.green),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeLeft,
                .landscapeRight
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources"
        )
    ]
)
