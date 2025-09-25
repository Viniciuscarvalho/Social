import SwiftUI

struct EventCardSmall: View {
    let event: Event
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: event.imageURL.flatMap { URL(string: $0) }) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
                .frame(width: 160, height: 120)
                .clipped()
                .cornerRadius(16)
                
                Text(event.dateFormatted)
                    .font(.caption.bold())
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(6)
            }
            
            Text(event.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            
            Text(event.timeRange)
                .font(.caption)
                .foregroundColor(.gray)
            
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
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(event.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 160)
        .onTapGesture(perform: onTap)
    }
}
