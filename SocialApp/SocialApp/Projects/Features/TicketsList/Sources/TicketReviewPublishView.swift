import SwiftUI
import ComposableArchitecture

// MARK: - Ticket Review & Publish View (Etapa 5)

struct TicketReviewPublishView: View {
    let store: StoreOf<AddTicketFeature>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(TicketCreationStep.review.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(TicketCreationStep.review.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Ticket Preview Card
                VStack(alignment: .leading, spacing: 16) {
                    // Event Info
                    if let selectedId = store.selectedEventId,
                       let selectedEvent = store.availableEvents.first(where: { UUID(uuidString: $0.id) == selectedId }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EVENTO")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundColor(AppColors.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedEvent.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                    
                                    Text(selectedEvent.location.city)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    Divider()
                    
                    // Ticket Details
                    VStack(spacing: 16) {
                        ReviewRow(
                            icon: "ticket",
                            label: "Título",
                            value: store.ticketName,
                            action: { store.send(.goToStep(.details)) }
                        )
                        
                        ReviewRow(
                            icon: "star",
                            label: "Tipo",
                            value: store.ticketType.displayName,
                            action: { store.send(.goToStep(.details)) }
                        )
                        
                        if !store.description.isEmpty {
                            ReviewRow(
                                icon: "text.alignleft",
                                label: "Descrição",
                                value: store.description,
                                action: { store.send(.goToStep(.details)) }
                            )
                        }
                    }
                    
                    Divider()
                    
                    // Pricing
                    VStack(spacing: 16) {
                        ReviewRow(
                            icon: "brazilianrealsign.circle",
                            label: "Preço",
                            value: formatPrice(store.price, currency: store.currencyCode),
                            action: { store.send(.goToStep(.pricing)) }
                        )
                        
                        if !store.originalPrice.isEmpty {
                            ReviewRow(
                                icon: "tag",
                                label: "Preço Original",
                                value: formatPrice(store.originalPrice, currency: store.currencyCode),
                                action: { store.send(.goToStep(.pricing)) }
                            )
                        }
                        
                        ReviewRow(
                            icon: "number",
                            label: "Quantidade",
                            value: "\(store.quantity) \(store.quantity == 1 ? "ingresso" : "ingressos")",
                            action: { store.send(.goToStep(.pricing)) }
                        )
                    }
                    
                    Divider()
                    
                    // Validity
                    ReviewRow(
                        icon: "calendar.badge.clock",
                        label: "Válido até",
                        value: formatDate(store.validUntil),
                        action: { store.send(.goToStep(.validity)) }
                    )
                    
                    if !store.selectedImageUrls.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(AppColors.primary)
                                
                                Text("Fotos")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Editar") {
                                    store.send(.goToStep(.media))
                                }
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                            }
                            
                            Text("\(store.selectedImageUrls.count) foto(s) anexada(s)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // Total Summary
                if let priceValue = AddTicketFeature.parsePrice(store.price) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Valor Total")
                                .font(.headline)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(formatCurrency(priceValue * Double(store.quantity), currency: store.currencyCode))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.primary)
                                
                                Text("\(store.quantity) × \(formatCurrency(priceValue, currency: store.currencyCode))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Publish Button
                Button {
                    store.send(.publishTicket)
                } label: {
                    HStack {
                        if store.isPublishing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Publicar Ingresso")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(store.isFormValid && !store.isPublishing ? AppColors.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!store.isFormValid || store.isPublishing)
                
                // Terms
                Text("Ao publicar, você concorda com nossos termos de serviço e política de privacidade.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private func formatPrice(_ priceString: String, currency: String) -> String {
        if let priceValue = AddTicketFeature.parsePrice(priceString) {
            return formatCurrency(priceValue, currency: currency)
        }
        return priceString
    }
    
    private func formatCurrency(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: currency == "BRL" ? "pt_BR" : "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

// MARK: - Review Row

struct ReviewRow: View {
    let icon: String
    let label: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
            
            Button {
                action()
            } label: {
                Image(systemName: "pencil")
                    .font(.caption)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketReviewPublishView(
            store: Store(
                initialState: AddTicketFeature.State(
                    ticketName: "Ingresso VIP",
                    ticketType: .vip,
                    price: "250,00",
                    originalPrice: "300,00",
                    description: "Acesso completo ao evento",
                    selectedEventId: nil,
                    quantity: 2,
                    currencyCode: "BRL",
                    validUntil: Date().addingTimeInterval(86400 * 30)
                )
            ) {
                AddTicketFeature()
            }
        )
    }
}

// Extension for initializer
extension AddTicketFeature.State {
    init(
        ticketName: String,
        ticketType: TicketType,
        price: String,
        originalPrice: String,
        description: String,
        selectedEventId: UUID?,
        quantity: Int,
        currencyCode: String,
        validUntil: Date
    ) {
        self.init(selectedEventId: selectedEventId)
        self.ticketName = ticketName
        self.ticketType = ticketType
        self.price = price
        self.originalPrice = originalPrice
        self.description = description
        self.quantity = quantity
        self.currencyCode = currencyCode
        self.validUntil = validUntil
        self.currentStep = .review
    }
}

