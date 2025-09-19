import ProjectDescription

let project = Project(
    name: "Parties",
    targets: [
        .target(
            name: "Parties",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Parties",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        )
    ]
)