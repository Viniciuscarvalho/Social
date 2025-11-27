import SwiftUI

/// Design System - Tokens de Tipografia
/// Define escala tipográfica consistente baseada no iOS Human Interface Guidelines
public struct DSTypography {
  
  // MARK: - Font Sizes
  
  /// Tamanhos de fonte padronizados
  public enum Size {
    /// 34pt - Títulos grandes
    case largeTitle
    /// 28pt - Títulos de seção
    case title1
    /// 22pt - Títulos secundários
    case title2
    /// 20pt - Títulos terciários
    case title3
    /// 17pt - Headline, destaque
    case headline
    /// 17pt - Body padrão
    case body
    /// 16pt - Callout
    case callout
    /// 15pt - Subheadline
    case subheadline
    /// 13pt - Footnote
    case footnote
    /// 12pt - Caption 1
    case caption1
    /// 11pt - Caption 2
    case caption2
    
    var systemFont: Font {
      switch self {
      case .largeTitle: return .largeTitle
      case .title1: return .title
      case .title2: return .title2
      case .title3: return .title3
      case .headline: return .headline
      case .body: return .body
      case .callout: return .callout
      case .subheadline: return .subheadline
      case .footnote: return .footnote
      case .caption1: return .caption
      case .caption2: return .caption2
      }
    }
  }
  
  // MARK: - Font Weights
  
  public enum Weight {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black
    
    var fontWeight: Font.Weight {
      switch self {
      case .ultraLight: return .ultraLight
      case .thin: return .thin
      case .light: return .light
      case .regular: return .regular
      case .medium: return .medium
      case .semibold: return .semibold
      case .bold: return .bold
      case .heavy: return .heavy
      case .black: return .black
      }
    }
  }
  
  // MARK: - Predefined Styles
  
  /// Título grande (LargeTitle + Bold)
  public static let largeTitle = Font.largeTitle.weight(.bold)
  
  /// Título principal (Title1 + Bold)
  public static let title1 = Font.title.weight(.bold)
  
  /// Título secundário (Title2 + Bold)
  public static let title2 = Font.title2.weight(.bold)
  
  /// Título terciário (Title3 + Semibold)
  public static let title3 = Font.title3.weight(.semibold)
  
  /// Headline (Headline + Semibold)
  public static let headline = Font.headline.weight(.semibold)
  
  /// Body padrão (Body + Regular)
  public static let body = Font.body
  
  /// Body ênfase (Body + Medium)
  public static let bodyEmphasized = Font.body.weight(.medium)
  
  /// Callout (Callout + Regular)
  public static let callout = Font.callout
  
  /// Subheadline (Subheadline + Regular)
  public static let subheadline = Font.subheadline
  
  /// Footnote (Footnote + Regular)
  public static let footnote = Font.footnote
  
  /// Caption 1 (Caption + Regular)
  public static let caption1 = Font.caption
  
  /// Caption 2 (Caption2 + Regular)
  public static let caption2 = Font.caption2
  
  // MARK: - Helper Methods
  
  /// Cria uma fonte customizada com tamanho e peso específicos
  public static func font(size: Size, weight: Weight) -> Font {
    size.systemFont.weight(weight.fontWeight)
  }
}

// MARK: - Text Style Extensions

public extension Text {
  
  // MARK: - Titles
  
  /// Aplica estilo de large title
  func dsLargeTitle() -> Text {
    self
      .font(DSTypography.largeTitle)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de title 1
  func dsTitle1() -> Text {
    self
      .font(DSTypography.title1)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de title 2
  func dsTitle2() -> Text {
    self
      .font(DSTypography.title2)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de title 3
  func dsTitle3() -> Text {
    self
      .font(DSTypography.title3)
      .foregroundColor(DSColors.textPrimary)
  }
  
  // MARK: - Body & Content
  
  /// Aplica estilo de headline
  func dsHeadline() -> Text {
    self
      .font(DSTypography.headline)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de body
  func dsBody() -> Text {
    self
      .font(DSTypography.body)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de body com ênfase
  func dsBodyEmphasized() -> Text {
    self
      .font(DSTypography.bodyEmphasized)
      .foregroundColor(DSColors.textPrimary)
  }
  
  /// Aplica estilo de callout
  func dsCallout() -> Text {
    self
      .font(DSTypography.callout)
      .foregroundColor(DSColors.textSecondary)
  }
  
  /// Aplica estilo de subheadline
  func dsSubheadline() -> Text {
    self
      .font(DSTypography.subheadline)
      .foregroundColor(DSColors.textSecondary)
  }
  
  // MARK: - Small Text
  
  /// Aplica estilo de footnote
  func dsFootnote() -> Text {
    self
      .font(DSTypography.footnote)
      .foregroundColor(DSColors.textTertiary)
  }
  
  /// Aplica estilo de caption
  func dsCaption() -> Text {
    self
      .font(DSTypography.caption1)
      .foregroundColor(DSColors.textTertiary)
  }
  
  /// Aplica estilo de caption 2 (menor)
  func dsCaption2() -> Text {
    self
      .font(DSTypography.caption2)
      .foregroundColor(DSColors.textTertiary)
  }
}

