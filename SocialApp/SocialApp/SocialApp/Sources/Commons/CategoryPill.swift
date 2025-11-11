import SwiftUI

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
            HStack(spacing: 8) {
                // Ícone da categoria em círculo
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    
                    Text(iconForCategory(category))
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category?.displayName ?? String(localized: "commons.categories.all"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .primary : .secondary)
                    
                    Text("\(count) eventos")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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
            HStack(spacing: 6) {
                Text(iconForCategory(category))
                    .font(.system(size: 16))
                
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
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


