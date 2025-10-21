import ComposableArchitecture
import SwiftUI

@main
struct SocialApp: App {
    var body: some Scene {
        WindowGroup {
            SocialAppView(
                store: Store(initialState: SocialAppFeature.State()) {
                    SocialAppFeature()
                }
            )
            .environment(ThemeManager.shared)
        }
    }
}
