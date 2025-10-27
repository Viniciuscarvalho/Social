import SwiftUI

public struct TicketCard: View {
    let ticket: Ticket
    let onTap: () -> Void
    var onDelete: (() -> Void)? = nil
    
    public init(ticket: Ticket, onTap: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.ticket = ticket
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Button(action: onTap) {
                if geometry.size.width < 350 {
                    // Compact layout for smaller screens
                    compactLayout(geometry: geometry)
                } else {
                    // Standard layout for larger screens
                    standardLayout(geometry: geometry)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray6).opacity(0.5), lineWidth: 0.8)
            )
            .swipeActions(edge: .trailing) {
                if let onDelete = onDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Deletar", systemImage: "trash.fill")
                    }
                }
            }
        }
        .frame(height: 110)
    }
    
    @ViewBuilder
    private func compactLayout(geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            // Top row - Title and Status
            HStack {
                Text(ticket.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                // Status indicator - inline
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(ticket.status.color))
                        .frame(width: 8, height: 8)
                    Text(ticket.status.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.8)
                }
            }
            
            // Middle row - Price and Type
            HStack {
                Text("R$ \(ticket.price, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .minimumScaleFactor(0.8)
                
                if let discountPercentage = ticket.discountPercentage {
                    Text("-\(discountPercentage, specifier: "%.0f")%")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(.green.opacity(0.15))
                        )
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Text(ticket.ticketType.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.blue.opacity(0.1))
                    )
            }
            
            // Bottom row - Date
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("Válido até: \(formatShortDate(ticket.validUntil))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.8)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private func standardLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Ticket type icon with responsive sizing
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue.opacity(0.1))
                        .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.blue.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "ticket.fill")
                        .font(.system(size: min(geometry.size.width * 0.05, 18), weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Text(ticket.ticketType.displayName)
                    .font(.system(size: min(geometry.size.width * 0.025, 10), weight: .medium))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: geometry.size.width * 0.2)
            
            // Main content area - adaptive
            VStack(alignment: .leading, spacing: geometry.size.height * 0.08) {
                // Ticket name
                Text(ticket.name)
                    .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Price section - responsive layout
                HStack(spacing: 8) {
                    Text("R$ \(ticket.price, specifier: "%.2f")")
                        .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .minimumScaleFactor(0.8)
                    
                    if let discountPercentage = ticket.discountPercentage {
                        Text("-\(discountPercentage, specifier: "%.0f")%")
                            .font(.system(size: min(geometry.size.width * 0.025, 10), weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.green.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(.green.opacity(0.4), lineWidth: 0.8)
                                    )
                            )
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                
                // Date info - compact
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: min(geometry.size.width * 0.025, 10)))
                        .foregroundColor(.secondary)
                    Text("Válido até: \(formatShortDate(ticket.validUntil))")
                        .font(.system(size: min(geometry.size.width * 0.025, 10)))
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Status indicator - compact
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(ticket.status.color).opacity(0.15))
                        .frame(width: min(geometry.size.width * 0.07, 24), height: min(geometry.size.width * 0.07, 24))
                        .overlay(
                            Circle()
                                .stroke(Color(ticket.status.color), lineWidth: 1.5)
                        )
                    
                    Circle()
                        .fill(Color(ticket.status.color))
                        .frame(width: min(geometry.size.width * 0.025, 8), height: min(geometry.size.width * 0.025, 8))
                }
                
                Text(ticket.status.displayName)
                    .font(.system(size: min(geometry.size.width * 0.02, 8), weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: geometry.size.width * 0.15)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ \(value)"
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "pt_BR")
        return df.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        df.locale = Locale(identifier: "pt_BR")
        return df.string(from: date)
    }
}
