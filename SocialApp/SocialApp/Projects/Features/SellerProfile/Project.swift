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
                .project(target: "SharedModels", path: "../../../SharedModels", status: .required)
            ]
        )
    ]
)