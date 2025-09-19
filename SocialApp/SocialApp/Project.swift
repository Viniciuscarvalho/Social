import ProjectDescription

let project = Project(
    name: "SocialApp",
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
                .project(target: "Events", path: "Projects/Features/Events"),
                .project(target: "TicketsList", path: "Projects/Features/TicketsList"),
                .project(target: "TicketDetail", path: "Projects/Features/TicketDetail"),
                .project(target: "SellerProfile", path: "Projects/Features/SellerProfile"),
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
