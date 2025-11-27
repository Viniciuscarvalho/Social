import SwiftUI

// MARK: - Button Styles

/// Estilo de botão primário com gradient
public struct DSPrimaryButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.headline)
      .foregroundColor(.white)
      .padding(.horizontal, DSSpacing.lg)
      .padding(.vertical, DSSpacing.md)
      .frame(maxWidth: .infinity)
      .background(DSGradients.primary)
      .dsCornerRadius(DSRadius.buttonMedium)
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(configuration.isPressed ? 0.9 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

/// Estilo de botão secundário (outline)
public struct DSSecondaryButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.headline)
      .foregroundColor(DSColors.primary)
      .padding(.horizontal, DSSpacing.lg)
      .padding(.vertical, DSSpacing.md)
      .frame(maxWidth: .infinity)
      .background(DSColors.backgroundSecondary)
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.buttonMedium)
          .strokeBorder(DSColors.primary, lineWidth: 2)
      )
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(configuration.isPressed ? 0.8 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

/// Estilo de botão terciário (ghost/text only)
public struct DSTertiaryButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.body)
      .foregroundColor(DSColors.primary)
      .padding(.horizontal, DSSpacing.md)
      .padding(.vertical, DSSpacing.sm)
      .background(
        DSColors.primary.opacity(configuration.isPressed ? 0.15 : 0.1)
      )
      .dsCornerRadius(DSRadius.buttonSmall)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

/// Estilo de botão destrutivo (vermelho)
public struct DSDestructiveButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.headline)
      .foregroundColor(.white)
      .padding(.horizontal, DSSpacing.lg)
      .padding(.vertical, DSSpacing.md)
      .frame(maxWidth: .infinity)
      .background(DSGradients.error)
      .dsCornerRadius(DSRadius.buttonMedium)
      .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
      .opacity(configuration.isPressed ? 0.9 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

/// Estilo de botão pequeno/compacto
public struct DSCompactButtonStyle: ButtonStyle {
  
  private let variant: DSButton.Variant
  
  public init(variant: DSButton.Variant = .primary) {
    self.variant = variant
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(DSTypography.footnote)
      .foregroundColor(variant == .primary ? .white : DSColors.primary)
      .padding(.horizontal, DSSpacing.sm)
      .padding(.vertical, DSSpacing.xs)
      .background(
        variant == .primary
          ? AnyView(DSGradients.primary)
          : AnyView(DSColors.backgroundSecondary)
      )
      .overlay(
        variant == .primary ? nil :
          RoundedRectangle(cornerRadius: DSRadius.buttonSmall)
            .strokeBorder(DSColors.primary, lineWidth: 1)
      )
      .dsCornerRadius(DSRadius.buttonSmall)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .opacity(configuration.isPressed ? 0.85 : 1.0)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

// MARK: - Button Component

public struct DSButton {
  
  /// Variantes de botão
  public enum Variant {
    case primary
    case secondary
    case tertiary
    case destructive
  }
  
  /// Tamanhos de botão
  public enum Size {
    case small
    case medium
    case large
  }
}

// MARK: - Button Extensions

public extension Button {
  
  /// Aplica estilo de botão primário
  func dsPrimaryButton() -> some View {
    self.buttonStyle(DSPrimaryButtonStyle())
  }
  
  /// Aplica estilo de botão secundário
  func dsSecondaryButton() -> some View {
    self.buttonStyle(DSSecondaryButtonStyle())
  }
  
  /// Aplica estilo de botão terciário
  func dsTertiaryButton() -> some View {
    self.buttonStyle(DSTertiaryButtonStyle())
  }
  
  /// Aplica estilo de botão destrutivo
  func dsDestructiveButton() -> some View {
    self.buttonStyle(DSDestructiveButtonStyle())
  }
  
  /// Aplica estilo de botão compacto
  func dsCompactButton(variant: DSButton.Variant = .primary) -> some View {
    self.buttonStyle(DSCompactButtonStyle(variant: variant))
  }
}

// MARK: - Icon Button

public struct DSIconButton: View {
  
  private let icon: String
  private let action: () -> Void
  private let variant: Variant
  
  public enum Variant {
    case primary
    case secondary
    case ghost
    
    var foregroundColor: Color {
      switch self {
      case .primary: return .white
      case .secondary: return DSColors.primary
      case .ghost: return DSColors.textSecondary
      }
    }
    
    var backgroundColor: Color {
      switch self {
      case .primary: return DSColors.primary
      case .secondary: return DSColors.backgroundSecondary
      case .ghost: return .clear
      }
    }
  }
  
  public init(
    icon: String,
    variant: Variant = .ghost,
    action: @escaping () -> Void
  ) {
    self.icon = icon
    self.variant = variant
    self.action = action
  }
  
  public var body: some View {
    Button(action: action) {
      Image(systemName: icon)
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(variant.foregroundColor)
        .frame(width: 40, height: 40)
        .background(variant.backgroundColor)
        .dsCornerRadius(DSRadius.sm)
    }
  }
}

