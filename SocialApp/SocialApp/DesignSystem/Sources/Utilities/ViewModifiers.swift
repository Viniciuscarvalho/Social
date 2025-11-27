import SwiftUI

// MARK: - Corner Radius

public extension View {
  
  /// Aplica corner radius do Design System
  func dsCornerRadius(_ radius: CGFloat, corners: UIRectCorner = .allCorners) -> some View {
    self.clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

/// Shape para corner radius customizado
struct RoundedCorner: Shape {
  var radius: CGFloat
  var corners: UIRectCorner

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

// MARK: - Shadow

public extension View {
  
  /// Shadow leve
  func dsLightShadow() -> some View {
    self.shadow(
      color: Color.black.opacity(0.08),
      radius: 4,
      x: 0,
      y: 2
    )
  }
  
  /// Shadow média
  func dsMediumShadow() -> some View {
    self.shadow(
      color: Color.black.opacity(0.12),
      radius: 8,
      x: 0,
      y: 4
    )
  }
  
  /// Shadow forte
  func dsStrongShadow() -> some View {
    self.shadow(
      color: Color.black.opacity(0.18),
      radius: 16,
      x: 0,
      y: 8
    )
  }
  
  /// Shadow de card
  func dsCardShadow() -> some View {
    self.shadow(
      color: Color.black.opacity(0.1),
      radius: 8,
      x: 0,
      y: 2
    )
  }
}

// MARK: - Border

public extension View {
  
  /// Border do Design System
  func dsBorder(_ color: Color, width: CGFloat = 1, radius: CGFloat = DSRadius.md) -> some View {
    self
      .overlay(
        RoundedRectangle(cornerRadius: radius)
          .strokeBorder(color, lineWidth: width)
      )
  }
}

// MARK: - Card

public extension View {
  
  /// Aplica estilo de card padrão
  func dsCardStyle() -> some View {
    self
      .background(DSColors.cardBackground)
      .dsCornerRadius(DSRadius.card)
      .dsCardShadow()
  }
}

// MARK: - Skeleton Loading

public extension View {
  
  /// Aplica efeito de skeleton loading
  func dsSkeleton(isLoading: Bool, cornerRadius: CGFloat = DSRadius.sm) -> some View {
    self.modifier(SkeletonModifier(isLoading: isLoading, cornerRadius: cornerRadius))
  }
}

struct SkeletonModifier: ViewModifier {
  let isLoading: Bool
  let cornerRadius: CGFloat
  
  @State private var animationPhase: CGFloat = 0
  
  func body(content: Content) -> some View {
    content
      .opacity(isLoading ? 0.3 : 1)
      .overlay {
        if isLoading {
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
              LinearGradient(
                colors: [
                  DSColors.tertiaryBackground,
                  DSColors.secondaryBackground,
                  DSColors.tertiaryBackground
                ],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .offset(x: animationPhase)
            .onAppear {
              withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
              ) {
                animationPhase = 300
              }
            }
        }
      }
  }
}

