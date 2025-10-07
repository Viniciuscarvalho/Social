import ProjectDescription

let project = Project(
    name: "SocialApp",
    packages: [
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "1.0.0")
        )
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        .target(
            name: "SocialApp",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.SocialApp",
            infoPlist: .default,
            sources: [
                "./SocialApp/Sources/**",
                "./Domain/Sources/**",
                "./Projects/Features/Login/**",
                "./Projects/Features/Profile/**",
                "./Projects/Features/Events/Sources/**",
                "./Projects/Features/TicketsList/Sources/**", 
                "./Projects/Features/SellerProfile/Sources/**",
                "./Projects/Features/TicketDetail/Sources/**"
            ],
            resources: ["SocialApp/Resources/**"],
            dependencies: [
                .package(product: "ComposableArchitecture")
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            )
        ),

        .target(
            name: "SocialAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.SocialAppTests",
            infoPlist: .default,
            buildableFolders: [
                "SocialApp/Tests"
            ],
            dependencies: [.target(name: "SocialApp")]
        )
    ]
    
)
