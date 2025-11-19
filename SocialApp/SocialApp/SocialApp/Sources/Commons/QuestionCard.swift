import SwiftUI

public struct QuestionCard: View {
    let question: NegotiationQuestion
    @State private var isExpanded: Bool = false
    
    public init(question: NegotiationQuestion) {
        self.question = question
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header com categoria e status
            HStack(spacing: 8) {
                // Badge de categoria
                categoryBadge
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            
            // Texto da pergunta
            Text(question.questionText)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Resposta (se disponível)
            if let answer = question.answer {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        
                        Text("Resposta")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                    }
                    
                    if shouldShowExpansionButton(for: answer.answerText) {
                        Text(isExpanded ? answer.answerText : truncatedText(answer.answerText))
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Text(isExpanded ? "Ver menos" : "Ver mais")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppColors.primary)
                        }
                    } else {
                        Text(answer.answerText)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                // Indicador de pendente
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("Aguardando resposta")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
            
            // Timestamps
            HStack(spacing: 12) {
                timestampRow(
                    icon: "calendar",
                    text: formatDate(question.createdAt)
                )
                
                if let answeredAt = question.answeredAt {
                    timestampRow(
                        icon: "checkmark.circle",
                        text: "Respondida em \(formatDate(answeredAt))"
                    )
                }
            }
            .font(.system(size: 12))
            .foregroundColor(AppColors.tertiaryText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(question.isAnswered ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    question.isAnswered ? Color.green.opacity(0.3) : Color.orange.opacity(0.3),
                    lineWidth: 1
                )
        )
        .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Category Badge
    
    private var categoryBadge: some View {
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
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(question.isAnswered ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(question.isAnswered ? "Respondida" : "Pendente")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(question.isAnswered ? .green : .orange)
        }
    }
    
    // MARK: - Helper Methods
    
    private func timestampRow(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
        }
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
    
    private func shouldShowExpansionButton(for text: String) -> Bool {
        // Mostra botão de expansão se o texto tiver mais de 150 caracteres
        text.count > 150
    }
    
    private func truncatedText(_ text: String) -> String {
        String(text.prefix(150)) + "..."
    }
}

