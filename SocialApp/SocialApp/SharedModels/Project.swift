import ProjectDescription

let project = Project(
    name: "SharedModels",
    targets: [
        .target(
            name: "SharedModels",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.SharedModels",
            infoPlist: .default,
            sources: ["Sources/**"]
        )
    ]
)

