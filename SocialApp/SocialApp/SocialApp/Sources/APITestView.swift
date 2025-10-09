import SwiftUI

/// View simples para testar a API e debugar problemas
struct APITestView: View {
    @State private var testResults: [String] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Testar API de Tickets") {
                    testTicketsAPI()
                }
                .disabled(isLoading)
                
                Button("Testar API de Events") {
                    testEventsAPI()
                }
                .disabled(isLoading)
                
                Button("Limpar Resultados") {
                    testResults.removeAll()
                }
                
                if isLoading {
                    ProgressView("Testando...")
                        .padding()
                }
                
                List(testResults, id: \.self) { result in
                    Text(result)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(result.hasPrefix("✅") ? .green : 
                                       result.hasPrefix("❌") ? .red : .primary)
                }
            }
            .navigationTitle("API Tester")
        }
    }
    
    private func testTicketsAPI() {
        isLoading = true
        testResults.append("🎫 Iniciando teste de tickets...")
        
        Task {
            do {
                let apiTickets: [APITicketResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/tickets",
                    method: .GET
                )
                
                await MainActor.run {
                    testResults.append("✅ Sucesso: \(apiTickets.count) tickets obtidos")
                    
                    if let firstTicket = apiTickets.first {
                        testResults.append("📊 Primeiro ticket: \(firstTicket.name)")
                        testResults.append("💰 Preço: R$ \(firstTicket.price)")
                    }
                }
                
            } catch {
                await MainActor.run {
                    testResults.append("❌ Erro: \(error.localizedDescription)")
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func testEventsAPI() {
        isLoading = true
        testResults.append("📅 Iniciando teste de eventos...")
        
        Task {
            do {
                let apiEvents: [APIEventResponse] = try await NetworkService.shared.requestArray(
                    endpoint: "/events",
                    method: .GET
                )
                
                await MainActor.run {
                    testResults.append("✅ Sucesso: \(apiEvents.count) eventos obtidos")
                    
                    if let firstEvent = apiEvents.first {
                        testResults.append("📊 Primeiro evento: \(firstEvent.name)")
                        testResults.append("📍 Local: \(firstEvent.location.name)")
                    }
                }
                
            } catch {
                await MainActor.run {
                    testResults.append("❌ Erro: \(error.localizedDescription)")
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    APITestView()
}