import ComposableArchitecture
import SwiftUI
import DesignSystem

public struct EventsView: View {
    @Bindable var store: StoreOf<EventsFeature>
    
    public init(store: StoreOf<EventsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            DSGradients.backgroundMain
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: DSSpacing.xl) {
                        // Espaçamento para o header fixo
                        Spacer()
                            .frame(height: 100)
                        
                        // Seção Popular
                        if store.hasPopularEvents {
                            popularSection
                        }
                        
                        // Seção de Categorias
                        if store.hasCategories {
                            categoriesSection
                        }
                    }
                    .padding(.vertical, DSSpacing.m)
                }
                
                // Header fixo no topo
                VStack(spacing: 0) {
                    headerSection
                        .padding(.horizontal, DSSpacing.m)
                        .padding(.top, DSSpacing.xs)
                        .padding(.bottom, DSSpacing.m)
                        .background(
                            DSColors.background
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            store.send(.refreshRequested)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        .sheet(isPresented: $store.showFilterSheet.sending(\.showFilterSheetChanged)) {
            FilterSheetView(
                filterState: store.filterState,
                onApply: { filterState in
                    store.send(.filterApplied(filterState))
                }
            )
            .dsSlideFromBottomTransition()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(currentDateTime())
                        .font(DSTypography.caption1())
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("Explore eventos")
                        .font(DSTypography.title1(weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                }
                
                Spacer()
                
                // Foto de perfil
                AsyncImage(url: URL(string: store.user?.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(DSGradients.primary)
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
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("POPULAR")
                    .font(DSTypography.caption1(weight: .bold))
                    .foregroundColor(DSColors.textSecondary)
                    .tracking(1)
                
                Spacer()
            }
            .padding(.horizontal, DSSpacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.m) {
                    ForEach(Array(store.popularEvents.enumerated()), id: \.element.id) { index, event in
                        ExploreEventCard(event: event) {
                            if let eventId = UUID(uuidString: event.id) {
                                store.send(.eventSelected(eventId))
                            }
                        }
                        .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.1)
                    }
                }
                .padding(.horizontal, DSSpacing.m)
            }
        }
    }
    
    @ViewBuilder
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("CATEGORIES")
                    .font(DSTypography.caption1(weight: .bold))
                    .foregroundColor(DSColors.textSecondary)
                    .tracking(1)
                
                Spacer()
            }
            .padding(.horizontal, DSSpacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.sm) {
                    ForEach(Array(EventCategory.allCases.enumerated()), id: \.element) { index, category in
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
                        .dsEnterAnimation(isVisible: true, delay: Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, DSSpacing.m)
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
