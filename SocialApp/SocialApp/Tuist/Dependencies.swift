import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(
                url: "https://github.com/pointfreeco/swift-composable-architecture",
                requirement: .exact("1.22.3")
            ),
            .remote(
                url: "https://github.com/pointfreeco/swift-navigation",
                requirement: .upToNextMajor(from: "2.0.0")
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
