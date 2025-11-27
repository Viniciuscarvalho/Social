import SwiftUI

// MARK: - Tap Feedback

/// Estilos de feedback de toque
public enum DSTapFeedbackStyle {
  case scale
  case opacity
  case highlight
  case ripple
  case bounce
  case none
}

// MARK: - Tap Feedback Button Style

/// ButtonStyle com feedback de toque personalizado
public struct DSTapFeedbackButtonStyle: ButtonStyle {
  
  private let style: DSTapFeedbackStyle
  private let intensity: CGFloat
  
  public init(style: DSTapFeedbackStyle = .scale, intensity: CGFloat = 0.95) {
    self.style = style
    self.intensity = intensity
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed && style == .scale ? intensity : 1.0)
      .opacity(configuration.isPressed && style == .opacity ? 0.7 : 1.0)
      .overlay {
        if configuration.isPressed && style == .highlight {
          RoundedRectangle(cornerRadius: DSRadius.sm)
            .fill(Color.white.opacity(0.2))
        }
      }
      .overlay {
        if configuration.isPressed && style == .ripple {
          Circle()
            .fill(Color.white.opacity(0.3))
            .scaleEffect(configuration.isPressed ? 1.5 : 0.5)
            .opacity(configuration.isPressed ? 0 : 1)
            .animation(.easeOut(duration: 0.3), value: configuration.isPressed)
        }
      }
      .animation(DSAnimations.quickEasing, value: configuration.isPressed)
  }
}

// MARK: - Haptic Feedback

/// Tipos de feedback háptico
public enum DSHapticFeedbackType {
  case light
  case medium
  case heavy
  case success
  case warning
  case error
  case selection
  
  var style: UIImpactFeedbackGenerator.FeedbackStyle {
    switch self {
    case .light: return .light
    case .medium: return .medium
    case .heavy: return .heavy
    default: return .medium
    }
  }
  
  var notificationType: UINotificationFeedbackGenerator.FeedbackType {
    switch self {
    case .success: return .success
    case .warning: return .warning
    case .error: return .error
    default: return .success
    }
  }
}

/// Helper para feedback háptico
public struct DSHapticFeedback {
  
  public static func impact(_ type: DSHapticFeedbackType) {
    switch type {
    case .light, .medium, .heavy:
      let generator = UIImpactFeedbackGenerator(style: type.style)
      generator.impactOccurred()
    case .success, .warning, .error:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(type.notificationType)
    case .selection:
      let generator = UISelectionFeedbackGenerator()
      generator.selectionChanged()
    }
  }
  
  public static func light() {
    impact(.light)
  }
  
  public static func medium() {
    impact(.medium)
  }
  
  public static func heavy() {
    impact(.heavy)
  }
  
  public static func success() {
    impact(.success)
  }
  
  public static func warning() {
    impact(.warning)
  }
  
  public static func error() {
    impact(.error)
  }
  
  public static func selection() {
    impact(.selection)
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Adiciona feedback de toque
  func dsTapFeedback(
    style: DSTapFeedbackStyle = .scale,
    intensity: CGFloat = 0.95
  ) -> some View {
    self.buttonStyle(DSTapFeedbackButtonStyle(style: style, intensity: intensity))
  }
  
  /// Adiciona feedback háptico ao toque
  func dsHapticFeedback(
    _ type: DSHapticFeedbackType = .medium,
    onTap: Bool = true
  ) -> some View {
    self.onTapGesture {
      if onTap {
        DSHapticFeedback.impact(type)
      }
    }
  }
  
  /// Adiciona feedback de toque com haptic
  func dsInteractiveFeedback(
    tapStyle: DSTapFeedbackStyle = .scale,
    hapticType: DSHapticFeedbackType = .light
  ) -> some View {
    self
      .dsTapFeedback(style: tapStyle)
      .onTapGesture {
        DSHapticFeedback.impact(hapticType)
      }
  }
}

// MARK: - Pressable View

/// View que responde a pressão com feedback visual e háptico
public struct DSPressable<Content: View>: View {
  
