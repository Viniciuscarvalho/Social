import ProjectDescription

let project = Project(
  name: "Data",
  targets: [
    .target(
      name: "Data",
      destinations: .iOS,
      product: .framework,
      bundleId: "dev.tuist.Data",
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "Domain", path: .relativeToRoot("Domain"))
      ]
    )
  ]
)

