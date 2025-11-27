import ComposableArchitecture
import SwiftUI
import DesignSystem

// MARK: - Add Ticket View (Multi-Step Flow)

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator (oculto no welcome)
                if store.currentStep != .welcome {
                    StepProgressView(currentStep: store.currentStep)
                        .padding()
                }
                
                // Step Content
                TabView(selection: $store.currentStep) {
                    welcomeStepView
                        .tag(TicketCreationStep.welcome)
                    
                    TicketDetailsStepView(store: store)
                        .tag(TicketCreationStep.details)
                    
                    TicketPricingStepView(store: store)
                        .tag(TicketCreationStep.pricing)
                    
                    TicketValidityStepView(store: store)
                        .tag(TicketCreationStep.validity)
                    
                    TicketMediaStepView(store: store)
                        .tag(TicketCreationStep.media)
                    
                    TicketReviewPublishView(store: store)
                        .tag(TicketCreationStep.review)
                    
                    successStepView
                        .tag(TicketCreationStep.success)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: store.currentStep)
                
                // Navigation Buttons (oculto no welcome e success)
                if store.currentStep != .welcome && store.currentStep != .success {
                    navigationButtons
                }
            }
            .background(DSGradients.backgroundMain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Criar Ingresso")
                        .font(.headline)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                store.send(.onDisappear)
            }
            .onChange(of: store.publishSuccess) { _, success in
                // Não fechar automaticamente - deixar usuário ver a tela de sucesso
                // O fechamento será feito pelo botão na successStepView
            }
            .alert("Erro", isPresented: errorBinding) {
                Button("OK") {
                    store.send(.clearError)
                }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Back Button
            if store.canGoBack {
                Button {
                    store.send(.previousStep)
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Voltar")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            
            // Next/Publish Button
            if store.currentStep != .review {
                Button {
                    store.send(.nextStep)
                } label: {
                    HStack {
                        Text("Próximo")
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(store.isCurrentStepValid ? DSColors.primary : DSColors.textTertiary)
                    .foregroundColor(.white)
                    .dsCornerRadius(DSRadius.medium)
                    .dsTapFeedback()
                }
                .disabled(!store.isCurrentStepValid)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
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
    
    // MARK: - Welcome Step View
    
    private var welcomeStepView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Ícone de calendário em círculo
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "calendar")
                    .font(.system(size: 50))
                    .foregroundColor(DSColors.primary)
            }
            
            VStack(spacing: DSSpacing.xs) {
                Text(String(localized: "empty_state.announce_ticket.title"))
                    .font(DSTypography.title1(weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(String(localized: "empty_state.announce_ticket.message"))
                    .font(DSTypography.body())
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                store.send(.nextStep) // Vai para .details
            }) {
                Text(String(localized: "empty_state.announce_ticket.button"))
                    .font(DSTypography.body(weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(DSSpacing.m)
                    .background(DSColors.primary)
                    .dsCornerRadius(DSRadius.medium)
                    .dsTapFeedback()
            }
            .padding(.horizontal, DSSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xxl)
        .background(DSGradients.backgroundMain)
    }
    
    // MARK: - Success Step View
    
    private var successStepView: some View {
        SuccessView(
            icon: "check_successfull",
            iconColor: .green,
            useCustomIcon: true,
            title: String(localized: "success.announce_ticket.title"),
            message: String(localized: "success.announce_ticket.message"),
            buttonTitle: String(localized: "success.announce_ticket.button"),
            buttonAction: {
                store.send(.closeAfterSuccess)
                dismiss()
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .background(AppColors.background)
    }
}

// MARK: - Step Progress View

struct StepProgressView: View {
    let currentStep: TicketCreationStep
    
    var body: some View {
        // Filtrar apenas steps com rawValue >= 0 e < 5 (excluir .welcome e .success)
        let validSteps = TicketCreationStep.allCases.filter { $0.rawValue >= 0 && $0.rawValue < 5 }
        
        return HStack(spacing: 8) {
            ForEach(validSteps, id: \.self) { step in
                VStack(spacing: 4) {
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 10, height: 10)
                    
                    if step == currentStep {
                        Text(step.title)
                            .font(.caption2)
                            .foregroundColor(DSColors.primary)
                    }
                }
                
                if step != validSteps.last {
                    Rectangle()
                        .fill(step.rawValue < currentStep.rawValue ? AppColors.primary : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
    
    private func stepColor(for step: TicketCreationStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return AppColors.primary // Completed
        } else if step == currentStep {
            return AppColors.primary // Current
        } else {
            return Color.gray.opacity(0.3) // Not reached
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
