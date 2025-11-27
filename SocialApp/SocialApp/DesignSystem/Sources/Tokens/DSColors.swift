import SwiftUI

/// Design System - Tokens de Cores
/// Baseado no Aivent Mobile App UI Kit e adaptado para light/dark mode
public struct DSColors {
  
  // MARK: - Brand Colors (Primary)
  
  public static let primary = Color.accentColor
  public static let secondary = Color(.systemBlue)
  
  // MARK: - Background Colors
  
  /// Background principal do app
  public static let background = Color(.systemBackground)
  
  /// Background secundário (cards, sections)
  public static let backgroundSecondary = Color(.secondarySystemBackground)
  
  /// Background terciário (input fields, etc)
  public static let backgroundTertiary = Color(.tertiarySystemBackground)
  
  /// Background para listas agrupadas
  public static let backgroundGrouped = Color(.systemGroupedBackground)
  public static let backgroundGroupedSecondary = Color(.secondarySystemGroupedBackground)
  
  // MARK: - Text Colors
  
  /// Texto principal
  public static let textPrimary = Color(.label)
  
  /// Texto secundário (subtítulos, labels)
  public static let textSecondary = Color(.secondaryLabel)
  
  /// Texto terciário (placeholders, hints)
  public static let textTertiary = Color(.tertiaryLabel)
  
  /// Texto quaternário (disabled, muito sutil)
  public static let textQuaternary = Color(.quaternaryLabel)
  
  // MARK: - Border Colors
  
  /// Borda padrão
  public static var border: Color {
    Color(
      light: Color.black.opacity(0.1),
      dark: Color.white.opacity(0.15)
    )
  }
  
  /// Borda sutil/light
  public static var borderLight: Color {
    Color(
      light: Color.black.opacity(0.05),
      dark: Color.white.opacity(0.08)
    )
  }
  
  /// Borda forte/destacada
  public static var borderStrong: Color {
    Color(
      light: Color.black.opacity(0.2),
      dark: Color.white.opacity(0.25)
    )
  }
  
  // MARK: - Separator Colors
  
  public static let separator = Color(.separator)
  public static let separatorOpaque = Color(.opaqueSeparator)
  
  // MARK: - Semantic Colors (Status)
  
  /// Sucesso
  public static let success = Color(.systemGreen)
  
  /// Aviso/Warning
  public static let warning = Color(.systemOrange)
  
  /// Erro/Danger
  public static let error = Color(.systemRed)
  
  /// Informação
  public static let info = Color(.systemBlue)
  
  // MARK: - Accent Colors (Custom Brand)
  
  /// Verde limão accent (success alternativo)
  public static let accentGreen = Color(hex: "a0f064")
  
  /// Azul vibrante
  public static let accentBlue = Color(hex: "4a90e2")
  
  /// Azul escuro (para gradientes)
  public static let accentBlueDark = Color(hex: "357abd")
  
  /// Vermelho para favoritos
  public static let favoriteRed = Color(.systemPink)
  
  // MARK: - Glassmorphism Colors
  
  /// Background com efeito glass
  public static var glassBackground: Color {
    Color(
      light: Color.white.opacity(0.7),
      dark: Color.white.opacity(0.05)
    )
  }
  
  /// Borda com efeito glass
  public static var glassBorder: Color {
    Color(
      light: Color.black.opacity(0.1),
      dark: Color.white.opacity(0.1)
    )
  }
  
  // MARK: - Gradient Colors
  
  /// Gradient background - Top
  public static var gradientTop: Color {
    Color(
      light: Color(hex: "F5F5F7"),
      dark: Color(hex: "1a1a2e")
    )
  }
  
  /// Gradient background - Bottom
  public static var gradientBottom: Color {
    Color(
      light: Color(hex: "E8E8ED"),
      dark: Color(hex: "0f0f1e")
    )
  }
  
  // MARK: - Shadow & Overlay Colors
  
  /// Sombra de card
  public static var shadow: Color {
    Color(
      light: Color.black.opacity(0.1),
      dark: Color.black.opacity(0.3)
    )
  }
  
  /// Overlay escuro (para modals, etc)
  public static var overlay: Color {
    Color.black.opacity(0.4)
  }
  
  // MARK: - Badge & Icon Colors
  
  /// Badge de verificado
  public static let badgeVerified = Color(hex: "4a90e2")
  
  /// Badge de troféu/conquista
  public static let badgeTrophy = Color(.systemOrange)
  
  /// Background de ícone circular (função helper)
  public static func iconCircleBackground(_ color: Color, opacity: Double = 0.15) -> Color {
    color.opacity(opacity)
  }
}

// MARK: - Color Hex Helper

extension Color {
  /// Inicializa Color a partir de string hexadecimal
  /// - Parameter hex: String no formato "RRGGBB" ou "#RRGGBB"
  init(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)
    
    let r = Double((rgb & 0xFF0000) >> 16) / 255.0
    let g = Double((rgb & 0x00FF00) >> 8) / 255.0
    let b = Double(rgb & 0x0000FF) / 255.0
    
    self.init(red: r, green: g, blue: b)
  }
  
  /// Inicializa Color com cores diferentes para light e dark mode
  init(light: Color, dark: Color) {
    self.init(UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark:
        return UIColor(dark)
      default:
        return UIColor(light)
      }
    })
  }
}

// MARK: - Convenience Extensions

public extension Color {
  // Background
  static let dsBackground = DSColors.background
  static let dsBackgroundSecondary = DSColors.backgroundSecondary
  static let dsBackgroundTertiary = DSColors.backgroundTertiary
  
  // Text
  static let dsTextPrimary = DSColors.textPrimary
  static let dsTextSecondary = DSColors.textSecondary
  static let dsTextTertiary = DSColors.textTertiary
  
  // Semantic
  static let dsSuccess = DSColors.success
  static let dsWarning = DSColors.warning
  static let dsError = DSColors.error
  static let dsInfo = DSColors.info
  
  // Accent
  static let dsAccentGreen = DSColors.accentGreen
  static let dsAccentBlue = DSColors.accentBlue
  
  // Glass
  static let dsGlass = DSColors.glassBackground
}

