import SwiftUI
import ComposableArchitecture

public struct NegotiationChatView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let negotiation = store.negotiation {
                // Máquina de Estados Visual (compacta)
                NegotiationStateMachineView(negotiation: negotiation)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Date separator (exemplo: "Jan 20")
                            if let firstQuestion = store.questions.first {
                                dateSeparator(for: firstQuestion.createdAt)
                                    .id("date-\(firstQuestion.id)")
                            }
                            
                            // Documents Gallery (se houver documentos)
                            if !store.documents.isEmpty {
                                DocumentGalleryView(
                                    documents: store.documents,
                                    onDelete: { document in
                                        store.send(.deleteDocument(document.id))
                                    }
                                )
                                .padding(.vertical, 8)
                            }
                            
                            // Messages (perguntas e respostas)
                            ForEach(store.questions) { question in
                                // Pergunta (enviada pelo comprador)
                                if store.isBuyer {
                                    sentMessageBubble(text: question.questionText, timestamp: question.createdAt)
                                        .id(question.id)
                                } else {
                                    receivedMessageBubble(text: question.questionText, timestamp: question.createdAt)
                                        .id(question.id)
                                }
                                
                                // Resposta (se existir)
                                if let answer = question.answer {
                                    if store.isBuyer {
                                        receivedMessageBubble(text: answer.answerText, timestamp: answer.createdAt)
                                            .id("answer-\(answer.id)")
                                    } else {
                                        sentMessageBubble(text: answer.answerText, timestamp: answer.createdAt)
                                            .id("answer-\(answer.id)")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: store.questions.count) { _, _ in
                        // Scroll to bottom quando novas mensagens chegam
                        if let lastQuestion = store.questions.last {
                            withAnimation {
                                proxy.scrollTo(lastQuestion.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        // Scroll to bottom on appear
                        if let lastQuestion = store.questions.last {
                            proxy.scrollTo(lastQuestion.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input Bar
                inputBar
            } else if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $store.showingQuestionSelection) {
            QuestionSelectionView(store: store)
        }
        .sheet(isPresented: $store.showingDocumentUpload) {
            DocumentUploadView(store: store)
        }
        .sheet(isPresented: $store.showingContactReveal) {
            ContactRevealView(store: store)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let negotiation = store.negotiation {
                    HStack(spacing: 8) {
                        // Profile picture
                        AsyncImage(url: URL(string: otherPerson(negotiation).profileImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Text(String(otherPerson(negotiation).name.prefix(1)))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        
                        Text(otherPerson(negotiation).name)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: Implementar chamada
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - Date Separator
    
    private func dateSeparator(for date: Date) -> some View {
        HStack {
            Spacer()
            Text(formatDate(date))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.5, green: 0.3, blue: 0.9)) // Purple como na imagem
                )
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    // MARK: - Message Bubbles
    
    private func sentMessageBubble(text: String, timestamp: Date) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(red: 0.5, green: 0.3, blue: 0.9)) // Purple como na imagem
                    )
                
                Text(formatTime(timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
        }
    }
    
    private func receivedMessageBubble(text: String, timestamp: Date) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemBackground))
                    )
                
                Text(formatTime(timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            Spacer()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            // Botão de perguntas pré-definidas (apenas para comprador)
            if store.isBuyer {
                Button {
                    store.send(.showQuestionSelection)
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
            } else {
                // Emoji button (para vendedor)
                Button {
                    // TODO: Implementar emoji picker
                } label: {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
            }
            
            // Text input
            TextField("Digite aqui...", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )
                .focused($isInputFocused)
                .lineLimit(1...5)
            
            // Send button
            Button {
                sendMessage()
            } label: {
                if store.isSendingMessage {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(messageText.isEmpty ? .secondary : Color(red: 0.5, green: 0.3, blue: 0.9))
                }
            }
            .disabled(messageText.isEmpty || store.isSendingMessage)
            
            // Botão de upload de documento (apenas para vendedor)
            if !store.isBuyer {
                Button {
                    store.send(.showDocumentUpload)
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.9))
                }
            } else {
                // Microphone button (para comprador)
                Button {
                    // TODO: Implementar gravação de áudio
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Helpers
    
    private func otherPerson(_ negotiation: Negotiation) -> User {
        let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") ?? ""
        if negotiation.buyerId == currentUserId {
            return negotiation.seller ?? User(name: "Vendedor", email: "")
        } else {
            return negotiation.buyer ?? User(name: "Comprador", email: "")
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let textToSend = messageText.trimmingCharacters(in: .whitespaces)
        messageText = ""
        isInputFocused = false
        
        store.send(.sendMessage(textToSend))
    }
}

