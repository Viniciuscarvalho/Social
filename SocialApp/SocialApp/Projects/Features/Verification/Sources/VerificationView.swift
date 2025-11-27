import SwiftUI
import ComposableArchitecture
import Foundation
import DesignSystem

// Importar as views de verificação que estão definidas nos arquivos de Feature
// PhoneVerificationView está em PhoneVerificationFeature.swift
// DocumentVerificationView está em DocumentVerificationFeature.swift

public struct VerificationView: View {
    @Bindable var store: StoreOf<VerificationFeature>
    @Environment(\.dismiss) private var dismiss
    
    public init(store: StoreOf<VerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background
            DSGradients.backgroundMain
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
        .onDisappear {
            store.send(.onDisappear)
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
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(DSColors.backgroundSecondary.opacity(0.5))
                    .clipShape(Circle())
            }
            .dsTapFeedback()
            
            Spacer()
            
            Text("Verificação da Conta")
                .font(DSTypography.headline(weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            // Close button
            Button {
                store.send(.dismiss)
            } label: {
                Image(systemName: "xmark")
                    .font(DSTypography.body(weight: .semibold))
                    .foregroundColor(DSColors.textSecondary)
                    .frame(width: 40, height: 40)
            }
            .dsTapFeedback()
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.vertical, DSSpacing.sm)
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: DSSpacing.sm) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DSRadius.xs)
                        .fill(DSColors.backgroundSecondary)
                    
                    RoundedRectangle(cornerRadius: DSRadius.xs)
                        .fill(DSGradients.primary)
                        .frame(width: geometry.size.width * store.progress)
                }
                .frame(height: 8)
            }
            .frame(height: 8)
            
            // Progress text
            HStack {
                Text("Etapa \(store.currentStepNumber) de \(store.totalSteps)")
                    .font(DSTypography.caption1(weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                Text(store.progressPercentage)
                    .font(DSTypography.caption1(weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
            }
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.vertical, DSSpacing.sm)
    }
    
    // MARK: - Navigation Buttons Section
    
    private var navigationButtonsSection: some View {
        HStack(spacing: DSSpacing.sm) {
            // Previous button (disabled on first visible step)
            let isFirstStep = store.visibleSteps.firstIndex(of: store.currentStep) == 0
            
            Button {
                store.send(.previousStep)
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Anterior")
                }
                .font(DSTypography.footnote(weight: .semibold))
                .foregroundColor(isFirstStep ? DSColors.textTertiary : DSColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.medium)
                        .stroke(
                            isFirstStep ? DSColors.border : DSColors.primary,
                            lineWidth: 1
                        )
                )
            }
            .disabled(isFirstStep)
            .dsTapFeedback()
            
            // Skip button
            Button {
                store.send(.skipStep)
            } label: {
                Text("Pular")
                    .font(DSTypography.footnote(weight: .semibold))
                    .foregroundColor(DSColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.medium)
                            .stroke(DSColors.border, lineWidth: 1)
                    )
            }
            .dsTapFeedback()
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.bottom, DSSpacing.l)
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

