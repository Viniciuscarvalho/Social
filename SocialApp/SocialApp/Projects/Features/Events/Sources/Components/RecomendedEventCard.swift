import SwiftUI

struct RecommendedEventCard: View {
    let event: Event
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: event.imageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 200, height: 120)
                .cornerRadius(8)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onFavorite) {
                                Image(systemName: "heart")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                    .padding(8)
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Foto")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(event.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("start from: $\(Int(event.startPrice))")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 200)
    }
}
