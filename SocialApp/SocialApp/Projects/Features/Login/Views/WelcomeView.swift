import ComposableArchitecture
import SwiftUI

struct WelcomeView: View {
  @Bindable var store: StoreOf<SocialAppFeature>
  @State private var showSignIn = false
  @State private var showSignUp = false

  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        VStack(spacing: 4) {
          Text("SocialClub")
            .font(.system(size: 36, weight: .bold))
            .foregroundColor(.primary)

          Text("Trade your tickets easily")
            .font(.system(size: 16))
            .foregroundColor(.secondary)
        }
        .padding(.bottom, 60)

        Image(systemName: "ticket.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 200)
          .foregroundColor(.blue.opacity(0.2))
          .padding(.bottom, 60)

        Spacer()

        VStack(spacing: 16) {
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

          Button(action: {
            showSignIn = true
          }) {
            HStack(spacing: 0) {
              Text("Already have an account? ")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
              Text("Sign In")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)
            }
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
    .fullScreenCover(isPresented: $showSignIn) {
      SignInView(store: store.scope(state: \.auth.signInForm, action: \.auth.signInForm))
    }
  }
}

#Preview {
  WelcomeView(store: Store(initialState: SocialAppFeature.State()) {
    SocialAppFeature()
  })
}

