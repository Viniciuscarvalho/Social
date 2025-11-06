import ComposableArchitecture
import SwiftUI

struct AuthenticationView: View {
  @Bindable var store: StoreOf<SocialAppFeature>
  @State private var hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

  @ViewBuilder
  private var contentView: some View {
    if isUserAuthenticated() {
      EmptyView()
    } else {
      if !hasSeenOnboarding {
        OnboardingView(onComplete: {
          markOnboardingAsSeen()
          hasSeenOnboarding = true
        })
      } else {
        WelcomeView(store: store)
      }
    }
  }

  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()

      contentView

      if let verification = store.verification {
        VerificationView(
          store: Store(
            initialState: verification,
            reducer: { VerificationFeature() }
          )
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .alert("Erro", isPresented: .constant(store.auth.errorMessage != nil)) {
      Button("OK") {
        store.send(.auth(.clearError))
      }
    } message: {
      if let errorMessage = store.auth.errorMessage {
        Text(errorMessage)
      }
    }
    .onAppear {
      hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
      store.send(.auth(.onAppear))
    }
  }

  // MARK: - Helper Methods

  private func isUserAuthenticated() -> Bool {
    guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
      return false
    }

    guard (try? JSONDecoder().decode(User.self, from: userData)) != nil else {
      return false
    }

    guard let authToken = UserDefaults.standard.string(forKey: "authToken"),
          !authToken.isEmpty else {
      return false
    }

    guard let userId = UserDefaults.standard.string(forKey: "currentUserId"),
          !userId.isEmpty else {
      return false
    }

    let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    if !hasLaunchedBefore {
      return false
    }

    return true
  }

  private func markOnboardingAsSeen() {
    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
  }
}