  private let content: Content
  private let tapStyle: DSTapFeedbackStyle
  private let hapticType: DSHapticFeedbackType?
  private let action: () -> Void
  
  @State private var isPressed = false
  
  public init(
    tapStyle: DSTapFeedbackStyle = .scale,
    hapticType: DSHapticFeedbackType? = .light,
    action: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.tapStyle = tapStyle
    self.hapticType = hapticType
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    content
      .scaleEffect(isPressed && tapStyle == .scale ? 0.95 : 1.0)
      .opacity(isPressed && tapStyle == .opacity ? 0.7 : 1.0)
      .overlay {
        if isPressed && tapStyle == .highlight {
          RoundedRectangle(cornerRadius: DSRadius.sm)
            .fill(Color.white.opacity(0.2))
        }
      }
      .animation(DSAnimations.quickEasing, value: isPressed)
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            if !isPressed {
              isPressed = true
              hapticType.map { DSHapticFeedback.impact($0) }
            }
          }
          .onEnded { _ in
            isPressed = false
            action()
          }
      )
  }
}

// MARK: - Long Press Feedback

/// View com feedback de long press
public struct DSLongPressable<Content: View>: View {
  
  private let content: Content
  private let minimumDuration: Double
  private let action: () -> Void
  
  @State private var isPressed = false
  @State private var progress: CGFloat = 0
  
  public init(
    minimumDuration: Double = 0.5,
    action: @escaping () -> Void,
    @ViewBuilder content: () -> Content
  ) {
    self.minimumDuration = minimumDuration
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    content
      .scaleEffect(isPressed ? 0.95 : 1.0)
      .overlay {
        if isPressed {
          Circle()
            .stroke(DSColors.primary, lineWidth: 3)
            .scaleEffect(1 + progress)
            .opacity(1 - progress)
        }
      }
      .animation(DSAnimations.quickEasing, value: isPressed)
      .gesture(
        LongPressGesture(minimumDuration: minimumDuration)
          .onChanged { isPressing in
            isPressed = isPressing
            if isPressing {
              withAnimation(.linear(duration: minimumDuration)) {
                progress = 1.0
              }
              DSHapticFeedback.medium()
            }
          }
          .onEnded { _ in
            isPressed = false
            progress = 0
            DSHapticFeedback.success()
            action()
          }
      )
  }
}

// MARK: - Shake Animation

/// View que pode ser "sacudida" (shake)
public struct DSShakeable: ViewModifier {
  
  @Binding var isShaking: Bool
  let intensity: CGFloat
  
  public init(isShaking: Binding<Bool>, intensity: CGFloat = 10) {
    self._isShaking = isShaking
    self.intensity = intensity
  }
  
  public func body(content: Content) -> some View {
    content
      .offset(x: isShaking ? intensity : 0)
      .animation(
        Animation.default.repeatCount(3, autoreverses: true).speed(6),
        value: isShaking
      )
      .onChange(of: isShaking) { newValue in
        if newValue {
          DSHapticFeedback.error()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
          }
        }
      }
  }
}

public extension View {
  
  /// Aplica animação de shake
  func dsShakeable(
    isShaking: Binding<Bool>,
    intensity: CGFloat = 10
  ) -> some View {
    self.modifier(DSShakeable(isShaking: isShaking, intensity: intensity))
  }
}

// MARK: - Loading Pulse

/// View com animação de pulse para loading
public struct DSLoadingPulse: View {
  
  private let color: Color
  private let size: CGFloat
  
  @State private var scale: CGFloat = 0.8
  @State private var opacity: Double = 0.5
  
  public init(color: Color = DSColors.primary, size: CGFloat = 20) {
    self.color = color
    self.size = size
  }
  
  public var body: some View {
    Circle()
      .fill(color)
      .frame(width: size, height: size)
      .scaleEffect(scale)
      .opacity(opacity)
      .onAppear {
        withAnimation(
          .easeInOut(duration: 1.0)
          .repeatForever(autoreverses: true)
        ) {
          scale = 1.2
          opacity = 1.0
        }
      }
  }
}

