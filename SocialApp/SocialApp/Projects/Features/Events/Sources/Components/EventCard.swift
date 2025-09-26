import SwiftUI
import CoreLocation
import ComposableArchitecture

struct EventCard: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(event.location.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("$\(Int(event.startPrice))")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    if let rating = event.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                EventFavoriteView(
                    store: Store(initialState: EventFavoriteFeature.State(event: event)) {
                        EventFavoriteFeature()
                    }
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
