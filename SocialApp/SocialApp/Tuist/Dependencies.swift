import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(
                url: "https://github.com/pointfreeco/swift-composable-architecture",
                requirement: .upToNextMajor(from: "1.0.0")
            ),
            .remote(
                url: "https://github.com/pointfreeco/swift-navigation",
                requirement: .upToNextMajor(from: "1.0.0")
            ),
            .remote(
                url: "https://github.com/pointfreeco/swift-dependencies",
                requirement: .upToNextMajor(from: "1.0.0")
            )
        ],
        productTypes: [
            "ComposableArchitecture": .framework
        ]
    ),
    platforms: [.iOS]
)
