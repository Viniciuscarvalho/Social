import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {
  let onComplete: () -> Void

  @State private var currentPage = 0

  private let pages: [OnboardingPage] = [
    OnboardingPage(
      icon: "ticket.fill",
      title: "Welcome to SocialClub",
      subtitle: "Your smart assistant and discover unforgettable events around you and trade tickets.",
      primaryColor: .blue
    ),
    OnboardingPage(
      icon: "calendar.badge.plus",
      title: "Create Tickets in Seconds",
      subtitle: "Tell us what you need, our AI builds the schedule, and suggests venues.",
      primaryColor: .purple
    ),
    OnboardingPage(
      icon: "person.3.fill",
      title: "Join Smarter Events",
      subtitle: "Join and connect with the right crowd. Trade your tickets easily.",
      primaryColor: .green
    )
  ]

  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          Spacer()
          Button(action: {
            onComplete()
          }) {
            Text("Skip")
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(AppColors.primary)
              .padding(.horizontal, 20)
              .padding(.vertical, 12)
          }
        }
        .padding(.top, 16)

        TabView(selection: $currentPage) {
          ForEach(0..<pages.count, id: \.self) { index in
            OnboardingPageView(page: pages[index])
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))

        VStack(spacing: 12) {
          Button(action: {
            if currentPage < pages.count - 1 {
              withAnimation {
                currentPage += 1
              }
            } else {
              onComplete()
            }
          }) {
            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(AppColors.primary)
              .cornerRadius(12)
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
      }
    }
  }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
  let icon: String
  let title: String
  let subtitle: String
  let primaryColor: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
  let page: OnboardingPage

  var body: some View {
    VStack(spacing: 30) {
      Spacer()

      Image(systemName: page.icon)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 200)
        .foregroundColor(page.primaryColor)

      VStack(spacing: 16) {
        Text(page.title)
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)

        Text(page.subtitle)
          .font(.system(size: 16))
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }

      Spacer()
    }
    .padding(.horizontal, 20)
  }
}

#Preview {
  OnboardingView(onComplete: {})
}
