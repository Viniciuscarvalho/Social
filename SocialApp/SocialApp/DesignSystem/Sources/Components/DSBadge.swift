import SwiftUI

// MARK: - Badge Component

public struct DSBadge: View {
  
  private let text: String
  private let style: BadgeStyle
  private let size: BadgeSize
  
  public enum BadgeStyle {
    case primary
    case secondary
    case success
    case warning
    case error
    case info
    case custom(background: Color, foreground: Color)
    
    var backgroundColor: Color {
      switch self {
      case .primary: return DSColors.primary
      case .secondary: return DSColors.secondary
      case .success: return DSColors.success
      case .warning: return DSColors.warning
      case .error: return DSColors.error
      case .info: return DSColors.accentBlue
      case .custom(let bg, _): return bg
      }
    }
    
    var foregroundColor: Color {
      switch self {
      case .primary, .secondary, .success, .warning, .error, .info:
        return .white
      case .custom(_, let fg):
        return fg
      }
    }
  }
  
  public enum BadgeSize {
    case small
    case medium
    case large
    
    var font: Font {
      switch self {
      case .small: return DSTypography.caption2(weight: .semibold)
      case .medium: return DSTypography.caption(weight: .semibold)
      case .large: return DSTypography.footnote(weight: .semibold)
      }
    }
    
    var horizontalPadding: CGFloat {
      switch self {
      case .small: return DSSpacing.xs
      case .medium: return DSSpacing.s
      case .large: return DSSpacing.sm
      }
    }
    
    var verticalPadding: CGFloat {
      switch self {
      case .small: return DSSpacing.xxs
      case .medium: return DSSpacing.xs
      case .large: return DSSpacing.xs
      }
    }
  }
  
  public init(
    _ text: String,
    style: BadgeStyle = .primary,
    size: BadgeSize = .medium
  ) {
    self.text = text
    self.style = style
    self.size = size
  }
  
  public var body: some View {
    Text(text)
      .font(size.font)
      .foregroundColor(style.foregroundColor)
      .padding(.horizontal, size.horizontalPadding)
      .padding(.vertical, size.verticalPadding)
      .background(style.backgroundColor)
      .dsCornerRadius(DSRadius.badge)
  }
}

// MARK: - Status Badge

public struct DSStatusBadge: View {
  
  private let status: String
  private let color: Color
  
  public init(status: String, color: Color) {
    self.status = status
    self.color = color
  }
  
  public var body: some View {
    HStack(spacing: DSSpacing.xs) {
      Circle()
        .fill(color)
        .frame(width: 6, height: 6)
      
      Text(status)
        .font(DSTypography.caption(weight: .medium))
        .foregroundColor(DSColors.textPrimary)
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.vertical, DSSpacing.xs)
    .background(DSColors.backgroundSecondary)
    .dsCornerRadius(DSRadius.badge)
  }
}

// MARK: - Number Badge (Notification Count)

public struct DSNumberBadge: View {
  
  private let count: Int
  private let maxCount: Int
  
  public init(count: Int, maxCount: Int = 99) {
    self.count = count
    self.maxCount = maxCount
  }
  
  private var displayText: String {
    count > maxCount ? "\(maxCount)+" : "\(count)"
  }
  
  public var body: some View {
    if count > 0 {
      Text(displayText)
        .font(DSTypography.caption2(weight: .bold))
        .foregroundColor(.white)
        .padding(.horizontal, count > 9 ? DSSpacing.xs : DSSpacing.xxs)
        .padding(.vertical, DSSpacing.xxs)
        .background(DSColors.error)
        .dsCornerRadius(DSRadius.circle)
        .frame(minWidth: 18, minHeight: 18)
    }
  }
}

// MARK: - Icon Badge

public struct DSIconBadge: View {
  
  private let icon: String
  private let style: DSBadge.BadgeStyle
  private let size: CGFloat
  
  public init(
    icon: String,
    style: DSBadge.BadgeStyle = .primary,
    size: CGFloat = 32
  ) {
    self.icon = icon
    self.style = style
    self.size = size
  }
  
  public var body: some View {
    Image(systemName: icon)
      .font(.system(size: size * 0.5, weight: .semibold))
      .foregroundColor(style.foregroundColor)
      .frame(width: size, height: size)
      .background(style.backgroundColor)
      .dsCornerRadius(size / 4)
  }
}

// MARK: - Tag (Pill-shaped Badge)

public struct DSTag: View {
  
  private let text: String
  private let isSelected: Bool
  private let action: (() -> Void)?
  
  public init(
    _ text: String,
    isSelected: Bool = false,
    action: (() -> Void)? = nil
  ) {
    self.text = text
    self.isSelected = isSelected
    self.action = action
  }
  
  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          tagContent
        }
      } else {
        tagContent
      }
    }
  }
  
  private var tagContent: some View {
    Text(text)
      .font(DSTypography.footnote(weight: .medium))
      .foregroundColor(isSelected ? .white : DSColors.textSecondary)
      .padding(.horizontal, DSSpacing.sm)
      .padding(.vertical, DSSpacing.xs)
      .background(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
      .dsCornerRadius(DSRadius.circle)
      .overlay(
        RoundedRectangle(cornerRadius: DSRadius.circle)
          .strokeBorder(
            isSelected ? Color.clear : DSColors.border,
            lineWidth: 1
          )
      )
  }
}

