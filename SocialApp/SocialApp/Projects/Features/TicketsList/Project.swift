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
                .project(target: "Events", path: "../Events", status: .required),
                .project(target: "TicketDetail", path: "../TicketDetail", status: .required)
            ]
        )
    ]
)