import SwiftUI
import Observation

@Observable
public class ThemeManager {
    public static let shared = ThemeManager()
    
    public var colorScheme: ColorScheme? = nil {
        didSet {
            UserDefaults.standard.set(colorScheme?.rawValue, forKey: "colorScheme")
        }
    }
    
    private init() {
        // Carrega a preferência salva do usuário
        if let savedScheme = UserDefaults.standard.string(forKey: "colorScheme"),
           let scheme = ColorScheme(rawValue: savedScheme) {
            self.colorScheme = scheme
        }
    }
    
    public func toggleColorScheme() {
        switch colorScheme {
        case .light:
            colorScheme = .dark
        case .dark:
            colorScheme = nil // Sistema
        case .none:
            colorScheme = .light
        }
    }
    
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
}

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