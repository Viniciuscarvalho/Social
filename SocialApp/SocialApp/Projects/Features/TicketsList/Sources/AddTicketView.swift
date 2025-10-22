import ComposableArchitecture
import SwiftUI

struct AddTicketView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @Environment(\.dismiss) var dismiss
    @Dependency(\.ticketsClient) var ticketsClient
    
    var body: some View {
        NavigationStack {
            mainContent
                .background(AppColors.background)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
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
                    Button("OK") { }
                } message: {
                    Text(store.errorMessage ?? "")
                }
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                formView
                testButtonView
                publishButtonView
            }
            .padding(.bottom, 40)
        }
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
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.accentGreen)
            
            Text("Vender Ingresso")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primaryText)
            
            Text("Preencha os dados do ingresso que deseja vender")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var formView: some View {
        VStack(spacing: 16) {
            eventSelectorView
            FormField(
                title: "Nome do Ingresso",
                text: $store.ticketName,
                placeholder: "Ex: VIP, Pista, Camarote"
            )
            FormField(
                title: "Preço",
                text: $store.price,
                placeholder: "Ex: 120,00"
            )
            FormField(
                title: "Tipo",
                text: Binding(
                    get: { store.ticketType.displayName },
                    set: { _ in }
                ),
                placeholder: "Selecione o tipo"
            )
            FormField(
                title: "Descrição",
                text: $store.description,
                placeholder: "Descrição",
                isTextEditor: true
            )
        }
        .padding(.horizontal)
    }
    
    private var eventSelectorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evento")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            eventSelectorContent
        }
    }
    
    @ViewBuilder
    private var eventSelectorContent: some View {
        if let eventId = store.selectedEventId {
            selectedEventView(eventId: eventId)
        } else {
            eventSelectionView
        }
    }
    
    private func selectedEventView(eventId: UUID) -> some View {
        let selectedEvent = store.availableEvents.first { UUID(uuidString: $0.id) == eventId }
        
        return VStack(alignment: .leading, spacing: 4) {
            Text(selectedEvent?.name ?? "Evento Selecionado")
                .font(.body)
                .foregroundColor(AppColors.accentGreen)
            Text("ID: \(eventId.uuidString)")
                .font(.caption2)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accentGreen.opacity(0.1))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var eventSelectionView: some View {
        if store.isLoadingEvents {
            loadingEventsView
        } else {
            eventMenuView
        }
    }
    
    private var loadingEventsView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Carregando eventos...")
                .font(.body)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
    }
    
    private var eventMenuView: some View {
        Menu {
            ForEach(store.availableEvents, id: \.id) { event in
                Button(event.name) {
                    if let eventId = UUID(uuidString: event.id) {
                        store.send(.setSelectedEventId(eventId))
                    }
                }
            }
        } label: {
            HStack {
                Text("Selecionar Evento")
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(12)
            .background(AppColors.cardBackground)
            .cornerRadius(8)
        }
    }
    
    private var testButtonView: some View {
        VStack(spacing: 8) {
            Button(action: testAPICall) {
                Text("🧪 Testar Nova API JWT")
                    .font(.system(size: 12))
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(15)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func testAPICall() {
        print("🧪 Testando envio para Nova API JWT...")
        
        logFormData()
        
        guard validateTestData() else { return }
        
        Task {
            await performJWTAPITest()
        }
    }
    
    private func logFormData() {
        print("📋 Dados do formulário:")
        print("   ℹ️ sellerId será injetado automaticamente do JWT")
        print("   store.selectedEventId: \(store.selectedEventId?.uuidString ?? "nil")")
        print("   store.ticketName: '\(store.ticketName)'")
        print("   store.price: '\(store.price)'")
        print("   store.ticketType: \(store.ticketType)")
        
        let token = UserDefaults.standard.string(forKey: "authToken")
        print("   Token disponível: \(token != nil ? "✅ Sim" : "❌ Não")")
    }
    
    private func validateTestData() -> Bool {
        guard store.selectedEventId != nil else {
            print("❌ Nenhum evento selecionado")
            return false
        }
        
        guard AddTicketFeature.parsePrice(store.price) != nil else {
            print("❌ Preço inválido: '\(store.price)'")
            return false
        }
        
        guard UserDefaults.standard.string(forKey: "authToken") != nil else {
            print("❌ Token JWT não disponível!")
            return false
        }
        
        return true
    }
    
    private func performJWTAPITest() async {
        guard let eventId = store.selectedEventId,
              let priceValue = AddTicketFeature.parsePrice(store.price) else { return }
        
        print("\n🔍 TESTE DA NOVA API JWT")
        
        // Primeiro, verificar se o event existe
        await verifyEventExists(eventId)
        
        let jwtTestData: [String: Any] = [
            "eventId": eventId.uuidString,
            "name": store.ticketName,
            "price": priceValue,
            "ticketType": store.ticketType.rawValue,
            "validUntil": ISO8601DateFormatter().string(from: store.validUntil)
        ]
        
        await sendJWTRequest(jwtTestData)
    }
    
    private func verifyEventExists(_ eventId: UUID) async {
        print("\n🔍 VERIFICANDO SE O EVENTO EXISTE...")
        
        guard let url = URL(string: "https://ticketplace-api.onrender.com/api/events/\(eventId.uuidString)") else {
            print("❌ URL inválida para verificar evento")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status verificação evento: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    if httpResponse.statusCode == 200 {
                        print("✅ Evento existe: \(responseString)")
                    } else {
                        print("❌ Evento não encontrado ou erro: \(responseString)")
                        print("🚨 POSSÍVEL CAUSA: Event ID '\(eventId.uuidString)' pode não existir no backend!")
                    }
                }
            }
        } catch {
            print("❌ Erro ao verificar evento: \(error)")
        }
    }
    
    private func sendJWTRequest(_ data: [String: Any]) async {
        print("\n📤 ENVIANDO PARA API JWT...")
        
        guard let url = URL(string: "https://ticketplace-api.onrender.com/api/tickets") else {
            print("❌ URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Token JWT adicionado: \(token.prefix(20))...")
            
            // Decodificar o JWT para ver o conteúdo
            await decodeJWTToken(token)
        } else {
            print("⚠️ Nenhum token de auth encontrado!")
            return
        }
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = requestData
            
            if let requestString = String(data: requestData, encoding: .utf8) {
                print("📤 JSON enviado (sellerId será injetado pelo backend):")
                print("   \(requestString)")
            }
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let success = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                print("📊 Status da API: \(httpResponse.statusCode)")
                
                // Log dos headers de resposta
                print("📋 Headers da resposta:")
                for (key, value) in httpResponse.allHeaderFields {
                    print("   \(key): \(value)")
                }
                
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("📥 Resposta da API:")
                    print("   \(responseString)")
                    
                    if success {
                        print("🎉 SUCESSO! Ticket criado com JWT!")
                    } else {
                        print("❌ Erro na criação do ticket - Status \(httpResponse.statusCode)")
                        await analyzeError(httpResponse.statusCode, responseString)
                    }
                }
            }
            
        } catch {
            print("❌ Erro no envio JWT: \(error)")
        }
        
        // Teste adicional com diferentes formatos
        await testAlternativeFormats()
    }
    
    private func decodeJWTToken(_ token: String) async {
        print("\n🔍 DECODIFICANDO TOKEN JWT...")
        
        let parts = token.components(separatedBy: ".")
        guard parts.count >= 2 else {
            print("❌ Token JWT inválido - não tem partes suficientes")
            return
        }
        
        // Decodificar o payload (segunda parte)
        var payload = parts[1]
        
        // Adicionar padding se necessário
        let remainder = payload.count % 4
        if remainder > 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }
        
        if let data = Data(base64Encoded: payload),
           let jsonString = String(data: data, encoding: .utf8) {
            print("📋 Payload do JWT:")
            print("   \(jsonString)")
            
            // Tentar parsear como JSON para mostrar de forma mais limpa
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🔍 Campos no JWT:")
                    for (key, value) in json {
                        print("   \(key): \(value)")
                    }
                    
                    // Verificar campos importantes
                    if let userId = json["id"] as? String ?? json["user_id"] as? String ?? json["sub"] as? String {
                        print("✅ User ID no JWT: \(userId)")
                    } else {
                        print("⚠️ Nenhum user ID encontrado no JWT!")
                    }
                    
                    if let exp = json["exp"] as? Int {
                        let expirationDate = Date(timeIntervalSince1970: TimeInterval(exp))
                        print("⏰ Token expira em: \(expirationDate)")
                        
                        if expirationDate < Date() {
                            print("🚨 TOKEN EXPIRADO!")
                        }
                    }
                }
            } catch {
                print("❌ Erro ao parsear payload do JWT: \(error)")
            }
        } else {
            print("❌ Erro ao decodificar payload do JWT")
        }
    }
    
    private func analyzeError(_ statusCode: Int, _ errorResponse: String) async {
        print("\n🔍 ANÁLISE DO ERRO:")
        
        switch statusCode {
        case 400:
            print("❌ Bad Request (400) - Problema na estrutura da requisição")
            print("  • Verifique se todos os campos obrigatórios estão presentes")
            print("  • Verifique o formato dos dados (UUID, data, etc.)")
            
        case 401:
            print("🔐 Unauthorized (401) - Problema de autenticação")
            print("  • Token JWT pode estar inválido ou expirado")
            print("  • Verifique se o header Authorization está correto")
            
        case 403:
            print("🚫 Forbidden (403) - Problema de autorização")
            print("  • Usuário autenticado mas sem permissão")
            print("  • Verifique se o usuário pode criar tickets")
            
        case 404:
            print("🔍 Not Found (404) - Recurso não encontrado")
            print("  • Event ID pode não existir")
            print("  • Endpoint pode estar incorreto")
            
        case 422:
            print("📝 Unprocessable Entity (422) - Erro de validação")
            print("  • Dados não passaram na validação do servidor")
            print("  • Verifique formatos e valores dos campos")
            
        case 500:
            print("💥 Internal Server Error (500) - Erro no servidor")
            print("  • Problema no backend (database, lógica, etc.)")
            print("  • Pode ser problema com extração do sellerId do JWT")
            print("  • Verifique os logs do servidor no Render")
            
        default:
            print("❓ Status code não comum: \(statusCode)")
        }
        
        // Tentar parsear o erro como JSON
        if let data = errorResponse.data(using: .utf8) {
            do {
                if let errorJson = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📋 Detalhes do erro:")
                    for (key, value) in errorJson {
                        print("   \(key): \(value)")
                    }
                }
            } catch {
                print("📋 Erro não é um JSON válido: \(errorResponse)")
            }
        }
    }
    
    private func testAlternativeFormats() async {
        print("\n🔄 TESTANDO FORMATOS ALTERNATIVOS...")
        
        guard let eventId = store.selectedEventId,
              let priceValue = AddTicketFeature.parsePrice(store.price),
              let token = UserDefaults.standard.string(forKey: "authToken") else { 
            print("❌ Dados insuficientes para teste alternativo")
            return 
        }
        
        let alternativeFormats: [(String, [String: Any])] = [
            ("1. Com description", [
                "eventId": eventId.uuidString,
                "name": store.ticketName,
                "description": store.description.isEmpty ? "Ticket criado via app" : store.description,
                "price": priceValue,
                "ticketType": store.ticketType.rawValue,
                "validUntil": ISO8601DateFormatter().string(from: store.validUntil)
            ]),
            ("2. Sem validUntil", [
                "eventId": eventId.uuidString,
                "name": store.ticketName,
                "price": priceValue,
                "ticketType": store.ticketType.rawValue
            ]),
            ("3. Com campos snake_case", [
                "event_id": eventId.uuidString,
                "name": store.ticketName,
                "price": priceValue,
                "ticket_type": store.ticketType.rawValue,
                "valid_until": ISO8601DateFormatter().string(from: store.validUntil)
            ]),
            ("4. Mínimo absoluto", [
                "eventId": eventId.uuidString,
                "name": store.ticketName,
                "price": priceValue
            ])
        ]
        
        for (description, testData) in alternativeFormats {
            print("\n🧪 Testando: \(description)")
            await sendAlternativeFormat(testData, description: description, token: token)
            
            // Pausa entre testes
            try? await Task.sleep(for: .milliseconds(1000))
        }
    }
    
    private func sendAlternativeFormat(_ data: [String: Any], description: String, token: String) async {
        guard let url = URL(string: "https://ticketplace-api.onrender.com/api/tickets") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = requestData
            
            if let requestString = String(data: requestData, encoding: .utf8) {
                print("   📤 JSON: \(requestString)")
            }
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                let success = httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                
                if let responseString = String(data: responseData, encoding: .utf8) {
                    if success {
                        print("   ✅ SUCESSO (\(httpResponse.statusCode)): \(responseString)")
                        print("   🎯 FORMATO FUNCIONAL ENCONTRADO: \(description)")
                    } else {
                        print("   ❌ Falha (\(httpResponse.statusCode)): \(responseString)")
                    }
                }
            }
            
        } catch {
            print("   ❌ Erro no teste \(description): \(error)")
        }
    }

    
    private var publishButtonView: some View {
        Button(action: {
            store.send(.publishTicket)
        }) {
            HStack {
                if store.isPublishing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(store.isPublishing ? "Publicando..." : "Publicar Ingresso")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.accentGreen.gradient)
            .cornerRadius(12)
        }
        .disabled(store.isPublishing)
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

// MARK: - Form Field Component

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isTextEditor: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
            
            if isTextEditor {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(AppColors.cardBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator.opacity(0.5), lineWidth: 1)
                    )
            }
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
