import ProjectDescription

let project = Project(
    name: "SocialApp",
    packages: [
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .exact("1.22.3")
        ),
        .remote(
            url: "https://github.com/supabase/supabase-swift",
            requirement: .upToNextMajor(from: "2.0.0")
        ),
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "11.0.0")
        )
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_LANGUAGE": "pt-BR"
        ],
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
            infoPlist: .extendingDefault(with: [
                "FirebaseAppDelegateProxyEnabled": false,
                "NSUserNotificationAlertSoundEnabled": false,
                "CFBundleDevelopmentRegion": "pt-BR",
                "UILaunchScreen": [
                    "UIImageName": "splash",
                    "UIImageRespectsSafeAreaInsets": true,
                    "UIColorName": "AccentColor"
                ]
            ]),
            sources: [
                "./SocialApp/Sources/**",
                "./Data/Sources/**",
                "./Domain/Sources/**",
                "./Projects/Features/Login/**",
                "./Projects/Features/Negotiations/**",
                "./Projects/Features/Home/**",
                "./Projects/Features/Profile/**",
                "./Projects/Features/Events/Sources/**",
                "./Projects/Features/TicketsList/Sources/**", 
                "./Projects/Features/SellersList/Sources/**",
                "./Projects/Features/SellerProfile/Sources/**",
                "./Projects/Features/TicketDetail/Sources/**",
                "./Projects/Features/Verification/Sources/**"
            ],
            resources: ["SocialApp/Resources/**"],
            dependencies: [
                .package(product: "ComposableArchitecture"),
                .package(product: "Supabase"),
                .package(product: "FirebaseCore"),
                .package(product: "FirebaseMessaging")
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
