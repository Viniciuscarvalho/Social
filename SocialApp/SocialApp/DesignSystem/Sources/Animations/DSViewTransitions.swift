import SwiftUI

// MARK: - Transition Types

/// Tipos de transição pré-definidos
public enum DSTransitionType {
  case fade
  case slideFromBottom
  case slideFromTop
  case slideFromLeading
  case slideFromTrailing
  case scale
  case scaleWithFade
  case move(Edge)
  case asymmetric(insertion: AnyTransition, removal: AnyTransition)
  
  var transition: AnyTransition {
    switch self {
    case .fade:
      return .opacity
    case .slideFromBottom:
      return .move(edge: .bottom).combined(with: .opacity)
    case .slideFromTop:
      return .move(edge: .top).combined(with: .opacity)
    case .slideFromLeading:
      return .move(edge: .leading).combined(with: .opacity)
    case .slideFromTrailing:
      return .move(edge: .trailing).combined(with: .opacity)
    case .scale:
      return .scale
    case .scaleWithFade:
      return .scale.combined(with: .opacity)
    case .move(let edge):
      return .move(edge: edge)
    case .asymmetric(let insertion, let removal):
      return .asymmetric(insertion: insertion, removal: removal)
    }
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Aplica transição customizada
  func dsTransition(
    _ type: DSTransitionType,
    animation: Animation = DSAnimations.smoothSpring
  ) -> some View {
    self.transition(type.transition)
      .animation(animation, value: UUID())
  }
  
  /// Transição de fade
  func dsFadeTransition(
    animation: Animation = DSAnimations.smoothEasing
  ) -> some View {
    self.transition(.opacity)
      .animation(animation, value: UUID())
  }
  
  /// Transição de slide do bottom
  func dsSlideFromBottomTransition(
    animation: Animation = DSAnimations.smoothSpring
  ) -> some View {
    self.transition(.move(edge: .bottom).combined(with: .opacity))
      .animation(animation, value: UUID())
  }
  
  /// Transição de scale
  func dsScaleTransition(
    animation: Animation = DSAnimations.bouncySpring
  ) -> some View {
    self.transition(.scale.combined(with: .opacity))
      .animation(animation, value: UUID())
  }
}

// MARK: - Page Transition

/// Transição de página (slide horizontal)
public struct DSPageTransition: ViewModifier {
  
  let direction: PageDirection
  let isActive: Bool
  
  public enum PageDirection {
    case forward
    case backward
  }
  
  public init(direction: PageDirection, isActive: Bool) {
    self.direction = direction
    self.isActive = isActive
  }
  
  public func body(content: Content) -> some View {
    content
      .offset(x: isActive ? (direction == .forward ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width) : 0)
      .opacity(isActive ? 0 : 1)
      .animation(DSAnimations.smoothSpring, value: isActive)
  }
}

public extension View {
  
  /// Transição de página (slide horizontal)
  func dsPageTransition(
    direction: DSPageTransition.PageDirection,
    isActive: Bool
  ) -> some View {
    self.modifier(DSPageTransition(direction: direction, isActive: isActive))
  }
}

// MARK: - Modal Transition

/// Transição de modal (scale + fade do center)
public struct DSModalTransition: ViewModifier {
  
  let isPresented: Bool
  
  public init(isPresented: Bool) {
    self.isPresented = isPresented
  }
  
  public func body(content: Content) -> some View {
    content
      .scaleEffect(isPresented ? 1 : 0.9)
      .opacity(isPresented ? 1 : 0)
      .animation(DSAnimations.smoothSpring, value: isPresented)
  }
}

public extension View {
  
  /// Transição de modal
  func dsModalTransition(isPresented: Bool) -> some View {
    self.modifier(DSModalTransition(isPresented: isPresented))
  }
}

// MARK: - Card Transition

/// Transição de card (slide + scale)
public struct DSCardTransition: ViewModifier {
  
  let isVisible: Bool
  let delay: Double
  
  public init(isVisible: Bool, delay: Double = 0) {
    self.isVisible = isVisible
    self.delay = delay
  }
  
  public func body(content: Content) -> some View {
    content
      .offset(y: isVisible ? 0 : 20)
      .scaleEffect(isVisible ? 1 : 0.95)
      .opacity(isVisible ? 1 : 0)
      .animation(
        DSAnimations.smoothSpring.delay(delay),
        value: isVisible
      )
  }
}

public extension View {
  
  /// Transição de card
  func dsCardTransition(isVisible: Bool, delay: Double = 0) -> some View {
    self.modifier(DSCardTransition(isVisible: isVisible, delay: delay))
  }
}

// MARK: - List Item Transition

/// Transição de item de lista (stagger)
public struct DSListItemTransition: ViewModifier {
  
  let isVisible: Bool
  let index: Int
  let delay: Double
  
  public init(isVisible: Bool, index: Int, delay: Double = 0.05) {
    self.isVisible = isVisible
    self.index = index
    self.delay = delay
  }
  
  public func body(content: Content) -> some View {
    content
      .offset(x: isVisible ? 0 : -20)
      .opacity(isVisible ? 1 : 0)
      .animation(
        DSAnimations.smoothSpring.delay(Double(index) * delay),
        value: isVisible
      )
  }
}

public extension View {
  
  /// Transição de item de lista (stagger)
  func dsListItemTransition(
    isVisible: Bool,
    index: Int,
    delay: Double = 0.05
  ) -> some View {
    self.modifier(
      DSListItemTransition(
        isVisible: isVisible,
        index: index,
        delay: delay
      )
    )
  }
}

// MARK: - Tab Transition

/// Transição de tab (fade + slight scale)
public struct DSTabTransition: ViewModifier {
  
  let isSelected: Bool
  
  public init(isSelected: Bool) {
    self.isSelected = isSelected
  }
  
  public func body(content: Content) -> some View {
    content
      .scaleEffect(isSelected ? 1 : 0.95)
      .opacity(isSelected ? 1 : 0.6)
      .animation(DSAnimations.quickEasing, value: isSelected)
  }
}

public extension View {
  
  /// Transição de tab
  func dsTabTransition(isSelected: Bool) -> some View {
    self.modifier(DSTabTransition(isSelected: isSelected))
  }
}

// MARK: - Hero Transition

/// Transição hero (para shared element transitions)
public struct DSHeroTransition: ViewModifier {
  
  let isActive: Bool
  let sourceFrame: CGRect?
  let destinationFrame: CGRect?
  
  public init(isActive: Bool, sourceFrame: CGRect? = nil, destinationFrame: CGRect? = nil) {
    self.isActive = isActive
    self.sourceFrame = sourceFrame
    self.destinationFrame = destinationFrame
  }
  
  public func body(content: Content) -> some View {
    content
      .scaleEffect(isActive ? 1 : 0.8)
      .opacity(isActive ? 1 : 0)
      .animation(DSAnimations.smoothSpring, value: isActive)
  }
}

public extension View {
  
  /// Transição hero
  func dsHeroTransition(
    isActive: Bool,
    sourceFrame: CGRect? = nil,
    destinationFrame: CGRect? = nil
  ) -> some View {
    self.modifier(
      DSHeroTransition(
        isActive: isActive,
        sourceFrame: sourceFrame,
        destinationFrame: destinationFrame
      )
    )
  }
}

