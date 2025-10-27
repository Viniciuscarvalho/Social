import ComposableArchitecture
import SwiftUI

public struct EventsView: View {
    @Bindable var store: StoreOf<EventsFeature>
    
    public init(store: StoreOf<EventsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 24) {
                    // Espaçamento para o header fixo
                    Spacer()
                        .frame(height: 100)
                    
                    // Barra de busca persistente
                    SearchBarView(
                        searchText: $store.searchText.sending(\.searchTextChanged),
                        placeholder: "Search...",
                        onFilterTap: {
                            store.send(.showFilterSheetChanged(true))
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    // Seção Popular
                    if !store.popularEvents.isEmpty {
                        popularSection
                    }
                    
                    // Seção de Categorias
                    categoriesSection
                }
                .padding(.vertical, 16)
            }
            
            // Header fixo no topo
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            store.send(.refreshRequested)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.showFilterSheet.sending(\.showFilterSheetChanged)) {
            FilterSheetView(
                filterState: store.filterState,
                onApply: { filterState in
                    store.send(.filterApplied(filterState))
                }
            )
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentDateTime())
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("Explore eventos")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Foto de perfil
                AsyncImage(url: URL(string: store.user?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            }
        }
    }
    
    @ViewBuilder
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("POPULAR")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(store.popularEvents) { event in
                        ExploreEventCard(event: event) {
                            if let eventId = UUID(uuidString: event.id) {
                                store.send(.eventSelected(eventId))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("CATEGORIES")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EventCategory.allCases, id: \.self) { category in
                        let count = store.categoryCounts[category] ?? 0
                        CategoryPill(
                            category: category,
                            count: count,
                            isSelected: store.selectedCategory == category
                        ) {
                            store.send(.categorySelected(
                                store.selectedCategory == category ? nil : category
                            ))
                        }
                        .frame(width: 140)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func currentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, h:mm a"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: Date()).uppercased()
    }
}

// MARK: - Explore Event Card (similar ao Popular mas ajustado para Explore)

private struct ExploreEventCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Imagem de fundo
                AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: 280, height: 320)
                .clipped()
                
                // Overlay gradient
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Conteúdo
                VStack(alignment: .leading, spacing: 8) {
                    // Badge de categoria e data
                    HStack(spacing: 6) {
                        Text(categoryBadgeText(event.category))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                        
                        Spacer()
                        
                        // Data
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(dateDay(event.eventDate))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Text(dateMonth(event.eventDate))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Título e informações
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        HStack(spacing: 4) {
                            Text(event.dateFormatted)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("•")
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(event.timeRange)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(width: 280, height: 320)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
    
    private func categoryBadgeText(_ category: EventCategory) -> String {
        switch category {
        case .music:
            return "CONCERT"
        case .sports:
            return "SPORTS"
        case .culture:
            return "CULTURE"
        case .food:
            return "FOOD"
        default:
            return category.displayName.uppercased()
        }
    }
    
    private func dateDay(_ date: Date?) -> String {
        guard let date = date else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func dateMonth(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en")
        return formatter.string(from: date).uppercased()
    }
}
