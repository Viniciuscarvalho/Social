import SwiftUI
import ComposableArchitecture

public struct AnswerQuestionView: View {
    let question: NegotiationQuestion
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var answerText: String = ""
    @FocusState private var isAnswerFieldFocused: Bool
    
    public init(question: NegotiationQuestion, store: StoreOf<NegotiationDetailsFeature>) {
        self.question = question
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Pergunta a ser respondida
                questionCard
                
                // Campo de resposta
                answerField
                
                // Botão enviar
                sendButton
                
                Spacer()
            }
            .padding()
            .navigationTitle("Responder Pergunta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isAnswerFieldFocused = true
            }
        }
    }
    
    // MARK: - Question Card
    
    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Badge de categoria
                HStack(spacing: 4) {
                    Image(systemName: question.category.icon)
                        .font(.system(size: 11))
                    
                    Text(question.category.displayName)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(question.category.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(question.category.color.opacity(0.15))
                )
                
                Spacer()
                
                // Status pendente
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text("Pendente")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }
            }
            
            Text(question.questionText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Timestamp
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                Text(formatDate(question.createdAt))
                    .font(.system(size: 12))
            }
            .foregroundColor(AppColors.tertiaryText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Answer Field
    
    private var answerField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sua Resposta")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            TextEditor(text: $answerText)
                .frame(minHeight: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .focused($isAnswerFieldFocused)
                .onChange(of: answerText) { oldValue, newValue in
                    // Limitar tamanho máximo (opcional)
                    if newValue.count > 1000 {
                        answerText = String(newValue.prefix(1000))
                    }
                }
            
            HStack {
                Text("\(answerText.count) / 1000 caracteres")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.tertiaryText)
                
                Spacer()
                
                if !isValidAnswer {
                    Text("Mínimo 10 caracteres")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    // MARK: - Send Button
    
    private var sendButton: some View {
        Button {
            sendAnswer()
        } label: {
            HStack {
                if store.isSendingMessage {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                
                Image(systemName: "paperplane.fill")
                Text("Enviar Resposta")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isValidAnswer ? AppColors.primary : Color.gray)
            )
        }
        .disabled(!isValidAnswer || store.isSendingMessage)
    }
    
    // MARK: - Helper Methods
    
    private var isValidAnswer: Bool {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 10 && trimmed.count <= 1000
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "pt_BR")
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"
            return "Hoje às \(timeFormatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"
            return "Ontem às \(timeFormatter.string(from: date))"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt_BR")
            dateFormatter.dateFormat = "dd/MM/yyyy 'às' HH:mm"
            return dateFormatter.string(from: date)
        }
    }
    
    private func sendAnswer() {
        guard isValidAnswer else { return }
        
        let trimmedAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        store.send(.answerQuestion(question.id, trimmedAnswer))
        
        // Fecha o sheet após um pequeno delay para permitir que a ação seja processada
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - QuestionCategory Color Extension

extension QuestionCategory {
    var color: Color {
        switch self {
        case .authenticity: return .blue
        case .conditions: return .purple
        case .delivery: return .orange
        case .payment: return .green
        case .other: return .gray
        }
    }
}

