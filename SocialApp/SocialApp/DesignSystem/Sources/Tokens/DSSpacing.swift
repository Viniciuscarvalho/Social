import SwiftUI

/// Design System - Tokens de Espaçamento
/// Define escala de espaçamento consistente (baseado em múltiplos de 4)
public struct DSSpacing {
  
  // MARK: - Base Unit
  
  /// Unidade base de espaçamento (4pt)
  private static let baseUnit: CGFloat = 4
  
  // MARK: - Spacing Scale
  
  /// 0pt - Sem espaçamento
  public static let none: CGFloat = 0
  
  /// 2pt - Espaçamento mínimo
  public static let xxxs: CGFloat = baseUnit * 0.5  // 2
  
  /// 4pt - Extra extra small
  public static let xxs: CGFloat = baseUnit * 1  // 4
  
  /// 8pt - Extra small
  public static let xs: CGFloat = baseUnit * 2  // 8
  
  /// 12pt - Small
  public static let sm: CGFloat = baseUnit * 3  // 12
  
  /// 16pt - Medium (padrão mais comum)
  public static let md: CGFloat = baseUnit * 4  // 16
  
  /// 20pt - Large
  public static let lg: CGFloat = baseUnit * 5  // 20
  
  /// 24pt - Extra large
  public static let xl: CGFloat = baseUnit * 6  // 24
  
  /// 32pt - Extra extra large
  public static let xxl: CGFloat = baseUnit * 8  // 32
  
  /// 40pt - Extra extra extra large
  public static let xxxl: CGFloat = baseUnit * 10  // 40
  
  /// 48pt - Huge
  public static let huge: CGFloat = baseUnit * 12  // 48
  
  // MARK: - Semantic Spacing
  
  /// Padding interno de componentes pequenos (8pt)
  public static let componentPaddingSmall = xs
  
  /// Padding interno de componentes médios (12pt)
  public static let componentPaddingMedium = sm
  
  /// Padding interno de componentes grandes (16pt)
  public static let componentPaddingLarge = md
  
  /// Espaçamento entre elementos em stack horizontal/vertical (12pt)
  public static let stackSpacing = sm
  
  /// Espaçamento entre sections (24pt)
  public static let sectionSpacing = xl
  
  /// Padding horizontal padrão de tela (16pt)
  public static let screenPaddingHorizontal = md
  
  /// Padding vertical padrão de tela (16pt)
  public static let screenPaddingVertical = md
  
  /// Padding de card (16pt)
  public static let cardPadding = md
  
  /// Espaçamento entre cards (12pt)
  public static let cardSpacing = sm
  
  /// Margem de lista (16pt)
  public static let listMargin = md
  
  /// Espaçamento entre linhas de lista (8pt)
  public static let listItemSpacing = xs
}

// MARK: - Corner Radius Tokens

public struct DSRadius {
  
  // MARK: - Radius Scale
  
  /// 0pt - Sem arredondamento
  public static let none: CGFloat = 0
  
  /// 2pt - Radius mínimo
  public static let xxxs: CGFloat = 2
  
  /// 4pt - Extra small
  public static let xxs: CGFloat = 4
  
  /// 6pt - Small
  public static let xs: CGFloat = 6
  
  /// 8pt - Small/Medium
  public static let sm: CGFloat = 8
  
  /// 12pt - Medium (padrão para cards)
  public static let md: CGFloat = 12
  
  /// 16pt - Large
  public static let lg: CGFloat = 16
  
  /// 20pt - Extra large
  public static let xl: CGFloat = 20
  
  /// 24pt - Extra extra large
  public static let xxl: CGFloat = 24
  
  /// 32pt - Huge
  public static let huge: CGFloat = 32
  
  /// Círculo perfeito (muito grande)
  public static let circle: CGFloat = 999
  
  // MARK: - Semantic Radius
  
  /// Radius de botões pequenos (8pt)
  public static let buttonSmall = sm
  
  /// Radius de botões médios (12pt)
  public static let buttonMedium = md
  
  /// Radius de botões grandes (16pt)
  public static let buttonLarge = lg
  
  /// Radius de cards (12pt)
  public static let card = md
  
  /// Radius de input fields (8pt)
  public static let input = sm
  
  /// Radius de modal/sheet (20pt)
  public static let modal = xl
  
  /// Radius de badge (circle/pill shape)
  public static let badge = circle
}

// MARK: - Shadow Tokens

public struct DSShadow {
  
  public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
      self.color = color
      self.radius = radius
      self.x = x
      self.y = y
    }
  }
  
  /// Sem sombra
  public static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
  
  /// Sombra pequena (cards, botões)
  public static let sm = ShadowStyle(
    color: DSColors.shadow,
    radius: 4,
    x: 0,
    y: 2
  )
  
  /// Sombra média (cards flutuantes)
  public static let md = ShadowStyle(
    color: DSColors.shadow,
    radius: 8,
    x: 0,
    y: 4
  )
  
  /// Sombra grande (modals, sheets)
  public static let lg = ShadowStyle(
    color: DSColors.shadow,
    radius: 16,
    x: 0,
    y: 8
  )
  
  /// Sombra extra grande (elementos muito destacados)
  public static let xl = ShadowStyle(
    color: DSColors.shadow,
    radius: 24,
    x: 0,
    y: 12
  )
}

// MARK: - View Extensions

public extension View {
  
  /// Aplica padding padrão de tela
  func dsScreenPadding() -> some View {
    self.padding(.horizontal, DSSpacing.screenPaddingHorizontal)
      .padding(.vertical, DSSpacing.screenPaddingVertical)
  }
  
  /// Aplica padding de card
  func dsCardPadding() -> some View {
    self.padding(DSSpacing.cardPadding)
  }
  
  /// Aplica sombra do design system
  func dsShadow(_ style: DSShadow.ShadowStyle = .sm) -> some View {
    self.shadow(
      color: style.color,
      radius: style.radius,
      x: style.x,
      y: style.y
    )
  }
  
  /// Aplica corner radius do design system
  func dsCornerRadius(_ radius: CGFloat = DSRadius.md) -> some View {
    self.clipShape(RoundedRectangle(cornerRadius: radius))
  }
}

