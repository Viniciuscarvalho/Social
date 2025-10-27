import ComposableArchitecture
import SwiftUI

struct AuthenticationView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            Group {
                // Check auth status
                if isUserAuthenticated() {
                    // User is logged in and token is valid → Show Home
                    EmptyView() // This will be handled by parent view to show HomeView
                } else if store.auth.isFirstLaunch {
                    // First time using app → Show Onboarding
                    OnboardingView(
                        onSignUpTapped: {
                            markFirstLaunchDone()
                        },
                        onSignInTapped: {
                            markFirstLaunchDone()
                        }
                    )
                } else {
                    // App used before but not logged in → Show Sign In
                    SignInView(
                        store: store.scope(state: \.auth.signInForm, action: \.auth.signInForm)
                    )
                }
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
            store.send(.auth(.onAppear))
        }
    }
    
    // MARK: - Helper Methods
    
    private func isUserAuthenticated() -> Bool {
        // Check 1: UserDefaults has currentUser
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
            print("❌ AuthenticationView: Nenhum usuário armazenado")
            return false
        }
        
        // Check 2: Can decode user
        guard (try? JSONDecoder().decode(User.self, from: userData)) != nil else {
            print("❌ AuthenticationView: Falha ao decodificar usuário")
            return false
        }
        
        // Check 3: Has valid auth token
        guard let authToken = UserDefaults.standard.string(forKey: "authToken"),
              !authToken.isEmpty else {
            print("❌ AuthenticationView: Token de autenticação não encontrado ou vazio")
            return false
        }
        
        // Check 4: Has user ID
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId"),
              !userId.isEmpty else {
            print("❌ AuthenticationView: ID do usuário não encontrado ou vazio")
            return false
        }
        
        // Check 5: Has completed onboarding
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            print("⚠️ AuthenticationView: Usuário existe mas não completou onboarding")
            return false
        }
        
        print("✅ AuthenticationView: Usuário autenticado com sucesso")
        print("   • ID: \(userId)")
        print("   • Token válido: \(authToken.prefix(20))...")
        return true
    }
    
    private func markFirstLaunchDone() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        print("📝 AuthenticationView: Primeiro lançamento marcado como concluído")
    }
}
