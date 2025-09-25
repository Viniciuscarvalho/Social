import SwiftUI

struct EventCardLarge: View {
    let event: Event
    let onTap: () -> Void
    let onJoin: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: event.imageURL.flatMap { URL(string: $0) }) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(16)
                
                Text(event.dateFormatted) // ex: "23 AUG"
                    .font(.caption.bold())
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(8)
            }
            
            Text(event.name)
                .font(.headline)
            
            HStack {
                Text(event.timeRange) // ex: "8:30 pm - 11:00 pm"
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(event.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(event.location.name)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("A partir de \(event.startPrice, format: .currency(code: "BRL"))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: onJoin) {
                    Text("Informações")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                }
            }
        }
        .onTapGesture(perform: onTap)
    }
}

