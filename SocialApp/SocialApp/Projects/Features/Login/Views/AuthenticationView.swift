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
                if store.auth.isFirstLaunch {
                    OnboardingView(
                        onSignUpTapped: {
                            showSignUp = true
                        },
                        onSignInTapped: {
                            // Marca que não é mais primeiro lançamento
                            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            store.send(.auth(.onAppear))
                        }
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
