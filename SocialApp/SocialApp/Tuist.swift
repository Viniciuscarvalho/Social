import ProjectDescription

let tuist = Tuist(
    fullHandle: "viniciuscarvalho789/SocialApp",
    project: .tuist(
        generationOptions: .options(
            resolveDependenciesWithSystemScm: true,
            disablePackageVersionLocking: true
        )
    )
)
