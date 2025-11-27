import SwiftUI

// MARK: - Pull to Refresh Component

/// Componente customizado de pull-to-refresh
public struct DSPullToRefresh: View {
  
  private let isRefreshing: Bool
  private let onRefresh: () -> Void
  private let threshold: CGFloat
  private let progress: CGFloat
  
  public init(
    isRefreshing: Bool,
    onRefresh: @escaping () -> Void,
    threshold: CGFloat = 80,
    progress: CGFloat = 0
  ) {
    self.isRefreshing = isRefreshing
    self.onRefresh = onRefresh
    self.threshold = threshold
    self.progress = progress
  }
  
  public var body: some View {
    VStack(spacing: DSSpacing.sm) {
      if isRefreshing {
        DSLoadingIndicator(style: .spinner, size: .medium)
      } else {
        refreshIcon
      }
      
      if isRefreshing {
        Text("Atualizando...")
          .font(DSTypography.footnote())
          .foregroundColor(DSColors.textSecondary)
      } else if progress > 0.5 {
        Text("Solte para atualizar")
          .font(DSTypography.footnote())
          .foregroundColor(DSColors.textSecondary)
      }
    }
    .frame(height: threshold)
    .opacity(min(progress, 1.0))
  }
  
  @ViewBuilder
  private var refreshIcon: some View {
    Image(systemName: "arrow.down")
      .font(.system(size: 20, weight: .semibold))
      .foregroundColor(DSColors.primary)
      .rotationEffect(.degrees(progress * 180))
      .scaleEffect(progress)
  }
}

// MARK: - Pull to Refresh Modifier

/// Modifier para adicionar pull-to-refresh a qualquer ScrollView
public struct DSPullToRefreshModifier: ViewModifier {
  
  @Binding var isRefreshing: Bool
  let onRefresh: () -> Void
  let threshold: CGFloat
  
  @State private var dragOffset: CGFloat = 0
  @State private var isDragging = false
  
  public init(
    isRefreshing: Binding<Bool>,
    onRefresh: @escaping () -> Void,
    threshold: CGFloat = 80
  ) {
    self._isRefreshing = isRefreshing
    self.onRefresh = onRefresh
    self.threshold = threshold
  }
  
  public func body(content: Content) -> some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        content
        
        // Pull to refresh indicator
        if dragOffset > 0 || isRefreshing {
          DSPullToRefresh(
            isRefreshing: isRefreshing,
            onRefresh: onRefresh,
            threshold: threshold,
            progress: min(dragOffset / threshold, 1.0)
          )
          .offset(y: -threshold + dragOffset)
          .opacity(min(dragOffset / threshold, 1.0))
        }
      }
      .gesture(
        DragGesture()
          .onChanged { value in
            if value.translation.height > 0 && !isRefreshing {
              isDragging = true
              dragOffset = value.translation.height
            }
          }
          .onEnded { value in
            isDragging = false
            if dragOffset > threshold && !isRefreshing {
              isRefreshing = true
              DSHapticFeedback.medium()
              onRefresh()
              
              // Reset após refresh
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(DSAnimations.smoothSpring) {
                  dragOffset = 0
                }
              }
            } else {
              withAnimation(DSAnimations.smoothSpring) {
                dragOffset = 0
              }
            }
          }
      )
    }
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Adiciona pull-to-refresh customizado
  func dsPullToRefresh(
    isRefreshing: Binding<Bool>,
    onRefresh: @escaping () -> Void,
    threshold: CGFloat = 80
  ) -> some View {
    self.modifier(
      DSPullToRefreshModifier(
        isRefreshing: isRefreshing,
        onRefresh: onRefresh,
        threshold: threshold
      )
    )
  }
}

// MARK: - Refreshable ScrollView

/// ScrollView com pull-to-refresh integrado
public struct DSRefreshableScrollView<Content: View>: View {
  
  private let content: Content
  @Binding private var isRefreshing: Bool
  private let onRefresh: () -> Void
  private let threshold: CGFloat
  
  public init(
    isRefreshing: Binding<Bool>,
    onRefresh: @escaping () -> Void,
    threshold: CGFloat = 80,
    @ViewBuilder content: () -> Content
  ) {
    self._isRefreshing = isRefreshing
    self.onRefresh = onRefresh
    self.threshold = threshold
    self.content = content()
  }
  
  public var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // Pull to refresh indicator
        if isRefreshing {
          DSPullToRefresh(
            isRefreshing: isRefreshing,
            onRefresh: onRefresh,
            threshold: threshold
          )
          .frame(height: threshold)
        }
        
        content
      }
    }
    .dsPullToRefresh(
      isRefreshing: $isRefreshing,
      onRefresh: onRefresh,
      threshold: threshold
    )
  }
}

// MARK: - Infinite Scroll

/// Helper para infinite scroll (load more)
public struct DSInfiniteScrollModifier: ViewModifier {
  
  let onLoadMore: () -> Void
  let threshold: CGFloat
  
  public init(onLoadMore: @escaping () -> Void, threshold: CGFloat = 100) {
    self.onLoadMore = onLoadMore
    self.threshold = threshold
  }
  
  public func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometry in
          Color.clear
            .preference(
              key: ScrollOffsetPreferenceKey.self,
              value: geometry.frame(in: .named("scroll")).minY
            )
        }
      )
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
        if offset < threshold {
          onLoadMore()
        }
      }
  }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

public extension View {
  
  /// Adiciona infinite scroll (load more quando chegar no final)
  func dsInfiniteScroll(
    onLoadMore: @escaping () -> Void,
    threshold: CGFloat = 100
  ) -> some View {
    self.modifier(DSInfiniteScrollModifier(onLoadMore: onLoadMore, threshold: threshold))
  }
}

