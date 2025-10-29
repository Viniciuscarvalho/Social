import ComposableArchitecture
import SwiftUI

public struct RecommendedEventsView: View {
    let events: [Event]
    let onEventSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var favoriteStores: [String: StoreOf<EventFavoriteFeature>] = [:]
    
    public init(events: [Event], onEventSelected: @escaping (String) -> Void) {
        self.events = events
        self.onEventSelected = onEventSelected
    }
    
    
    private func favoriteStore(for event: Event) -> StoreOf<EventFavoriteFeature> {
        if let existingStore = favoriteStores[event.id] {
            return existingStore
        }
        
        let newStore = Store(initialState: EventFavoriteFeature.State(event: event)) {
            EventFavoriteFeature()
        }
        favoriteStores[event.id] = newStore
        return newStore
    }
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(events) { event in
                    RecommendedEventFullCard(event: event, favoriteStore: favoriteStore(for: event)) {
                        onEventSelected(event.id)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .navigationTitle("Recommended Events")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Recommended Event Full Card

struct RecommendedEventFullCard: View {
    let event: Event
    @Bindable var favoriteStore: StoreOf<EventFavoriteFeature>
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Event image with price badge
                ZStack(alignment: .topTrailing) {
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
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    // Price badge
                    Text(getPriceText())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(getPriceColor())
                        )
                        .padding(14)
                }
                .frame(height: 200)
                
                // Event info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(event.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        FavoriteButton(
                            event: event,
                            isFavorite: favoriteStore.isFavorite,
                            onTap: {
                                favoriteStore.send(.toggleFavorite)
                            }
                        )
                        .onAppear {
                            favoriteStore.send(.onAppear)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text(event.timeRange.components(separatedBy: " - ").first ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.name)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func getPriceText() -> String {
        if event.startPrice == 0 {
            return "Free"
        }
        return "$\(Int(event.startPrice))"
    }
    
    private func getPriceColor() -> Color {
        if event.startPrice == 0 {
            return Color.green
        }
        return Color.blue
    }
}

#Preview {
    NavigationStack {
        RecommendedEventsView(
            events: [],
            onEventSelected: { _ in }
        )
    }
}

