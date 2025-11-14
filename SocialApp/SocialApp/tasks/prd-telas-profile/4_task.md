## status: pending

<task_context>
<domain>features/tickets/view</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>swiftui|coreimage</dependencies>
</task_context>

# Tarefa 4.0: Adicionar QR Code aos cards de MyTickets

## Visão Geral

Implementar geração de QR Code usando Core Image e exibir no card de cada ticket conforme layout do Figma. O QR Code deve conter o ID do ticket e ser exibido no lado direito do card.

<requirements>
- Criar componente `QRCodeView` reutilizável
- Usar Core Image CIFilter para gerar QR Code
- QR Code de tamanho 80x80 no card
- Conter ticket ID como dados
- Ajustar layout do MyTicketCard para incluir QR à direita
- Formato de data ajustado para "Feb, Mon 20, 2025"
- Mostrar "Ticket : 02" (quantidade ou número)
</requirements>

## Subtarefas

- [ ] 4.1 Criar `QRCodeView.swift` em Commons
- [ ] 4.2 Implementar geração de QR Code com Core Image
- [ ] 4.3 Atualizar layout do `MyTicketCard`
- [ ] 4.4 Ajustar formato de data no card
- [ ] 4.5 Adicionar campo de quantidade/número do ticket
- [ ] 4.6 Testar renderização em diferentes tamanhos
- [ ] 4.7 Garantir legibilidade em light/dark mode

## Detalhes de Implementação

### 4.2 QRCodeView Component
```swift
import SwiftUI
import CoreImage.CIFilterBuiltins

public struct QRCodeView: View {
    let data: String
    let size: CGFloat
    
    public init(data: String, size: CGFloat = 100) {
        self.data = data
        self.size = size
    }
    
    public var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
                .background(Color.white)
                .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "qrcode")
                        .foregroundColor(.gray)
                )
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        guard let data = string.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up para melhor qualidade
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
```

### 4.3 Atualizar MyTicketCard
```swift
struct MyTicketCard: View {
    let ticket: Ticket
    let currentUserId: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Info à esquerda
                VStack(alignment: .leading, spacing: 8) {
                    Text(ticket.name)
                        .font(.headline)
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    Text(formattedDate(ticket.validUntil))
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("Ticket : \(ticketNumber)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Spacer()
                
                // QR Code à direita
                QRCodeView(data: ticket.id, size: 80)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .shadow(color: AppColors.cardShadow.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, EEE dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private var ticketNumber: String {
        // Se ticket tem quantidade, mostrar; senão, mostrar índice ou ID curto
        return String(format: "%02d", ticket.quantity ?? 1)
    }
}
```

### 4.5 Adicionar Campo ao Ticket Model
```swift
// Em Models.swift - verificar se já existe, senão adicionar:
public struct Ticket {
    // ... campos existentes ...
    public var quantity: Int? // Número do ticket ou quantidade
}
```

## Critérios de Sucesso

- ✅ QR Code gerado corretamente com ticket ID
- ✅ QR Code é escaneável e legível
- ✅ Layout do card mostra info à esquerda e QR à direita
- ✅ Data formatada como "Feb, Mon 20, 2025"
- ✅ "Ticket : XX" exibido corretamente
- ✅ QR Code tem fundo branco para contraste
- ✅ Funciona em light/dark mode
- ✅ Performance adequada (QR cache se necessário)

## Arquivos relevantes
- `SocialApp/Sources/Commons/QRCodeView.swift` (NOVO)
- `Projects/Features/TicketsList/Sources/MyTicketsView.swift`
- `Domain/Sources/Models.swift`


