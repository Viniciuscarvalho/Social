import SwiftUI

// MARK: - Swipe Action Configuration

/// Configuração de ação de swipe
public struct DSSwipeAction {
  let icon: String
  let color: Color
  let action: () -> Void
  
  public init(icon: String, color: Color, action: @escaping () -> Void) {
    self.icon = icon
    self.color = color
    self.action = action
  }
}

// MARK: - Swipeable View

/// View que pode ser deslizada (swipe) com ações customizadas
public struct DSSwipeable<Content: View>: View {
  
  private let content: Content
  private let leadingActions: [DSSwipeAction]
  private let trailingActions: [DSSwipeAction]
  private let threshold: CGFloat
  
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false
  
  public init(
    leadingActions: [DSSwipeAction] = [],
    trailingActions: [DSSwipeAction] = [],
    threshold: CGFloat = 100,
    @ViewBuilder content: () -> Content
  ) {
    self.leadingActions = leadingActions
    self.trailingActions = trailingActions
    self.threshold = threshold
    self.content = content()
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Background actions (leading)
        if !leadingActions.isEmpty && dragOffset < 0 {
          HStack(spacing: 0) {
            ForEach(Array(leadingActions.enumerated()), id: \.offset) { index, action in
              actionButton(action: action, index: index, isLeading: true)
            }
          }
          .frame(width: abs(dragOffset))
        }
        
        // Background actions (trailing)
        if !trailingActions.isEmpty && dragOffset > 0 {
          HStack(spacing: 0) {
            ForEach(Array(trailingActions.enumerated()), id: \.offset) { index, action in
              actionButton(action: action, index: index, isLeading: false)
            }
          }
          .frame(width: abs(dragOffset))
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        // Content
        content
          .background(DSColors.cardBackground)
          .offset(x: dragOffset)
          .gesture(
            DragGesture()
              .onChanged { value in
                isDragging = true
                let newOffset = value.translation.width
                
                // Limitar swipe baseado nas ações disponíveis
                let maxLeading = leadingActions.isEmpty ? 0 : -threshold * CGFloat(leadingActions.count)
                let maxTrailing = trailingActions.isEmpty ? 0 : threshold * CGFloat(trailingActions.count)
                
                dragOffset = max(maxLeading, min(maxTrailing, newOffset))
              }
              .onEnded { value in
                isDragging = false
                let velocity = value.predictedEndTranslation.width
                
                // Determinar se deve executar ação ou voltar
                if abs(dragOffset) > threshold * 0.5 || abs(velocity) > 500 {
                  // Executar ação se passar do threshold ou tiver velocidade suficiente
                  if dragOffset < -threshold * 0.5 && !leadingActions.isEmpty {
                    leadingActions[0].action()
                    withAnimation(DSAnimations.quickEasing) {
                      dragOffset = 0
                    }
                  } else if dragOffset > threshold * 0.5 && !trailingActions.isEmpty {
                    trailingActions[0].action()
                    withAnimation(DSAnimations.quickEasing) {
                      dragOffset = 0
                    }
                  } else {
                    // Voltar para posição inicial
                    withAnimation(DSAnimations.smoothSpring) {
                      dragOffset = 0
                    }
                  }
                } else {
                  // Voltar para posição inicial
                  withAnimation(DSAnimations.smoothSpring) {
                    dragOffset = 0
                  }
                }
              }
          )
      }
      .clipped()
    }
  }
  
  @ViewBuilder
  private func actionButton(action: DSSwipeAction, index: Int, isLeading: Bool) -> some View {
    Button {
      action.action()
      withAnimation(DSAnimations.quickEasing) {
        dragOffset = 0
      }
      DSHapticFeedback.medium()
    } label: {
      VStack(spacing: DSSpacing.xs) {
        Image(systemName: action.icon)
          .font(.system(size: 20, weight: .semibold))
          .foregroundColor(.white)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(action.color)
    }
  }
}

// MARK: - Swipe to Delete

/// View com swipe para deletar
public struct DSSwipeToDelete<Content: View>: View {
  
  private let content: Content
  private let onDelete: () -> Void
  private let deleteColor: Color
  
  @State private var dragOffset: CGFloat = 0
  
  public init(
    deleteColor: Color = DSColors.error,
    onDelete: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.deleteColor = deleteColor
    self.onDelete = onDelete
    self.content = content()
  }
  
  public var body: some View {
    DSSwipeable(
      trailingActions: [
        DSSwipeAction(
          icon: "trash.fill",
          color: deleteColor,
          action: onDelete
        )
      ],
      threshold: 80
    ) {
      content
    }
  }
}

// MARK: - Swipe to Favorite

/// View com swipe para favoritar
public struct DSSwipeToFavorite<Content: View>: View {
  
  private let content: Content
  private let isFavorited: Bool
  private let onToggle: () -> Void
  private let favoriteColor: Color
  
  @State private var dragOffset: CGFloat = 0
  
  public init(
    isFavorited: Bool,
    favoriteColor: Color = DSColors.favoriteRed,
    onToggle: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.isFavorited = isFavorited
    self.favoriteColor = favoriteColor
    self.onToggle = onToggle
    self.content = content()
  }
  
  public var body: some View {
    DSSwipeable(
      leadingActions: [
        DSSwipeAction(
          icon: isFavorited ? "heart.fill" : "heart",
          color: favoriteColor,
          action: onToggle
        )
      ],
      threshold: 80
    ) {
      content
    }
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Adiciona swipe para deletar
  func dsSwipeToDelete(
    deleteColor: Color = DSColors.error,
    onDelete: @escaping () -> Void
  ) -> some View {
    DSSwipeToDelete(deleteColor: deleteColor, onDelete: onDelete) {
      self
    }
  }
  
  /// Adiciona swipe para favoritar
  func dsSwipeToFavorite(
    isFavorited: Bool,
    favoriteColor: Color = DSColors.favoriteRed,
    onToggle: @escaping () -> Void
  ) -> some View {
    DSSwipeToFavorite(
      isFavorited: isFavorited,
      favoriteColor: favoriteColor,
      onToggle: onToggle
    ) {
      self
    }
  }
  
  /// Adiciona swipe actions customizadas
  func dsSwipeActions(
    leading: [DSSwipeAction] = [],
    trailing: [DSSwipeAction] = [],
    threshold: CGFloat = 100
  ) -> some View {
    DSSwipeable(
      leadingActions: leading,
      trailingActions: trailing,
      threshold: threshold
    ) {
      self
    }
  }
}

// MARK: - Swipe Indicator

/// Indicador visual de swipe disponível
public struct DSSwipeIndicator: View {
  
  private let direction: SwipeDirection
  
  public enum SwipeDirection {
    case leading
    case trailing
    case both
  }
  
  public init(direction: SwipeDirection = .trailing) {
    self.direction = direction
  }
  
  public var body: some View {
    HStack(spacing: DSSpacing.xs) {
      if direction == .leading || direction == .both {
        Image(systemName: "chevron.left")
          .font(.system(size: 10, weight: .semibold))
          .foregroundColor(DSColors.textTertiary)
      }
      
      Circle()
        .fill(DSColors.textTertiary)
        .frame(width: 4, height: 4)
      
      if direction == .trailing || direction == .both {
        Image(systemName: "chevron.right")
          .font(.system(size: 10, weight: .semibold))
          .foregroundColor(DSColors.textTertiary)
      }
    }
    .padding(.horizontal, DSSpacing.sm)
    .padding(.vertical, DSSpacing.xs)
  }
}

