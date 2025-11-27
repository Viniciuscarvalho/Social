import SwiftUI
import Observation

/// Theme Manager - Gerencia o tema do app (light/dark/auto)
@Observable
public class Theme {
  
  public static let shared = Theme()
  
  /// Color scheme atual (nil = automático)
  public var colorScheme: ColorScheme? = nil {
    didSet {
      UserDefaults.standard.set(colorScheme?.rawValue, forKey: "app_color_scheme")
    }
  }
  
  private init() {
    // Carrega preferência salva
    if let savedScheme = UserDefaults.standard.string(forKey: "app_color_scheme"),
       let scheme = ColorScheme(rawValue: savedScheme) {
      self.colorScheme = scheme
    }
  }
  
  /// Toggle entre light/dark/auto
  public func toggleColorScheme() {
    switch colorScheme {
    case .light:
      colorScheme = .dark
    case .dark:
      colorScheme = nil
    case .none:
      colorScheme = .light
    }
  }
  
  /// Nome do tema atual para display
  public var displayName: String {
    switch colorScheme {
    case .light:
      return "Claro"
    case .dark:
      return "Escuro"
    case .none:
      return "Automático"
    }
  }
  
  /// Ícone do tema atual
  public var iconName: String {
    switch colorScheme {
    case .light:
      return "sun.max.fill"
    case .dark:
      return "moon.fill"
    case .none:
      return "circle.lefthalf.filled"
    }
  }
}

// MARK: - ColorScheme Extensions

extension ColorScheme {
  var rawValue: String {
    switch self {
    case .light:
      return "light"
    case .dark:
      return "dark"
    @unknown default:
      return "light"
    }
  }
  
  init?(rawValue: String) {
    switch rawValue {
    case "light":
      self = .light
    case "dark":
      self = .dark
    default:
      return nil
    }
  }
}

// MARK: - View Extensions

public extension View {
  
  /// Aplica o color scheme do Theme
  func dsPreferredColorScheme() -> some View {
    self.preferredColorScheme(Theme.shared.colorScheme)
  }
}

