import SwiftUI
import ComposableArchitecture
import DesignSystem

// MARK: - Ticket Details Step View (Etapa 1)

struct TicketDetailsStepView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(TicketCreationStep.details.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(TicketCreationStep.details.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Seleção de Evento
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Evento")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    if store.isLoadingEvents {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if store.availableEvents.isEmpty {
                        VStack(spacing: 12) {
                            Text("Nenhum evento disponível")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                store.send(.loadEvents)
                            } label: {
                                Label("Recarregar Eventos", systemImage: "arrow.clockwise")
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    } else {
                        Menu {
                            ForEach(store.availableEvents) { event in
                                Button {
                                    store.send(.setSelectedEventId(UUID(uuidString: event.id)))
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(event.name)
                                        Text(event.location.city)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if let selectedId = store.selectedEventId,
                                   let selectedEvent = store.availableEvents.first(where: { UUID(uuidString: $0.id) == selectedId }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedEvent.name)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text(selectedEvent.location.city)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("Selecione um evento")
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    if store.selectedEventId == nil && !store.isLoadingEvents {
                        Text("*Campo obrigatório")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Nome do Ingresso
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Título do Ingresso")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "ticket")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    TextField("Ex: Ingresso VIP - Pista Premium", text: $store.ticketName)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    if store.ticketName.isEmpty {
                        Text("*Campo obrigatório")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("\(store.ticketName.count)/60 caracteres")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tipo de Ingresso
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Tipo de Ingresso")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "star")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    Picker("Tipo", selection: $store.ticketType) {
                        ForEach(TicketType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Descrição (Opcional)
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Descrição (Opcional)")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $store.description)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
                            )
                        
                        if store.description.isEmpty {
                            Text("Adicione detalhes sobre o ingresso...")
                                .foregroundColor(.secondary)
                                .padding(.top, 16)
                                .padding(.leading, 12)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    Text("\(store.description.count)/500 caracteres")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetailsStepView(
            store: Store(
                initialState: AddTicketFeature.State()
            ) {
                AddTicketFeature()
            }
        )
    }
}

