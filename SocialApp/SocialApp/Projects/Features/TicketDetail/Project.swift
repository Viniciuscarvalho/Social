import ProjectDescription

let project = Project(
    name: "TicketDetail",
    targets: [
        .target(
            name: "TicketDetail",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.TicketDetail",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "SharedModels", path: "../../../SharedModels", status: .required)
            ]
        )
    ]
)