import SwiftUI

// MARK: - List Cell Component

/// Célula de lista padrão com ícone, título, subtítulo e acessórios
public struct DSListCell: View {
  
  private let icon: String?
  private let iconColor: Color?
  private let title: String
  private let subtitle: String?
  private let badge: String?
  private let accessory: Accessory
  private let action: (() -> Void)?
  
  public enum Accessory {
    case none
    case chevron
    case checkmark
    case toggle(Binding<Bool>)
    case custom(AnyView)
  }
  
  public init(
    icon: String? = nil,
    iconColor: Color? = nil,
    title: String,
    subtitle: String? = nil,
    badge: String? = nil,
    accessory: Accessory = .none,
    action: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.iconColor = iconColor
    self.title = title
    self.subtitle = subtitle
    self.badge = badge
    self.accessory = accessory
    self.action = action
  }
  
  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          cellContent
        }
        .buttonStyle(.plain)
      } else {
        cellContent
      }
    }
  }
  
  private var cellContent: some View {
    HStack(spacing: DSSpacing.sm) {
      // Ícone (opcional)
      if let icon = icon {
        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(iconColor ?? DSColors.primary)
          .frame(width: 28, height: 28)
      }
      
      // Conteúdo principal
      VStack(alignment: .leading, spacing: DSSpacing.xxs) {
        HStack(spacing: DSSpacing.xs) {
          Text(title)
            .font(DSTypography.body(weight: .medium))
            .foregroundColor(DSColors.textPrimary)
          
          if let badge = badge {
            DSBadge(badge, size: .small)
          }
        }
        
        if let subtitle = subtitle {
          Text(subtitle)
            .font(DSTypography.footnote())
            .foregroundColor(DSColors.textSecondary)
        }
      }
      
      Spacer()
      
      // Acessório
      accessoryView
    }
    .padding(.horizontal, DSSpacing.m)
    .padding(.vertical, DSSpacing.sm)
  }
  
  @ViewBuilder
  private var accessoryView: some View {
    switch accessory {
    case .none:
      EmptyView()
    case .chevron:
      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(DSColors.textTertiary)
    case .checkmark:
      Image(systemName: "checkmark")
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(DSColors.primary)
    case .toggle(let binding):
      Toggle("", isOn: binding)
        .labelsHidden()
    case .custom(let view):
      view
    }
  }
}

// MARK: - Avatar List Cell

public struct DSAvatarListCell: View {
  
  private let avatarURL: String?
  private let avatarInitials: String?
  private let title: String
  private let subtitle: String?
  private let badge: String?
  private let isVerified: Bool
  private let action: (() -> Void)?
  
  public init(
    avatarURL: String? = nil,
    avatarInitials: String? = nil,
    title: String,
    subtitle: String? = nil,
    badge: String? = nil,
    isVerified: Bool = false,
    action: (() -> Void)? = nil
  ) {
    self.avatarURL = avatarURL
    self.avatarInitials = avatarInitials
    self.title = title
    self.subtitle = subtitle
    self.badge = badge
    self.isVerified = isVerified
    self.action = action
  }
  
  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          cellContent
        }
        .buttonStyle(.plain)
      } else {
        cellContent
      }
    }
  }
  
  private var cellContent: some View {
    HStack(spacing: DSSpacing.sm) {
      // Avatar
      avatarView
      
      // Conteúdo
      VStack(alignment: .leading, spacing: DSSpacing.xxs) {
        HStack(spacing: DSSpacing.xs) {
          Text(title)
            .font(DSTypography.body(weight: .semibold))
            .foregroundColor(DSColors.textPrimary)
          
          if isVerified {
            Image(systemName: "checkmark.seal.fill")
              .font(.system(size: 14))
              .foregroundColor(DSColors.accentBlue)
          }
          
          if let badge = badge {
            DSBadge(badge, size: .small)
          }
        }
        
        if let subtitle = subtitle {
          Text(subtitle)
            .font(DSTypography.footnote())
            .foregroundColor(DSColors.textSecondary)
        }
      }
      
      Spacer()
      
      if action != nil {
        Image(systemName: "chevron.right")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(DSColors.textTertiary)
      }
    }
    .padding(.horizontal, DSSpacing.m)
    .padding(.vertical, DSSpacing.sm)
  }
  
  @ViewBuilder
  private var avatarView: some View {
    if let avatarURL = avatarURL {
      AsyncImage(url: URL(string: avatarURL)) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
        default:
          fallbackAvatar
        }
      }
    } else {
      fallbackAvatar
    }
  }
  
  private var fallbackAvatar: some View {
    ZStack {
      Circle()
        .fill(DSGradients.blue)
      
      if let initials = avatarInitials {
        Text(initials)
          .font(DSTypography.headline)
          .foregroundColor(.white)
      } else {
        Image(systemName: "person.fill")
          .font(.system(size: 20))
          .foregroundColor(.white.opacity(0.8))
      }
    }
    .frame(width: 48, height: 48)
  }
}

// MARK: - Card List Cell (Full Width)

public struct DSCardListCell<Content: View>: View {
  
  private let content: Content
  private let hasShadow: Bool
  private let action: (() -> Void)?
  
  public init(
    hasShadow: Bool = true,
    action: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.hasShadow = hasShadow
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          cellContent
        }
        .buttonStyle(.plain)
      } else {
        cellContent
      }
    }
  }
  
  private var cellContent: some View {
    content
      .padding(DSSpacing.m)
      .background(DSColors.cardBackground)
      .dsCornerRadius(DSRadius.card)
      .conditionalModifier(hasShadow) { view in
        view.dsCardShadow()
      }
  }
}

// MARK: - Divider

public struct DSDivider: View {
  
  private let inset: CGFloat
  
  public init(inset: CGFloat = DSSpacing.m) {
    self.inset = inset
  }
  
  public var body: some View {
    Divider()
      .background(DSColors.separator)
      .padding(.horizontal, inset)
  }
}

// MARK: - Section Header

public struct DSSectionHeader: View {
  
  private let title: String
  private let action: (() -> Void)?
  private let actionTitle: String?
  
  public init(
    title: String,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.actionTitle = actionTitle
    self.action = action
  }
  
  public var body: some View {
    HStack {
      Text(title)
        .font(DSTypography.headline(weight: .bold))
        .foregroundColor(DSColors.textPrimary)
      
      Spacer()
      
      if let actionTitle = actionTitle, let action = action {
        Button(action: action) {
          Text(actionTitle)
            .font(DSTypography.footnote(weight: .semibold))
            .foregroundColor(DSColors.primary)
        }
      }
    }
    .padding(.horizontal, DSSpacing.m)
    .padding(.vertical, DSSpacing.xs)
  }
}

