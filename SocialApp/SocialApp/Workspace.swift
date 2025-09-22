import ProjectDescription

let workspace = Workspace(
    name: "SocialApp",
    projects: [
        ".",
        "SharedModels",
        "Projects/Features/Events",
        "Projects/Features/TicketsList",
        "Projects/Features/SellerProfile",
        "Projects/Features/TicketDetail"
    ]
)