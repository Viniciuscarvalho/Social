import ProjectDescription

let project = Project(
  name: "DesignSystem",
  targets: [
    .target(
      name: "DesignSystem",
      destinations: .iOS,
      product: .framework,
      bundleId: "dev.tuist.DesignSystem",
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: []
    )
  ]
)

