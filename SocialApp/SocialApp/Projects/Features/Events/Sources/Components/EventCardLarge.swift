import ComposableArchitecture
import SwiftUI

public struct EventCardLarge: View {
    let event: Event
    let onTap: () -> Void
    let onJoin: () -> Void
    
    public init(event: Event, onTap: @escaping () -> Void, onJoin: @escaping () -> Void) {
        self.event = event
        self.onTap = onTap
        self.onJoin = onJoin
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topTrailing) {
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
                                .font(.largeTitle)
                        }
                }
                .frame(height: 200)
                .clipped()
                
                // Favorite button in top-right corner
                EventFavoriteView(
                    store: Store(initialState: EventFavoriteFeature.State(event: event)) {
                        EventFavoriteFeature()
                    }
                )
                .padding(.trailing, 12)
                .padding(.top, 12)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(event.location.city)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("HOJE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text(event.timeRange)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let description = event.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("a partir de")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("R$ \(event.startPrice, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button("Participar", action: onJoin)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

