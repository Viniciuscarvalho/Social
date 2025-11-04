import SwiftUI
import ComposableArchitecture

public struct NegotiationRequestView: View {
    @Bindable var store: StoreOf<NegotiationRequestFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<NegotiationRequestFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Informações do ingresso
                    ticketInfoSection
                    
                    // Status de verificação
                    verificationSection
                    
                    // Formulário de proposta (opcional)
                    if store.canNegotiate {
                        proposalSection
                    }
                    
                    // Botão de enviar
                    submitButton
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Solicitar Negociação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert("Negociação Enviada!", isPresented: $store.showingSuccessAlert) {
                Button("OK") {
                    store.send(.dismissSuccessAlert)
                }
            } message: {
                Text("Sua solicitação foi enviada ao vendedor. Você receberá uma notificação quando houver resposta.")
            }
            .alert("Erro", isPresented: $store.showingErrorAlert) {
                Button("OK") {
                    store.send(.dismissErrorAlert)
                }
            } message: {
                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Ticket Info Section
    
    private var ticketInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.ticketName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Vendido por \(store.sellerName)")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("R$ \(String(format: "%.2f", store.ticketPrice))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primary)
                    
                    Text("Preço atual")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
            )
            .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Verification Section
    
    @ViewBuilder
    private var verificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissões de Negociação")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            if store.isCheckingPermissions {
                HStack {
                    ProgressView()
                        .scaleEffect(0.9)
                    Text("Verificando permissões...")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.cardBackground)
                )
            } else if let verification = store.userVerification {
                VStack(spacing: 12) {
                    TrustScoreBadge(
                        verificationLevel: verification.verificationLevel,
                        trustScore: verification.trustScore,
                        showDetails: true
                    )
                    
                    NegotiationCounter(
                        count: store.activeNegotiationsCount,
                        maxCount: 3
                    )
                    
                    HStack {
                        Image(systemName: store.canNegotiate ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(store.canNegotiate ? .green : .red)
                        
                        Text(store.verificationMessage)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(store.canNegotiate ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    )
                }
            }
        }
    }
    
    // MARK: - Proposal Section
    
    private var proposalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Proposta de Preço (Opcional)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            Text("Você pode sugerir um preço diferente. O vendedor poderá aceitar ou recusar.")
                .font(.system(size: 13))
                .foregroundColor(AppColors.tertiaryText)
            
            HStack {
                Text("R$")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                TextField("0,00", text: $store.proposedPrice)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            store.send(.submitNegotiation)
        } label: {
            HStack {
                if store.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Enviando...")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                    Text("Enviar Solicitação")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(store.canSubmit ? AppColors.primary : Color.gray)
            )
        }
        .disabled(!store.canSubmit)
    }
}

