import SwiftUI

// MARK: - Animation Presets

/// Presets de animação do Design System
public struct DSAnimations {
  
  // MARK: - Timing Curves
  
  /// Easing suave (ease-in-out)
  public static let smoothEasing = Animation.easeInOut(duration: 0.3)
  
  /// Easing rápido (ease-out)
  public static let quickEasing = Animation.easeOut(duration: 0.2)
  
  /// Easing lento (ease-in-out)
  public static let slowEasing = Animation.easeInOut(duration: 0.5)
  
  /// Spring suave
  public static let smoothSpring = Animation.spring(
    response: 0.4,
    dampingFraction: 0.8,
    blendDuration: 0.2
  )
  
  /// Spring rápido
  public static let quickSpring = Animation.spring(
    response: 0.3,
    dampingFraction: 0.7,
    blendDuration: 0.1
  )
  
  /// Spring bouncy (para feedbacks)
  public static let bouncySpring = Animation.spring(
    response: 0.4,
    dampingFraction: 0.6,
    blendDuration: 0.2
  )
  
  // MARK: - Durations
  
  /// Duração instantânea (0.1s)
  public static let instant: Double = 0.1
  
  /// Duração rápida (0.2s)
  public static let fast: Double = 0.2
  
  /// Duração padrão (0.3s)
  public static let standard: Double = 0.3
  
  /// Duração lenta (0.5s)
  public static let slow: Double = 0.5
  
  /// Duração muito lenta (0.8s)
  public static let verySlow: Double = 0.8
}

// MARK: - Animation Types

/// Tipos de animação pré-definidos
public enum DSAnimationType {
  case fade
  case slideFromBottom
  case slideFromTop
  case slideFromLeading
  case slideFromTrailing
  case scale
  case scaleWithFade
  case rotate
  case custom(Animation)
  
  var animation: Animation {
    switch self {
    case .fade:
      return DSAnimations.smoothEasing
    case .slideFromBottom, .slideFromTop, .slideFromLeading, .slideFromTrailing:
      return DSAnimations.smoothSpring
    case .scale, .scaleWithFade:
      return DSAnimations.bouncySpring
    case .rotate:
      return DSAnimations.quickEasing
    case .custom(let anim):
      return anim
    }
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Aplica animação de fade
  func dsFadeAnimation(
    isVisible: Bool,
    duration: Double = DSAnimations.standard
  ) -> some View {
    self
      .opacity(isVisible ? 1 : 0)
      .animation(.easeInOut(duration: duration), value: isVisible)
  }
  
  /// Aplica animação de slide
  func dsSlideAnimation(
    isVisible: Bool,
    from edge: Edge = .bottom,
    offset: CGFloat = 50,
    duration: Double = DSAnimations.standard
  ) -> some View {
    let offsetValue = isVisible ? 0 : offset
    
    return self
      .offset(
        x: edge == .leading ? -offsetValue : edge == .trailing ? offsetValue : 0,
        y: edge == .top ? -offsetValue : edge == .bottom ? offsetValue : 0
      )
      .opacity(isVisible ? 1 : 0)
      .animation(DSAnimations.smoothSpring, value: isVisible)
  }
  
  /// Aplica animação de scale
  func dsScaleAnimation(
    isVisible: Bool,
    scale: CGFloat = 0.8,
    duration: Double = DSAnimations.standard
  ) -> some View {
    self
      .scaleEffect(isVisible ? 1 : scale)
      .opacity(isVisible ? 1 : 0)
      .animation(DSAnimations.bouncySpring, value: isVisible)
  }
  
  /// Aplica animação de rotação
  func dsRotateAnimation(
    angle: Angle,
    duration: Double = DSAnimations.standard
  ) -> some View {
    self
      .rotationEffect(angle)
      .animation(DSAnimations.quickEasing, value: angle)
  }
  
  /// Aplica animação de entrada (fade + scale)
  func dsEnterAnimation(
    isVisible: Bool,
    delay: Double = 0
  ) -> some View {
    self
      .scaleEffect(isVisible ? 1 : 0.9)
      .opacity(isVisible ? 1 : 0)
      .animation(
        DSAnimations.smoothSpring.delay(delay),
        value: isVisible
      )
  }
  
  /// Aplica animação de saída (fade + scale)
  func dsExitAnimation(
    isVisible: Bool,
    duration: Double = DSAnimations.fast
  ) -> some View {
    self
      .scaleEffect(isVisible ? 1 : 0.95)
      .opacity(isVisible ? 1 : 0)
      .animation(.easeOut(duration: duration), value: isVisible)
  }
  
  /// Aplica animação de shimmer (loading)
  func dsShimmerAnimation(
    isActive: Bool,
    duration: Double = 1.5
  ) -> some View {
    self.modifier(ShimmerModifier(isActive: isActive, duration: duration))
  }
  
  /// Aplica animação de pulse
  func dsPulseAnimation(
    isActive: Bool,
    scale: CGFloat = 1.1,
    duration: Double = 1.0
  ) -> some View {
    self.modifier(PulseModifier(isActive: isActive, scale: scale, duration: duration))
  }
  
  /// Aplica animação de bounce
  func dsBounceAnimation(
    isActive: Bool,
    intensity: CGFloat = 0.1
  ) -> some View {
    self.modifier(BounceModifier(isActive: isActive, intensity: intensity))
  }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
  let isActive: Bool
  let duration: Double
  
  @State private var phase: CGFloat = 0
  
  func body(content: Content) -> some View {
    content
      .overlay {
        if isActive {
          LinearGradient(
            colors: [
              Color.white.opacity(0),
              Color.white.opacity(0.3),
              Color.white.opacity(0)
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
          .offset(x: phase)
          .onAppear {
            withAnimation(
              .linear(duration: duration)
              .repeatForever(autoreverses: false)
            ) {
              phase = 300
            }
          }
        }
      }
  }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
  let isActive: Bool
  let scale: CGFloat
  let duration: Double
  
  @State private var isPulsing = false
  
  func body(content: Content) -> some View {
    content
      .scaleEffect(isActive && isPulsing ? scale : 1.0)
      .opacity(isActive && isPulsing ? 0.7 : 1.0)
      .onAppear {
        if isActive {
          withAnimation(
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
          ) {
            isPulsing = true
          }
        }
      }
      .onChange(of: isActive) { newValue in
        if !newValue {
          isPulsing = false
        }
      }
  }
}

// MARK: - Bounce Modifier

struct BounceModifier: ViewModifier {
  let isActive: Bool
  let intensity: CGFloat
  
  @State private var offset: CGFloat = 0
  
  func body(content: Content) -> some View {
    content
      .offset(y: offset)
      .onChange(of: isActive) { newValue in
        if newValue {
          withAnimation(DSAnimations.bouncySpring) {
            offset = -intensity * 20
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(DSAnimations.bouncySpring) {
              offset = 0
            }
          }
        }
      }
  }
}

// MARK: - Stagger Animation Helper

/// Aplica animação escalonada (stagger) a uma lista de views
public struct DSStaggeredView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
  
  let data: Data
  let content: (Data.Element) -> Content
  let delay: Double
  
  public init(
    _ data: Data,
    delay: Double = 0.05,
    @ViewBuilder content: @escaping (Data.Element) -> Content
  ) {
    self.data = data
    self.delay = delay
    self.content = content
  }
  
  public var body: some View {
    ForEach(Array(data.enumerated()), id: \.element.id) { index, element in
      content(element)
        .dsEnterAnimation(isVisible: true, delay: Double(index) * delay)
    }
  }
}

