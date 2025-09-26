import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct SocialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(DataManager.shared.modelContainer)
        }
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
                $0.eventsClient = .liveValue // Assumindo que você já tem isso configurado
            }
        )
    }
}

