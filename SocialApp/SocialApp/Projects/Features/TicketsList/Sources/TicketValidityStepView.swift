import SwiftUI
import ComposableArchitecture
import DesignSystem

// MARK: - Ticket Validity Step View (Etapa 3)

struct TicketValidityStepView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @State private var selectedDaysFromNow: Int = 30
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(TicketCreationStep.validity.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(TicketCreationStep.validity.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Quick Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Seleção Rápida")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickDurationButton(days: 7, selectedDays: $selectedDaysFromNow) {
                            updateValidUntil(days: 7)
                        }
                        
                        QuickDurationButton(days: 15, selectedDays: $selectedDaysFromNow) {
                            updateValidUntil(days: 15)
                        }
                        
                        QuickDurationButton(days: 30, selectedDays: $selectedDaysFromNow) {
                            updateValidUntil(days: 30)
                        }
                        
                        QuickDurationButton(days: 60, selectedDays: $selectedDaysFromNow) {
                            updateValidUntil(days: 60)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Custom Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Data Personalizada")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    DatePicker(
                        "Válido até",
                        selection: $store.validUntil,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .onChange(of: store.validUntil) { _, newValue in
                        // Reset quick selection when custom date is picked
                        let calendar = Calendar.current
                        let days = calendar.dateComponents([.day], from: Date(), to: newValue).day ?? 0
                        selectedDaysFromNow = days
                    }
                }
                
                // Validity Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .foregroundColor(DSColors.primary)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ingresso válido até:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatDate(store.validUntil))
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(DSColors.primary.opacity(0.1))
                    .cornerRadius(12)
                    
                    if store.validUntil <= Date() {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            
                            Text("A data de validade deve ser no futuro")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Time Zone Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Fuso horário: \(timeZoneString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(8)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private func updateValidUntil(days: Int) {
        selectedDaysFromNow = days
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) {
            store.send(.binding(.set(\.validUntil, newDate)))
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
    
    private var timeZoneString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        return TimeZone.current.identifier
    }
}

// MARK: - Quick Duration Button

struct QuickDurationButton: View {
    let days: Int
    @Binding var selectedDays: Int
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Text("\(days)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(days == 1 ? "dia" : "dias")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                selectedDays == days
                    ? DSColors.primary
                    : Color(.secondarySystemBackground)
            )
            .foregroundColor(
                selectedDays == days
                    ? .white
                    : .primary
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        TicketValidityStepView(
            store: Store(
                initialState: AddTicketFeature.State()
            ) {
                AddTicketFeature()
            }
        )
    }
}

