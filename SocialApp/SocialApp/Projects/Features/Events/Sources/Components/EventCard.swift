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
            VStack(alignment: .leading, spacing: 0) {
                // Event image placeholder
                AsyncImage(url: event.imageURL.flatMap { urlString in
                    print("📸 EventCard - Event: \(event.name)")
                    print("   imageURL: \(urlString)")
                    let url = URL(string: urlString)
                    print("   Parsed URL: \(url?.absoluteString ?? "nil")")
                    return url
                }) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Color.black.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                            .font(.system(size: 28))
                    }
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(16, corners: [.topLeft, .topRight])
                
                // Content section with better padding and spacing
                VStack(alignment: .leading, spacing: 14) {
                    // Category and recommended badge
                    HStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(event.category.icon)
                                .font(.system(size: 14))
                            Text(event.category.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if event.isRecommended {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("Recomendado")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(.orange.opacity(0.12))
                                    .overlay(
                                        Capsule()
                                            .stroke(.orange.opacity(0.3), lineWidth: 0.5)
                                    )
                            )
                        }
                    }
                    
                    // Event name with better spacing
                    Text(event.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Location and price with improved styling
                    HStack(alignment: .center, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(event.location.city)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("A partir de")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            HStack(spacing: 2) {
                                Text("R$")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(event.startPrice, specifier: "%.0f")")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    // Date and time with enhanced icons
                    HStack(alignment: .center, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(event.dateFormatted)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(event.timeRange)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray6), lineWidth: 0.5)
        )
    }
}

// MARK: - View Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
