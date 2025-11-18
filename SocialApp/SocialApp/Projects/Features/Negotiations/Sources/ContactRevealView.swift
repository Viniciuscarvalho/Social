import SwiftUI
import ComposableArchitecture

public struct ContactRevealView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var copiedField: String?
    @State private var showingCopiedFeedback = false
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if let seller = store.revealedSeller {
                    ScrollView {
                    VStack(spacing: 24) {
                        // Header com ícone de segurança
                        securityHeader
                        
                        // Informações de contato
                        contactInfoSection(seller: seller)
                        
                        // Botão WhatsApp (se negociação estiver disponível)
                        if let negotiation = store.negotiation {
                            whatsAppButton(negotiation: negotiation)
                        }
                        
                        // Aviso de segurança
                        securityWarning
                    }
                    .padding()
                    }
                } else if store.isRevealingContact {
                    loadingView
                }
            }
            .navigationTitle("Dados de Contato")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        // Limpa dados sensíveis da memória
                        store.send(.hideContactReveal)
                        dismiss()
                    }
                }
            }
            .alert("Copiado!", isPresented: $showingCopiedFeedback) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("O texto foi copiado para a área de transferência")
            }
        }
    }
    
    // MARK: - Security Header
    
    private var securityHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
            }
            
            Text("Dados Revelados com Segurança")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Estes dados foram revelados após autenticação biométrica")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Contact Info Section
    
    private func contactInfoSection(seller: User) -> some View {
        VStack(spacing: 16) {
            // Nome
            if let name = seller.name, !name.isEmpty {
                ContactInfoRow(
                    icon: "person.fill",
                    title: "Nome",
                    value: name,
                    isCopied: copiedField == "name",
                    onCopy: {
                        copyToClipboard(name, field: "name")
                    }
                )
            }
            
            // Email
            if let email = seller.email, !email.isEmpty {
                ContactInfoRow(
                    icon: "envelope.fill",
                    title: "E-mail",
                    value: email,
                    isCopied: copiedField == "email",
                    onCopy: {
                        copyToClipboard(email, field: "email")
                    },
                    actionType: .email
                )
            }
            
        }
    }
    
    // MARK: - WhatsApp Button
    
    private func whatsAppButton(negotiation: Negotiation) -> some View {
        Button {
            openWhatsAppWithNegotiation(negotiation: negotiation)
        } label: {
            HStack {
                Image(systemName: "message.fill")
                    .font(.system(size: 18))
                
                Text("Abrir WhatsApp")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green)
            )
            .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Security Warning
    
    private var securityWarning: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("Aviso de Segurança")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text("Estes dados são confidenciais. Use-os apenas para contato relacionado a esta negociação. Não compartilhe com terceiros.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Autenticando...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func copyToClipboard(_ text: String, field: String) {
        UIPasteboard.general.string = text
        copiedField = field
        showingCopiedFeedback = true
        
        // Reset após 2 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedField = nil
        }
    }
    
    private func formatPhone(_ phone: String) -> String {
        // Remove caracteres não numéricos
        let digits = phone.filter { $0.isNumber }
        
        // Formata como (XX) XXXXX-XXXX
        if digits.count == 11 {
            let areaCode = String(digits.prefix(2))
            let firstPart = String(digits.dropFirst(2).prefix(5))
            let secondPart = String(digits.dropFirst(7))
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        } else if digits.count == 10 {
            let areaCode = String(digits.prefix(2))
            let firstPart = String(digits.dropFirst(2).prefix(4))
            let secondPart = String(digits.dropFirst(6))
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        }
        
        return phone
    }
    
    private func openWhatsAppWithNegotiation(negotiation: Negotiation) {
        guard let seller = store.revealedSeller else { return }
        
        // Tenta usar telefone se disponível
        if let phone = seller.phone, !phone.isEmpty {
            let success = DeepLinkService.shared.openWhatsAppWithNegotiation(
                phoneNumber: phone,
                negotiation: negotiation
            )
            
            if !success {
                // Fallback: copiar mensagem para clipboard
                let message = DeepLinkService.shared.generateNegotiationMessage(negotiation: negotiation)
                DeepLinkService.shared.copyToClipboard(message)
                showingCopiedFeedback = true
            }
        } else {
            // Se não houver telefone, copia a mensagem para clipboard
            let message = DeepLinkService.shared.generateNegotiationMessage(negotiation: negotiation)
            DeepLinkService.shared.copyToClipboard(message)
            showingCopiedFeedback = true
        }
    }
}

// MARK: - Contact Info Row

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let isCopied: Bool
    let onCopy: (() -> Void)?
    var actionType: ActionType = .copy
    
    enum ActionType {
        case copy
        case email
        case phone
        case whatsapp
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let copyAction = onCopy {
                    Button(action: copyAction) {
                        HStack(spacing: 4) {
                            if isCopied {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                            }
                            
                            Text(isCopied ? "Copiado" : "Copiar")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isCopied ? .green : Color(red: 0.5, green: 0.3, blue: 0.9))
                        }
                    }
                }
                
                // Action button based on type
                switch actionType {
                case .email:
                    Button {
                        if let url = URL(string: "mailto:\(value)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "envelope.open")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                    }
                    
                case .phone:
                    Button {
                        if let url = URL(string: "tel:\(value.filter { $0.isNumber })") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "phone")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                    }
                    
                case .whatsapp:
                    Button {
                        let phoneNumber = value.filter { $0.isNumber }
                        if let url = URL(string: "https://wa.me/55\(phoneNumber)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    }
                    
                case .copy:
                    EmptyView()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

