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
            dependencies: []
        )
    ]
)