import ComposableArchitecture
import SwiftUI

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.dismiss) var dismiss
    @Dependency(\.ticketsClient) var ticketsClient
    
    var body: some View {
        NavigationStack {
            mainContent
                .background(AppColors.background)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .onChange(of: store.publishSuccess) { _, success in
                    if success {
                        dismiss()
                    }
                }
                .alert("Erro", isPresented: errorBinding) {
                    Button("OK") { }
                } message: {
                    Text(store.errorMessage ?? "")
                }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                formView
                publishButtonView
            }
            .padding(.bottom, 40)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancelar") {
            dismiss()
        }
        .foregroundColor(AppColors.secondaryText)
    }
    
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { _ in store.send(.clearError) }
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.accentGreen)
            
            Text("Vender Ingresso")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
            
            Text("Preencha os dados do ingresso que deseja vender")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var formView: some View {
        VStack(spacing: 16) {
            eventSelectorView
            FormField(
                title: "Nome do Ingresso",
                text: $store.ticketName,
                placeholder: "Ex: VIP, Pista, Camarote"
            )
            FormField(
                title: "Preço",
                text: $store.price,
                placeholder: "Ex: 120,00"
            )
            FormField(
                title: "Tipo",
                text: Binding(
                    get: { store.ticketType.displayName },
                    set: { _ in }
                ),
                placeholder: "Selecione o tipo"
            )
            FormField(
                title: "Descrição",
                text: $store.description,
                placeholder: "Descrição",
                isTextEditor: true
            )
        }
        .padding(.horizontal)
    }
    
    private var eventSelectorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evento")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            eventSelectorContent
        }
    }
    
    @ViewBuilder
    private var eventSelectorContent: some View {
        if let eventId = store.selectedEventId {
            selectedEventView(eventId: eventId)
        } else {
            eventSelectionView
        }
    }
    
    private func selectedEventView(eventId: UUID) -> some View {
        let selectedEvent = store.availableEvents.first { UUID(uuidString: $0.id) == eventId }
        
        return VStack(alignment: .leading, spacing: 4) {
            Text(selectedEvent?.name ?? "Evento Selecionado")
                .font(.body)
                .foregroundColor(AppColors.accentGreen)
            Text("ID: \(eventId.uuidString)")
                .font(.caption2)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accentGreen.opacity(0.1))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var eventSelectionView: some View {
        if store.isLoadingEvents {
            loadingEventsView
        } else {
            eventMenuView
        }
    }
    
    private var loadingEventsView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Carregando eventos...")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
    }
    
    private var eventMenuView: some View {
        Menu {
            ForEach(store.availableEvents, id: \.id) { event in
                Button(event.name) {
                    if let eventId = UUID(uuidString: event.id) {
                        store.send(.setSelectedEventId(eventId))
                    }
                }
            }
        } label: {
            HStack {
                Text("Selecionar Evento")
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(12)
            .background(AppColors.cardBackground)
            .cornerRadius(8)
        }
    }
    
    private var publishButtonView: some View {
        Button(action: {
            store.send(.publishTicket)
        }) {
            HStack {
                if store.isPublishing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(store.isPublishing ? "Publicando..." : "Publicar Ingresso")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.accentGreen.gradient)
            .cornerRadius(12)
        }
        .disabled(store.isPublishing)
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isTextEditor: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            if isTextEditor {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}

#Preview {
    AddTicketView(
        store: Store(initialState: AddTicketFeature.State()) {
            AddTicketFeature()
        }
    )
}
