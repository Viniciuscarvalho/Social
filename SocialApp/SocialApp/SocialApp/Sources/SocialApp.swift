import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct SocialApp: App {
    @State private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            SocialAppView(store: Store(initialState: SocialAppFeature.State()) {
                SocialAppFeature()
            })
            .preferredColorScheme(themeManager.colorScheme)
            .ignoresSafeArea(.keyboard)
        }
        .environment(themeManager)
    }
}

