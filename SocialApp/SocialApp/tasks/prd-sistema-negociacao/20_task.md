# Tarefa 20.0: Implementar Integração com WhatsApp (S)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar funcionalidade que gera mensagem pré-formatada com detalhes da negociação e abre o WhatsApp via deep link, facilitando a transição para negociação externa.

## Subtarefas

- [ ] 20.1 Expandir `DeepLinkService` com método para WhatsApp
- [ ] 20.2 Implementar geração de mensagem pré-formatada
- [ ] 20.3 Implementar deep link para WhatsApp
- [ ] 20.4 Adicionar fallback se WhatsApp não instalado
- [ ] 20.5 Integrar botão na `ContactRevealView`
- [ ] 20.6 Testar deep link em diferentes cenários
- [ ] 20.7 Adicionar tratamento de erros

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Services/DeepLinkService.swift`
- Expandir serviço existente

### Método para WhatsApp

```swift
public func openWhatsApp(
    phoneNumber: String,
    message: String
) {
    let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let urlString = "whatsapp://send?phone=\(phoneNumber)&text=\(encodedMessage)"
    
    if let url = URL(string: urlString),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else {
        // Fallback: copiar mensagem para clipboard
        UIPasteboard.general.string = message
    }
}
```

### Mensagem Pré-formatada

```
Olá! Vi seu ingresso no SocialApp e gostaria de negociar.

📅 Evento: [Nome do Evento]
🎫 Ingresso: [Nome do Ingresso]
💰 Preço: R$ [Valor]
🆔 ID da Negociação: [ID]

Podemos conversar sobre os detalhes?
```

### Integração

- Adicionar botão "Abrir WhatsApp" na `ContactRevealView`
- Botão aparece apenas se telefone estiver disponível
- Gerar mensagem com dados da negociação

## Critérios de Sucesso

- [ ] Deep link para WhatsApp funciona
- [ ] Mensagem pré-formatada é gerada corretamente
- [ ] Fallback funciona se WhatsApp não instalado
- [ ] Botão está integrado na view
- [ ] Mensagem inclui todos os detalhes relevantes
- [ ] Tratamento de erros está implementado
- [ ] Build do projeto compila sem erros

## Dependências

- **19.0**: Revelação de contato deve estar implementada

## Observações

- Verificar se `DeepLinkService` já existe e expandir
- Considerar outros apps de mensagem (Telegram, etc.) no futuro
- Mensagem deve ser clara e profissional

