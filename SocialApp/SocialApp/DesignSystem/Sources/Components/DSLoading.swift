import SwiftUI

// MARK: - Loading Indicator

public struct DSLoadingIndicator: View {
  
  private let style: LoadingStyle
  private let size: LoadingSize
  
  public enum LoadingStyle {
    case spinner
    case dots
    case pulse
  }
  
  public enum LoadingSize {
    case small
    case medium
    case large
    
    var dimension: CGFloat {
      switch self {
      case .small: return 24
      case .medium: return 40
      case .large: return 64
      }
    }
  }
  
  public init(
    style: LoadingStyle = .spinner,
    size: LoadingSize = .medium
  ) {
    self.style = style
    self.size = size
  }
  
  public var body: some View {
    Group {
      switch style {
      case .spinner:
        spinnerView
      case .dots:
        dotsView
      case .pulse:
        pulseView
      }
    }
  }
  
  private var spinnerView: some View {
    ProgressView()
      .progressViewStyle(.circular)
      .scaleEffect(size == .small ? 1.0 : size == .medium ? 1.5 : 2.0)
      .tint(DSColors.primary)
  }
  
  private var dotsView: some View {
    HStack(spacing: DSSpacing.xs) {
      ForEach(0..<3, id: \.self) { index in
        Circle()
          .fill(DSColors.primary)
          .frame(width: size.dimension / 4, height: size.dimension / 4)
          .scaleEffect(animatingDot == index ? 1.5 : 1.0)
          .animation(
            .easeInOut(duration: 0.6)
              .repeatForever()
              .delay(Double(index) * 0.2),
            value: animatingDot
          )
      }
    }
    .onAppear {
      startDotsAnimation()
    }
  }
  
  @State private var animatingDot = 0
  
  private func startDotsAnimation() {
    Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
      animatingDot = (animatingDot + 1) % 3
    }
  }
  
  private var pulseView: some View {
    Circle()
      .fill(DSColors.primary)
      .frame(width: size.dimension, height: size.dimension)
      .scaleEffect(pulsing ? 1.2 : 0.8)
      .opacity(pulsing ? 0.5 : 1.0)
      .animation(
        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
        value: pulsing
      )
      .onAppear {
        pulsing = true
      }
  }
  
  @State private var pulsing = false
}

// MARK: - Full Screen Loading

public struct DSFullScreenLoading: View {
  
  private let message: String?
  
  public init(message: String? = nil) {
    self.message = message
  }
  
  public var body: some View {
    ZStack {
      DSColors.background
        .opacity(0.8)
        .ignoresSafeArea()
      
      VStack(spacing: DSSpacing.m) {
        DSLoadingIndicator(size: .large)
        
        if let message = message {
          Text(message)
            .font(DSTypography.body())
            .foregroundColor(DSColors.textSecondary)
        }
      }
      .padding(DSSpacing.xl)
      .background(DSColors.cardBackground)
      .dsCornerRadius(DSRadius.lg)
      .dsMediumShadow()
    }
  }
}

// MARK: - Overlay Loading

public struct DSOverlayLoading: View {
  
  public init() {}
  
  public var body: some View {
    ZStack {
      Color.black
        .opacity(0.3)
        .ignoresSafeArea()
      
      DSLoadingIndicator(size: .large)
        .padding(DSSpacing.xl)
        .background(DSColors.cardBackground)
        .dsCornerRadius(DSRadius.lg)
    }
  }
}

// MARK: - Inline Loading

public struct DSInlineLoading: View {
  
  private let message: String
  
  public init(message: String = "Carregando...") {
    self.message = message
  }
  
  public var body: some View {
    HStack(spacing: DSSpacing.sm) {
      DSLoadingIndicator(style: .spinner, size: .small)
      
      Text(message)
        .font(DSTypography.body())
        .foregroundColor(DSColors.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, DSSpacing.m)
  }
}

// MARK: - Skeleton Views

public struct DSSkeletonText: View {
  
  private let lines: Int
  private let lineHeight: CGFloat
  
  public init(lines: Int = 1, lineHeight: CGFloat = 20) {
    self.lines = lines
    self.lineHeight = lineHeight
  }
  
  public var body: some View {
    VStack(spacing: DSSpacing.xs) {
      ForEach(0..<lines, id: \.self) { index in
        Rectangle()
          .fill(DSColors.tertiaryBackground)
          .frame(height: lineHeight)
          .frame(maxWidth: index == lines - 1 ? .infinity * 0.7 : .infinity)
          .dsCornerRadius(DSRadius.xs)
          .dsSkeleton(isLoading: true)
      }
    }
  }
}

public struct DSSkeletonImage: View {
  
  private let width: CGFloat
  private let height: CGFloat
  
  public init(width: CGFloat = 100, height: CGFloat = 100) {
    self.width = width
    self.height = height
  }
  
  public var body: some View {
    Rectangle()
      .fill(DSColors.tertiaryBackground)
      .frame(width: width, height: height)
      .dsCornerRadius(DSRadius.sm)
      .dsSkeleton(isLoading: true)
  }
}

public struct DSSkeletonCircle: View {
  
  private let size: CGFloat
  
  public init(size: CGFloat = 40) {
    self.size = size
  }
  
  public var body: some View {
    Circle()
      .fill(DSColors.tertiaryBackground)
      .frame(width: size, height: size)
      .dsSkeleton(isLoading: true, cornerRadius: size / 2)
  }
}

// MARK: - Button Loading State

public struct DSButtonLoading: View {
  
  public init() {}
  
  public var body: some View {
    HStack(spacing: DSSpacing.xs) {
      ProgressView()
        .progressViewStyle(.circular)
        .tint(.white)
        .scaleEffect(0.8)
      
      Text("Carregando...")
        .font(DSTypography.headline)
    }
  }
}

