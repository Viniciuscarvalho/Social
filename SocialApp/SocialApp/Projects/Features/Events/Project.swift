import ProjectDescription

let project = Project(
    name: "Events",
    targets: [
        .target(
            name: "Events",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Events",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)