import SwiftUI
import ComposableArchitecture

public struct QuestionSelectionView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuestionIds: Set<String> = []
    @State private var expandedCategories: Set<QuestionCategory> = Set(QuestionCategory.allCases)
    @State private var showingMaxLimitAlert = false
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header com contador
                headerView
                
                // Lista de perguntas por categoria
                questionsList
                
                // Preview e botão enviar
                bottomSection
            }
            .navigationTitle("Selecionar Perguntas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Limite Atingido", isPresented: $showingMaxLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if maxQuestionsAllowed == 0 {
                    Text("Você já atingiu o limite de 5 perguntas por negociação.")
                } else {
                    Text("Você pode selecionar no máximo \(maxQuestionsAllowed) pergunta\(maxQuestionsAllowed > 1 ? "s" : "") por negociação.")
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(selectedQuestionIds.count) de \(maxQuestionsAllowed) selecionadas")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if store.questions.count > 0 {
                    Text("\(store.questions.count) já enviadas")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if selectedQuestionIds.count >= maxQuestionsAllowed && maxQuestionsAllowed > 0 {
                    Text("Limite atingido")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                } else if maxQuestionsAllowed == 0 {
                    Text("Limite de 5 perguntas atingido")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color(red: 0.5, green: 0.3, blue: 0.9))
                        .frame(width: maxQuestionsAllowed > 0 ? geometry.size.width * CGFloat(selectedQuestionIds.count) / CGFloat(maxQuestionsAllowed) : 0, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Questions List
    
    private var questionsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(QuestionCategory.allCases, id: \.self) { category in
                    categorySection(category: category)
                }
            }
        }
    }
    
    private func categorySection(category: QuestionCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header da categoria
            Button {
                withAnimation {
                    if expandedCategories.contains(category) {
                        expandedCategories.remove(category)
                    } else {
                        expandedCategories.insert(category)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Text(category.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(PredefinedQuestions.questions(for: category).count)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Perguntas da categoria
            if expandedCategories.contains(category) {
                ForEach(PredefinedQuestions.questions(for: category)) { question in
                    questionRow(question: question)
                }
            }
        }
    }
    
    private func questionRow(question: PredefinedQuestion) -> some View {
        Button {
            toggleQuestion(question)
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(selectedQuestionIds.contains(question.id) ? Color(red: 0.5, green: 0.3, blue: 0.9) : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if selectedQuestionIds.contains(question.id) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                    }
                }
                
                // Texto da pergunta
                Text(question.text)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(selectedQuestionIds.contains(question.id) ? Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!selectedQuestionIds.contains(question.id) && !canSelectMore)
        .opacity(!selectedQuestionIds.contains(question.id) && !canSelectMore ? 0.5 : 1.0)
    }
    
    private func toggleQuestion(_ question: PredefinedQuestion) {
        withAnimation(.spring(response: 0.3)) {
            if selectedQuestionIds.contains(question.id) {
                selectedQuestionIds.remove(question.id)
            } else {
                if canSelectMore {
                    selectedQuestionIds.insert(question.id)
                } else {
                    showingMaxLimitAlert = true
                }
            }
        }
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: 12) {
            // Preview das selecionadas
            if !selectedQuestionIds.isEmpty {
                previewSection
            }
            
            // Botão enviar
            Button {
                sendQuestions()
            } label: {
                HStack {
                    if store.isSendingMessage {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    }
                    
                    Text(selectedQuestionIds.isEmpty ? "Selecione pelo menos uma pergunta" : "Enviar \(selectedQuestionIds.count) Pergunta\(selectedQuestionIds.count > 1 ? "s" : "")")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedQuestionIds.isEmpty ? Color.gray : Color(red: 0.5, green: 0.3, blue: 0.9))
                )
            }
            .disabled(selectedQuestionIds.isEmpty || store.isSendingMessage)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Perguntas Selecionadas")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedQuestions) { question in
                        selectedQuestionChip(question: question)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
    
    private func selectedQuestionChip(question: PredefinedQuestion) -> some View {
        HStack(spacing: 6) {
            Text(question.text)
                .font(.system(size: 13))
                .lineLimit(1)
            
            Button {
                withAnimation {
                    selectedQuestionIds.remove(question.id)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.2))
        )
        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
    }
    
    private var selectedQuestions: [PredefinedQuestion] {
        PredefinedQuestions.all.filter { selectedQuestionIds.contains($0.id) }
    }
    
    private var maxQuestionsAllowed: Int {
        // Limite total: 5 perguntas
        // Subtrai as perguntas já enviadas
        let alreadySent = store.questions.count
        return max(0, 5 - alreadySent)
    }
    
    private var canSelectMore: Bool {
        selectedQuestionIds.count < maxQuestionsAllowed
    }
    
    private func sendQuestions() {
        guard !selectedQuestionIds.isEmpty else { return }
        
        let questions = selectedQuestions
        
        Task { @MainActor in
            // Envia todas as perguntas sequencialmente
            for question in questions {
                store.send(.sendMessage(question.text))
                // Aguarda um pouco entre cada envio para não sobrecarregar
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
            }
            
            // Aguarda um pouco mais para garantir que todas foram processadas
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
            
            // Fecha o sheet
            store.send(.hideQuestionSelection)
            dismiss()
        }
    }
}

