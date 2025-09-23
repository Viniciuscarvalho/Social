import ProjectDescription

let project = Project(
    name: "SellerProfile",
    targets: [
        .target(
            name: "SellerProfile",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.SellerProfile",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "ComposableArchitecture"),
                .project(target: "SharedModels", path: "../../../SharedModels", status: .required)
            ]
        )
    ]
)