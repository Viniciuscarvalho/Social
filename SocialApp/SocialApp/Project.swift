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
            sources: [
                "SocialApp/Sources/**"
            ],
            resources: [
                "SocialApp/Resources/**"
            ],
            dependencies: [
                .project(target: "TicketsList", path: "Projects/Features/TicketsList", status: .required),
                .project(target: "TicketDetail", path: "Projects/Features/TicketDetail", status: .required),
                .project(target: "SellerProfile", path: "Projects/Features/SellerProfile", status: .required),
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
