import ComposableArchitecture
import SwiftUI

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                    
                    // Formulário
                    VStack(spacing: 16) {
                        FormField(
                            title: "Nome do Evento",
                            placeholder: "Ex: Rock in Rio 2025",
                            text: $store.ticketName
                        )
                        
                        // Picker para tipo de ingresso
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de Ingresso")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Picker("Tipo", selection: $store.ticketType) {
                                ForEach(TicketType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        FormField(
                            title: "Preço",
                            placeholder: "R$ 0,00",
                            text: $store.price,
                            keyboardType: .decimalPad
                        )
                        
                        FormField(
                            title: "Descrição",
                            placeholder: "Detalhes adicionais sobre o ingresso",
                            text: $store.description,
                            isTextEditor: true
                        )
                    }
                    .padding(.horizontal)
                    
                    // Botão de publicar
                    Button(action: {
                        store.send(.publishTicket)
                        dismiss()
                    }) {
                        Text("Publicar Ingresso")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accentGreen.gradient)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.secondaryText)
                }
            }
        }
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isTextEditor: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            if isTextEditor {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .padding(12)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .padding(12)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}
