import ComposableArchitecture
import SwiftUI

struct AuthenticationView: View {
    @Bindable var store: StoreOf<SocialAppFeature>
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            Group {
                if store.isFirstLaunch {
                    OnboardingView {
                        showSignUp = false
                    }
                } else {
                    SignInView(
                        store: store.scope(state: \.auth.signInForm, action: \.auth.signInForm)
                    )
                    .fullScreenCover(isPresented: $showSignUp) {
                        ZStack {
                            AppColors.backgroundGradient
                                .ignoresSafeArea()
                            
                            SignUpView(
                                store: store.scope(state: \.auth.signUpForm, action: \.auth.signUpForm)
                            )
                        }
                    }
                }
            }
        }
        .overlay(
            Group {
                if store.auth.isLoading {
                    LoadingView()
                }
            }
        )
        .alert("Erro", isPresented: .constant(store.auth.errorMessage != nil)) {
            Button("OK") {
                store.send(.auth(.clearError))
            }
        } message: {
            if let errorMessage = store.auth.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Supporting Views

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Carregando...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
    }
}
