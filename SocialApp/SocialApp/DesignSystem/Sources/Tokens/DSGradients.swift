import SwiftUI

/// Design System - Gradientes Pré-definidos
public struct DSGradients {
  
  // MARK: - Background Gradients
  
  /// Gradiente de background principal (top to bottom)
  public static var backgroundMain: LinearGradient {
    LinearGradient(
      colors: [DSColors.gradientTop, DSColors.gradientBottom],
      startPoint: .top,
      endPoint: .bottom
    )
  }
  
  /// Gradiente de background para cards
  public static var backgroundCard: LinearGradient {
    LinearGradient(
      colors: [
        DSColors.backgroundSecondary,
        DSColors.backgroundSecondary.opacity(0.95)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  // MARK: - Brand Gradients
  
  /// Gradiente primário (para botões, highlights)
  public static var primary: LinearGradient {
    LinearGradient(
      colors: [DSColors.primary, DSColors.primary.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  /// Gradiente azul (perfil, avatares)
  public static var blue: LinearGradient {
    LinearGradient(
      colors: [DSColors.accentBlue, DSColors.accentBlueDark],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  /// Gradiente verde (success, progress)
  public static var green: LinearGradient {
    LinearGradient(
      colors: [DSColors.accentGreen, DSColors.accentGreen.opacity(0.7)],
      startPoint: .leading,
      endPoint: .trailing
    )
  }
  
  // MARK: - Semantic Gradients
  
  /// Gradiente de sucesso
  public static var success: LinearGradient {
    LinearGradient(
      colors: [DSColors.success, DSColors.success.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  /// Gradiente de warning
  public static var warning: LinearGradient {
    LinearGradient(
      colors: [DSColors.warning, DSColors.warning.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  /// Gradiente de erro
  public static var error: LinearGradient {
    LinearGradient(
      colors: [DSColors.error, DSColors.error.opacity(0.8)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  // MARK: - Special Effects
  
  /// Gradiente shimmer (para loading states)
  public static var shimmer: LinearGradient {
    LinearGradient(
      colors: [
        DSColors.backgroundSecondary.opacity(0.3),
        DSColors.backgroundSecondary.opacity(0.6),
        DSColors.backgroundSecondary.opacity(0.3)
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
  }
  
  /// Gradiente glass (para glassmorphism)
  public static var glass: LinearGradient {
    LinearGradient(
      colors: [
        DSColors.glassBackground,
        DSColors.glassBackground.opacity(0.8)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
  
  // MARK: - Custom Gradient Builder
  
  /// Cria gradiente customizado com cor e opacidade
  public static func custom(
    _ color: Color,
    opacity: Double = 0.8,
    startPoint: UnitPoint = .topLeading,
    endPoint: UnitPoint = .bottomTrailing
  ) -> LinearGradient {
    LinearGradient(
      colors: [color, color.opacity(opacity)],
      startPoint: startPoint,
      endPoint: endPoint
    )
  }
  
  /// Cria gradiente com múltiplas cores
  public static func multiColor(
    _ colors: [Color],
    startPoint: UnitPoint = .topLeading,
    endPoint: UnitPoint = .bottomTrailing
  ) -> LinearGradient {
    LinearGradient(
      colors: colors,
      startPoint: startPoint,
      endPoint: endPoint
    )
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Aplica gradiente de background
  func dsBackgroundGradient(_ gradient: LinearGradient = DSGradients.backgroundMain) -> some View {
    self.background(gradient)
  }
  
  /// Aplica overlay de gradiente
  func dsOverlayGradient(_ gradient: LinearGradient) -> some View {
    self.overlay(gradient)
  }
}

