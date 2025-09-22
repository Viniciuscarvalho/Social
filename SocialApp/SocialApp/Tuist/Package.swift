// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "SocialApp",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SocialApp", targets: ["SocialApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SocialApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            resources: [
                .process("Resources/events.json"),
                .process("Resources/user.json")
            ]
        ),
        .testTarget(
            name: "SocialAppTests",
            dependencies: ["SocialApp"]
        )
    ]
)