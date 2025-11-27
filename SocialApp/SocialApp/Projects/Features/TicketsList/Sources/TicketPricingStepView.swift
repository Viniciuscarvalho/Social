import SwiftUI
import ComposableArchitecture
import DesignSystem

// MARK: - Ticket Pricing Step View (Etapa 2)

struct TicketPricingStepView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(TicketCreationStep.pricing.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(TicketCreationStep.pricing.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Currency Selection
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Moeda")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    Picker("Moeda", selection: $store.currencyCode) {
                        Text("🇧🇷 Real (BRL)").tag("BRL")
                        Text("🇺🇸 Dólar (USD)").tag("USD")
                        Text("🇪🇺 Euro (EUR)").tag("EUR")
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Preço
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Preço")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "brazilianrealsign.circle")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    HStack {
                        Text(currencySymbol)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        TextField("0,00", text: $store.price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                    }
                    .padding(.vertical)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    if store.price.isEmpty {
                        Text("*Campo obrigatório")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if let priceValue = AddTicketFeature.parsePrice(store.price) {
                        Text("Preço: \(formatCurrency(priceValue))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Formato inválido. Use: 120,00 ou 120.00")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Preço Original (Opcional)
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Preço Original (Opcional)")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "tag")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    Text("Para mostrar desconto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(currencySymbol)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        
                        TextField("0,00", text: $store.originalPrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                    }
                    .padding(.vertical)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    if !store.originalPrice.isEmpty {
                        if let originalPriceValue = AddTicketFeature.parsePrice(store.originalPrice),
                           let priceValue = AddTicketFeature.parsePrice(store.price) {
                            if originalPriceValue > priceValue {
                                let discount = ((originalPriceValue - priceValue) / originalPriceValue) * 100
                                Text("Desconto de \(String(format: "%.0f", discount))%")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("O preço original deve ser maior que o preço")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        } else {
                            Text("Formato inválido")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Quantidade
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Quantidade Disponível")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "number")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    Stepper(value: $store.quantity, in: 1...999) {
                        HStack {
                            Text("\(store.quantity)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(store.quantity == 1 ? String(localized: "tickets.units.single") : String(localized: "tickets.units.plural"))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Preview Card
                if let priceValue = AddTicketFeature.parsePrice(store.price) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "tickets.pricing.preview"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "tickets.pricing.total"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(formatCurrency(priceValue * Double(store.quantity)))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(DSColors.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(localized: "tickets.pricing.perTicket"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(formatCurrency(priceValue))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(DSColors.primary.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private var currencySymbol: String {
        switch store.currencyCode {
        case "BRL": return "R$"
        case "USD": return "$"
        case "EUR": return "€"
        default: return "R$"
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = store.currencyCode
        formatter.locale = Locale(identifier: store.currencyCode == "BRL" ? "pt_BR" : "en_US")
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencySymbol) \(value)"
    }
}

#Preview {
    NavigationStack {
        TicketPricingStepView(
            store: Store(
                initialState: AddTicketFeature.State()
            ) {
                AddTicketFeature()
            }
        )
    }
}

