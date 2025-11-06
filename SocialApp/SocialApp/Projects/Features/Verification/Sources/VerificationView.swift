import SwiftUI
import ComposableArchitecture

public struct VerificationView: View {
    @Bindable var store: StoreOf<VerificationFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<VerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Progress bar
                progressSection
                
                // Content - mostra a view correta baseado no currentStep
                ZStack {
                    switch store.currentStep {
                    case .email:
                        EmailVerificationView(
                            store: store.scope(
                                state: \.emailVerification,
                                action: \.emailVerification
                            )
                        )
                        
                    case .phone:
                        PhoneVerificationView(
                            store: store.scope(
                                state: \.phoneVerification,
                                action: \.phoneVerification
                            )
                        )
                        
                    case .document:
                        DocumentVerificationView(
                            store: store.scope(
                                state: \.documentVerification,
                                action: \.documentVerification
                            )
                        )
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Navigation buttons
                navigationButtonsSection
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert("Erro", isPresented: .constant(store.showingErrorAlert)) {
            Button("OK") {
                store.send(.dismissErrorAlert)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Button {
                store.send(.dismiss)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Verificação da Conta")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Close button
            Button {
                store.send(.dismiss)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * store.progress)
                }
                .frame(height: 8)
            }
            .frame(height: 8)
            
            // Progress text
            HStack {
                Text("Etapa \(store.currentStepNumber) de \(store.totalSteps)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text(store.progressPercentage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Navigation Buttons Section
    
    private var navigationButtonsSection: some View {
        HStack(spacing: 12) {
            // Previous button (disabled on first visible step)
            let isFirstStep = store.visibleSteps.firstIndex(of: store.currentStep) == 0
            
            Button {
                store.send(.previousStep)
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Anterior")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isFirstStep ? .white.opacity(0.3) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFirstStep ? Color.white.opacity(0.1) : Color.white.opacity(0.3),
                            lineWidth: 1
                        )
                )
            }
            .disabled(isFirstStep)
            
            // Skip button
            Button {
                store.send(.skipStep)
            } label: {
                Text("Pular")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}

#Preview {
    VerificationView(
        store: Store(
            initialState: VerificationFeature.State(userEmail: "user@example.com"),
            reducer: { VerificationFeature() }
        )
    )
}

