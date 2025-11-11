import SwiftUI
import ComposableArchitecture

/// Modal de filtros para eventos
public struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var filterState: FilterState
    let onApply: (FilterState) -> Void
    
    public init(
        filterState: FilterState,
        onApply: @escaping (FilterState) -> Void
    ) {
        self._filterState = State(initialValue: filterState)
        self.onApply = onApply
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Location Section
                    locationSection
                    
                    Divider()
                    
                    // Event Categories Section
                    categoriesSection
                    
                    Divider()
                    
                    // Price Range Section
                    priceSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "commons.filter.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Limpar") {
                        filterState = FilterState()
                    }
                    .font(.system(size: 15, weight: .medium))
                }
            }
            .safeAreaInset(edge: .bottom) {
                applyButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "commons.filter.section.location"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                // Campo de localização
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    TextField(String(localized: "commons.filter.location.placeholder"), text: $filterState.location)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                
                // Botão Localize me
                Button {
                    filterState.useCurrentLocation.toggle()
                    // Aqui você pode adicionar lógica de geolocalização real
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: filterState.useCurrentLocation ? "location.fill" : "location")
                            .font(.system(size: 14, weight: .semibold))
                        Text(String(localized: "commons.filter.useMyLocation"))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(filterState.useCurrentLocation ? .white : .blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(filterState.useCurrentLocation ? Color.blue : Color.blue.opacity(0.1))
                    )
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "commons.filter.section.categories"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            // Grid de categorias
            let categories: [EventCategory] = [.music, .culture, .food, .sports]
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(category)
                }
            }
        }
    }
    
    private func categoryButton(_ category: EventCategory) -> some View {
        let isSelected = filterState.selectedCategories.contains(category)
        
        return Button {
            if isSelected {
                filterState.selectedCategories.remove(category)
            } else {
                filterState.selectedCategories.insert(category)
            }
        } label: {
            HStack(spacing: 8) {
                Text(iconForCategory(category))
                    .font(.system(size: 20))
                
                Text(displayNameForCategory(category))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            PriceRangeSlider(
                minPrice: $filterState.minPrice,
                maxPrice: $filterState.maxPrice,
                range: 0...200
            )
        }
    }
    
    private var applyButton: some View {
        Button {
            onApply(filterState)
            dismiss()
        } label: {
            Text(String(localized: "commons.filter.apply"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
        }
    }
    
    // Helpers
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
    
    private func displayNameForCategory(_ category: EventCategory) -> String {
        switch category {
        case .music:
            return String(localized: "commons.filter.categories.concerts")
        case .culture:
            return String(localized: "commons.filter.categories.movies")
        case .food:
            return String(localized: "commons.filter.categories.exhibitions")
        case .sports:
            return String(localized: "commons.filter.categories.tours")
        default:
            return category.displayName
        }
    }
}

#Preview {
    FilterSheetView(filterState: FilterState()) { state in
        print("Applied filters: \(state)")
    }
}

