import SwiftUI
import CoreLocation
import ComposableArchitecture

public struct EventCard: View {
    let event: Event
    let onTap: () -> Void
    
    public init(event: Event, onTap: @escaping () -> Void) {
        self.event = event
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Event image placeholder
                AsyncImage(url: event.imageURL.flatMap(URL.init)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(event.category.icon)
                        Text(event.category.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if event.isRecommended {
                            Text("⭐ Recomendado")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(event.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(event.location.city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("A partir de R$ \(event.startPrice, specifier: "%.0f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(event.dateFormatted)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(event.timeRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
