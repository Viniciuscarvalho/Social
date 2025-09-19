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
                .target(name: "Events", path: "../Events", status: .required),
                .target(name: "TicketDetail", path: "../TicketDetail", status: .required)
            ]
        )
    ]
)