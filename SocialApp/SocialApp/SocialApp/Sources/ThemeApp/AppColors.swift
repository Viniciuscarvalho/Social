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
}

// MARK: - Extensões para Material Design
public extension Color {
    static let appBackground = AppColors.background
    static let appSecondaryBackground = AppColors.secondaryBackground
    static let appText = AppColors.primaryText
    static let appSecondaryText = AppColors.secondaryText
}