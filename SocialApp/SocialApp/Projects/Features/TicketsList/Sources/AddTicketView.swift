import ComposableArchitecture
import SwiftUI

// MARK: - Add Ticket View (Multi-Step Flow)

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                StepProgressView(currentStep: store.currentStep)
                    .padding()
                
                // Step Content
                TabView(selection: $store.currentStep) {
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
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: store.currentStep)
                
                // Navigation Buttons
                navigationButtons
            }
            .background(AppColors.background)
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
            .onChange(of: store.publishSuccess) { _, success in
                if success {
                    dismiss()
                }
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
                    .background(store.isCurrentStepValid ? AppColors.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
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
}

// MARK: - Step Progress View

struct StepProgressView: View {
    let currentStep: TicketCreationStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(TicketCreationStep.allCases, id: \.self) { step in
                VStack(spacing: 4) {
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 10, height: 10)
                    
                    if step == currentStep {
                        Text(step.title)
                            .font(.caption2)
                            .foregroundColor(AppColors.primary)
                    }
                }
                
                if step != TicketCreationStep.allCases.last {
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
