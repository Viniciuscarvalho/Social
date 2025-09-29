import SwiftUI

// MARK: - Card Styles
public struct AdaptiveCardStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: AppColors.eventCardShadow,
                radius: 4,
                x: 0,
                y: 2
            )
    }
}

public struct AdaptiveSectionStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Button Styles

public struct AdaptivePrimaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

public struct AdaptiveSecondaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Extensions
public extension View {
    func adaptiveCardStyle() -> some View {
        self.modifier(AdaptiveCardStyle())
    }
    
    func adaptiveSectionStyle() -> some View {
        self.modifier(AdaptiveSectionStyle())
    }
}

// MARK: - Text Styles
public extension Text {
    func adaptiveTitle() -> Text {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(AppColors.primaryText)
    }
    
    func adaptiveHeadline() -> Text {
        self
            .font(.headline)
            .foregroundColor(AppColors.primaryText)
    }
    
    func adaptiveSubheadline() -> Text {
        self
            .font(.subheadline)
            .foregroundColor(AppColors.secondaryText)
    }
    
    func adaptiveCaption() -> Text {
        self
            .font(.caption)
            .foregroundColor(AppColors.tertiaryText)
    }
}
