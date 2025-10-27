import ComposableArchitecture
import SwiftData
import SwiftUI

struct OnboardingView: View {
    let onSignUpTapped: () -> Void
    let onSignInTapped: () -> Void
    
    @State private var currentPage = 0
    @State private var showSignUp = false
    
    init(onSignUpTapped: @escaping () -> Void = {}, onSignInTapped: @escaping () -> Void = {}) {
        self.onSignUpTapped = onSignUpTapped
        self.onSignInTapped = onSignInTapped
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text("SocialClub")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Trade your tickets easily")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                .padding(.bottom, 16)
                
                Spacer()
                
                // Main Image Placeholder
                VStack(spacing: 20) {
                    Image(systemName: "ticket.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .foregroundColor(.blue.opacity(0.2))
                    
                    VStack(spacing: 12) {
                        Text("Where you find someone to share your ticket")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Connect with others and trade your event tickets securely and easily.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onSignInTapped) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        +
                        Text(" Sign In")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(store: Store(initialState: SignUpForm.State()) {
                SignUpForm()
            })
        }
    }
}

#Preview {
    OnboardingView(
        onSignUpTapped: { print("Sign up tapped") },
        onSignInTapped: { print("Sign in tapped") }
    )
}
