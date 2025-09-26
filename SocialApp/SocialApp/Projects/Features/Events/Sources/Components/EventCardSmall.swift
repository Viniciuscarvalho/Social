import ComposableArchitecture
import SwiftUI

public struct EventCardSmall: View {
    let event: Event
    let onTap: () -> Void
    
    public init(event: Event, onTap: @escaping () -> Void) {
        self.event = event
        self.onTap = onTap
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
                        }
                }
                .frame(width: 160, height: 120)
                .clipped()
                
                // Favorite button
                EventFavoriteView(
                    store: Store(initialState: EventFavoriteFeature.State(event: event)) {
                        EventFavoriteFeature()
                    }
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.dateFormatted)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text(event.name)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(event.location.city)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("R$ \(event.startPrice, specifier: "%.0f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding(12)
        }
        .frame(width: 160)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
