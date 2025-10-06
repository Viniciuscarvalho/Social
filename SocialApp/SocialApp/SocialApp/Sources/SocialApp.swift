import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct SocialApp: App {
    @State private var themeManager = ThemeManager.shared
    @StateObject private var authManager = AuthManager()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    if authManager.isAuthenticated {
                        ContentView()
                            .environmentObject(authManager)
                            .preferredColorScheme(themeManager.colorScheme)
                            .ignoresSafeArea(.keyboard)
                    } else if authManager.isFirstLaunch {
                        OnboardingView()
                            .environmentObject(authManager)
                    } else {
                        SignInView()
                            .environmentObject(authManager)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(DataManager.shared.modelContainer)
        .environment(themeManager)
    }
}

struct ContentView: View {
    var body: some View {
        SocialAppView(
            store: Store(initialState: SocialAppFeature.State()) {
                SocialAppFeature()
            }
        )
    }
}

// Extensão para registrar as dependências do TCA
extension SocialAppView {
    public static func withDependencies() -> SocialAppView {
        return SocialAppView(
            store: Store(initialState: SocialAppFeature.State()) {
                SocialAppFeature()
            } withDependencies: {
                $0.favoritesClient = .liveValue
                $0.eventsClient = .liveValue
            }
        )
    }
}

