import SwiftUI
import DesignSystem

/// Componente reutilizável para exibir categorias com ícone e contador
public struct CategoryPill: View {
    let category: EventCategory?
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        category: EventCategory?,
        count: Int,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                // Ícone da categoria em círculo
                ZStack {
                    Circle()
                        .fill(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
                        .frame(width: 40, height: 40)
                    
                    Text(iconForCategory(category))
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(category?.displayName ?? String(localized: "commons.categories.all"))
                        .font(DSTypography.footnote(weight: .semibold))
                        .foregroundColor(isSelected ? DSColors.textPrimary : DSColors.textSecondary)
                    
                    Text("\(count) eventos")
                        .font(DSTypography.caption1())
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.medium)
                    .fill(isSelected ? DSColors.primary.opacity(0.1) : DSColors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.medium)
                    .stroke(isSelected ? DSColors.primary : DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .dsTapFeedback()
    }
    
    private func iconForCategory(_ category: EventCategory?) -> String {
        guard let category = category else {
            return "📋" // Ícone para "All"
        }
        
        switch category {
        case .music:
            return "🎵"
        case .sports:
            return "⚽"
        case .culture:
            return "🎭"
        case .food:
            return "🍽️"
        case .technology:
            return "💻"
        case .business:
            return "💼"
        case .nature:
            return "🌿"
        case .adventure:
            return "🏔️"
        }
    }
}

/// Versão simplificada da pill para filtros
public struct CategoryFilterPill: View {
    let category: EventCategory
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        category: EventCategory,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.category = category
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                Text(iconForCategory(category))
                    .font(.system(size: 16))
                
                Text(category.displayName)
                    .font(DSTypography.footnote(weight: .medium))
                    .foregroundColor(isSelected ? .white : DSColors.textPrimary)
            }
            .padding(.horizontal, DSSpacing.m)
            .padding(.vertical, DSSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.buttonSmall)
                    .fill(isSelected ? DSColors.primary : DSColors.backgroundSecondary)
            )
        }
        .buttonStyle(.plain)
        .dsTapFeedback()
    }
    
    private func iconForCategory(_ category: EventCategory) -> String {
        switch category {
        case .music:
            return "🎵"
        case .sports:
            return "⚽"
        case .culture:
            return "🎭"
        case .food:
            return "🍽️"
        case .technology:
            return "💻"
        case .business:
            return "💼"
        case .nature:
            return "🌿"
        case .adventure:
            return "🏔️"
        }
    }
}


