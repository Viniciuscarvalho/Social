import ProjectDescription

let project = Project(
    name: "TicketsList",
    targets: [
        .target(
            name: "TicketsList",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.TicketsList",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "SharedModels", path: "../../../SharedModels", status: .required)
            ]
        )
    ]
)