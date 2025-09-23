import ProjectDescription

let project = Project(
    name: "SocialApp",
    settings: .settings(
        configurations: [
            .debug(
                name: "Debug",
                settings: [
                    "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "YES",
                    // Configuração crítica para evitar símbolos duplicados
                    "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks",
                    "FRAMEWORK_SEARCH_PATHS": "$(inherited) $(PLATFORM_DIR)/Developer/Library/Frameworks"
                ]
            )
        ]
    ),
    targets: [
        .target(
            name: "SocialApp",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.SocialApp",
            infoPlist: .default,
            buildableFolders: [
                "SocialApp/Sources",
                "SocialApp/Resources",
            ],
            dependencies: [
                .project(target: "SharedModels", path: "SharedModels"),
                .project(target: "Events", path: "Projects/Features/Events"),
                .project(target: "TicketsList", path: "Projects/Features/TicketsList"),
                .project(target: "SellerProfile", path: "Projects/Features/SellerProfile"),
                .project(target: "TicketDetail", path: "Projects/Features/TicketDetail"),
                .external(name: "ComposableArchitecture")
            ]
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
        ),
    ]
)
