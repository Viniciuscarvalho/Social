import SwiftUI

public struct AppColors {
    // MARK: - Cores principais
    public static let primary = Color.accentColor
    public static let secondary = Color(.systemBlue)
    
    // MARK: - Cores de fundo adaptativas
    public static let background = Color(.systemBackground)
    public static let secondaryBackground = Color(.secondarySystemBackground)
    public static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // MARK: - Cores de texto adaptativas
    public static let primaryText = Color(.label)
    public static let secondaryText = Color(.secondaryLabel)
    public static let tertiaryText = Color(.tertiaryLabel)
    public static let quaternaryText = Color(.quaternaryLabel)
    
    // MARK: - Cores de sistema adaptativas
    public static let separator = Color(.separator)
    public static let opaqueSeparator = Color(.opaqueSeparator)
    
    // MARK: - Cores de Cards e Containers
    public static let cardBackground = Color(.secondarySystemBackground)
    public static let groupedBackground = Color(.systemGroupedBackground)
    public static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
    
    // MARK: - Cores de estado
    public static let success = Color(.systemGreen)
    public static let warning = Color(.systemOrange)
    public static let error = Color(.systemRed)
    
    // MARK: - Cores personalizadas adaptativas
    
    public static var favoriteRed: Color {
        Color("FavoriteRed", bundle: .module)
    }
    
    public static var eventCardShadow: Color {
        Color(.label).opacity(0.1)
    }
    
    // MARK: - Cores do Design System Moderno (SellerProfile)
    
    /// Background gradient escuro adaptativo
    public static var darkGradientTop: Color {
        Color(
            light: Color(hex: "F5F5F7"), // Cinza claro para light mode
            dark: Color(hex: "1a1a2e")   // Azul escuro para dark mode
        )
    }
    
    public static var darkGradientBottom: Color {
        Color(
            light: Color(hex: "E8E8ED"), // Cinza mais escuro para light mode
            dark: Color(hex: "0f0f1e")   // Azul muito escuro para dark mode
        )
    }
    
    /// Cor de destaque verde limão (success alternativo)
    public static var accentGreen: Color {
        Color(hex: "a0f064")
    }
    
    /// Azul vibrante (secondary alternativo)
    public static var accentBlue: Color {
        Color(hex: "4a90e2")
    }
    
    /// Azul mais escuro para gradientes
    public static var accentBlueDark: Color {
        Color(hex: "357abd")
    }
    
    // MARK: - Cores para cards com glassmorphism
    
    /// Background de card com efeito glass
    public static var glassBackground: Color {
        Color(
            light: Color.white.opacity(0.7),
            dark: Color.white.opacity(0.05)
        )
    }
    
    /// Borda de card com efeito glass
    public static var glassBorder: Color {
        Color(
            light: Color.black.opacity(0.1),
            dark: Color.white.opacity(0.1)
        )
    }
    
    // MARK: - Cores de overlay e sombra
    
    /// Overlay escuro para modais
    public static var overlayDark: Color {
        Color.black.opacity(0.4)
    }
    
    /// Sombra suave para cards
    public static var cardShadow: Color {
        Color(
            light: Color.black.opacity(0.1),
            dark: Color.black.opacity(0.3)
        )
    }
    
    // MARK: - Cores para progress bars
    
    /// Cor de fundo da progress bar
    public static var progressBackground: Color {
        tertiaryBackground
    }
    
    /// Gradiente verde para progress
    public static func progressGradient(color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.6)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Cores de ícones e badges
    
    /// Cor do badge de verificado
    public static var verifiedBadge: Color {
        accentBlue
    }
    
    /// Cor do troféu/conquista
    public static var trophy: Color {
        warning
    }
    
    /// Background de ícone circular
    public static func iconCircleBackground(_ color: Color) -> Color {
        color.opacity(0.15)
    }
}

// MARK: - Extensões para Material Design

public extension Color {
    static let appBackground = AppColors.background
    static let appSecondaryBackground = AppColors.secondaryBackground
    static let appText = AppColors.primaryText
    static let appSecondaryText = AppColors.secondaryText
    
    static let appCard = AppColors.cardBackground
    static let appGlass = AppColors.glassBackground
    static let appAccentGreen = AppColors.accentGreen
    static let appAccentBlue = AppColors.accentBlue
}

// MARK: - Helper para cores hexadecimais com suporte Light/Dark

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    /// Inicializador com cores diferentes para light e dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Gradientes pré-definidos

public extension AppColors {
    /// Gradiente de fundo principal
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [darkGradientTop, darkGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Gradiente para botões primários
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Gradiente para avatar/profile
    static var profileGradient: LinearGradient {
        LinearGradient(
            colors: [accentBlue, accentBlueDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Gradiente verde para success
    static var successGradient: LinearGradient {
        LinearGradient(
            colors: [accentGreen, accentGreen.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
