import SwiftUI
import ComposableArchitecture

public struct PopularEventsView: View {
    let events: [Event]
    let onEventSelected: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCategory: EventCategory? = nil
    
    public init(events: [Event], onEventSelected: @escaping (String) -> Void) {
        self.events = events
        self.onEventSelected = onEventSelected
    }
    
    // Computed: eventos filtrados por categoria
    private var filteredEvents: [Event] {
        if let category = selectedCategory {
            let filtered = events.filter { $0.category == category }
            print("🔍 Filtrados por \(category.displayName): \(filtered.count) eventos")
            return filtered
        }
        print("🔍 Mostrando todos: \(events.count) eventos")
        return events
    }
    
    // Computed: contagem de eventos por categoria
    private var categoryCounts: [EventCategory?: Int] {
        var counts: [EventCategory?: Int] = [:]
        
        // Total (All)
        counts[nil] = events.count
        
        // Por categoria
        for event in events {
            counts[event.category, default: 0] += 1
        }
        
        return counts
    }
    
    // Helper: retorna a contagem para uma categoria
    private func countForCategory(_ category: EventCategory?) -> Int {
        return categoryCounts[category] ?? 0
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Popular Event")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Invisible button for symmetry
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Category Filters - Horizontal ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All - mostra total de eventos
                    CategoryFilterButton(
                        title: "All",
                        icon: nil,
                        count: countForCategory(nil),
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    // Music
                    CategoryFilterButton(
                        title: "Music",
                        icon: "🎵",
                        count: countForCategory(.music),
                        isSelected: selectedCategory == .music
                    ) {
                        selectedCategory = .music
                    }
                    
                    // Arts (Culture)
                    CategoryFilterButton(
                        title: "Arts",
                        icon: "🎨",
                        count: countForCategory(.culture),
                        isSelected: selectedCategory == .culture
                    ) {
                        selectedCategory = .culture
                    }
                    
                    // Business
                    CategoryFilterButton(
                        title: "Business",
                        icon: "💼",
                        count: countForCategory(.business),
                        isSelected: selectedCategory == .business
                    ) {
                        selectedCategory = .business
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            
            // Events List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredEvents, id: \.id) { event in
                        PopularEventCard(event: event) {
                            onEventSelected(event.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > 100 {
                        dismiss()
                    }
                }
        )
    }
}

// MARK: - Popular Event Card

struct PopularEventCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Event Image
                AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                }
                .frame(width: 80, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Event Info
                VStack(alignment: .leading, spacing: 6) {
                    // Price Badge
                    if event.startPrice > 0 {
                        Text("$\(Int(event.startPrice))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                    }
                    
                    // Event Name
                    Text(event.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Date and Time
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.dateFormatted)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(event.location.address ?? "")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Favorite Button
                EventFavoriteView(
                    store: Store(initialState: EventFavoriteFeature.State(event: event)) {
                        EventFavoriteFeature()
                    }
                )
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let title: String
    let icon: String?
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    if let icon = icon {
                        Text(icon)
                            .font(.system(size: 18))
                    }
                    
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}
