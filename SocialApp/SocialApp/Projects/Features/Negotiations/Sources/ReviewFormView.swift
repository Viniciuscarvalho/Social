import SwiftUI
import ComposableArchitecture

public struct ReviewFormView: View {
    @Bindable var store: StoreOf<NegotiationReviewFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFocused: Bool
    
    public init(store: StoreOf<NegotiationReviewFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Rating section
                        ratingSection
                        
                        // Comment section
                        commentSection
                        
                        // Guidelines
                        guidelinesSection
                        
                        // Submit button
                        if store.canSubmit {
                            submitButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Avaliar \(store.role.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(store.isSubmitting)
                }
            }
            .onAppear {
                store.send(.onAppear)
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
            .overlay(
                Group {
                    if store.submitSuccess {
                        successOverlay
                    }
                }
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.yellow)
            }
            
            // Text
            VStack(spacing: 8) {
                Text("Como foi sua experiência?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text("Avalie \(store.revieweeName)")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
    
    // MARK: - Rating Section
    
    private var ratingSection: some View {
        VStack(spacing: 16) {
            Text("Sua Avaliação")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            StarRatingView(
                rating: $store.rating,
                maxRating: 5,
                size: 48,
                interactive: true,
                spacing: 12
            )
            
            if store.rating > 0 {
                Text(ratingDescription)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var ratingDescription: String {
        switch store.rating {
        case 1: return "Muito Ruim"
        case 2: return "Ruim"
        case 3: return "Regular"
        case 4: return "Bom"
        case 5: return "Excelente"
        default: return ""
        }
    }
    
    // MARK: - Comment Section
    
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Comentário")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text(store.commentCountText)
                    .font(.system(size: 13))
                    .foregroundColor(store.isCommentValid ? AppColors.tertiaryText : .red)
            }
            
            // Text editor
            ZStack(alignment: .topLeading) {
                if store.comment.isEmpty {
                    Text("Compartilhe sua experiência com outros usuários...")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.tertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $store.comment)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.primaryText)
                    .frame(minHeight: 140)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .focused($isCommentFocused)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCommentFocused ? AppColors.primary : 
                        (store.isCommentValid ? AppColors.border : Color.red), 
                        lineWidth: 1
                    )
            )
            
            // Helper text
            HStack {
                Image(systemName: store.isCommentValid ? "info.circle" : "exclamationmark.triangle")
                    .font(.system(size: 12))
                    .foregroundColor(store.isCommentValid ? AppColors.tertiaryText : .red)
                
                Text(store.commentHelperText)
                    .font(.system(size: 12))
                    .foregroundColor(store.isCommentValid ? AppColors.tertiaryText : .red)
            }
        }
    }
    
    // MARK: - Guidelines Section
    
    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("Dicas para uma boa avaliação")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                guidelineItem(text: "Seja honesto e construtivo")
                guidelineItem(text: "Descreva o que mais te impressionou")
                guidelineItem(text: "Evite linguagem ofensiva")
                guidelineItem(text: "Ajude outros usuários com sua experiência")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.05))
        )
    }
    
    private func guidelineItem(text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.orange)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            store.send(.submitReview)
        } label: {
            HStack {
                if store.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Enviando...")
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Enviar Avaliação")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: store.canSubmit ? 
                        [Color.yellow, Color.orange] : 
                        [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: store.canSubmit ? Color.orange.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!store.canSubmit)
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated stars
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .offset(
                                x: CGFloat(cos(Double(index) * 2 * .pi / 5) * 50),
                                y: CGFloat(sin(Double(index) * 2 * .pi / 5) * 50)
                            )
                            .opacity(0.7)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Avaliação Enviada!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Obrigado por compartilhar sua experiência")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            )
            .padding(40)
        }
    }
}

#Preview {
    ReviewFormView(
        store: Store(
            initialState: NegotiationReviewFeature.State(
                negotiationId: "nego-123",
                revieweeId: "user-123",
                revieweeName: "João Silva",
                role: .seller
            )
        ) {
            NegotiationReviewFeature()
        }
    )
}

