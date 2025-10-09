# Guia de Solução para Problemas de Parsing da API

## Problema Original
A aplicação não conseguia fazer o parse e decode correto dos dados da API, sempre caindo no fallback de arquivos JSON locais.

## Soluções Implementadas

### 1. Novos Modelos de API (APIModels.swift)
Criados modelos específicos para a resposta da API que:
- Suportam tanto camelCase quanto snake_case para compatibilidade
- Incluem computed properties para conversão de campos
- Têm mappers para converter para os modelos de domínio
- Tratam parsing flexível de datas

### 2. NetworkService Melhorado
- Removida estratégia fixa de decodificação de datas
- Melhor logging de erros de decodificação
- Debug detalhado da resposta da API

### 3. Clients Atualizados
- EventsClient, TicketsClient e UserClient agora usam os novos modelos da API
- Melhor logging para rastrear onde estão os problemas
- Tratamento mais robusto de erros

### 4. APITester para Debugging
Ferramenta para testar e debugar problemas de API:
```swift
// Para testar a API completa
await APITester.runFullAPITest()

// Para testar conectividade básica
await APITester.testAPIConnection()
```

## Como Usar

### 1. Executar Teste Completo
No seu código, adicione temporariamente:
```swift
Task {
    await APITester.runFullAPITest()
}
```

### 2. Verificar Logs
Os logs agora mostram:
- ✅ Sucesso na obtenção de dados da API
- ❌ Falhas e detalhes dos erros
- 🔄 Quando está usando fallback
- 📊 Informações sobre a resposta da API

### 3. Estrutura Esperada da API

#### Para Events:
```json
[
  {
    "id": "string",
    "name": "string", 
    "description": "string",
    "imageURL": "string", // ou "image_url"
    "startPrice": 0.0, // ou "start_price"
    "location": {
      "name": "string",
      "address": "string",
      "city": "string", 
      "state": "string",
      "country": "string",
      "coordinate": { // ou "coordinates"
        "latitude": 0.0,
        "longitude": 0.0
      }
    },
    "category": "string",
    "isRecommended": true, // ou "is_recommended"
    "rating": 0.0,
    "reviewCount": 0, // ou "review_count"
    "createdAt": "2023-01-01T00:00:00Z", // ou "created_at"
    "eventDate": "2023-01-01T00:00:00Z" // ou "event_date"
  }
]
```

#### Para Tickets:
```json
[
  {
    "id": "string",
    "eventId": "string", // ou "event_id"
    "sellerId": "string", // ou "seller_id" 
    "name": "string",
    "price": 0.0,
    "originalPrice": 0.0, // ou "original_price"
    "ticketType": "string", // ou "ticket_type"
    "status": "string",
    "validUntil": "2023-01-01T00:00:00Z", // ou "valid_until"
    "createdAt": "2023-01-01T00:00:00Z", // ou "created_at"
    "isFavorited": false // ou "is_favorited"
  }
]
```

#### Para Users:
```json
{
  "id": "string",
  "name": "string",
  "title": "string",
  "profileImageURL": "string", // ou "profile_image_url"
  "email": "string",
  "followersCount": 0, // ou "followers_count"
  "followingCount": 0, // ou "following_count"
  "ticketsCount": 0, // ou "tickets_count"
  "isVerified": false, // ou "is_verified"
  "tickets": [], // array de tickets (opcional)
  "createdAt": "2023-01-01T00:00:00Z" // ou "created_at"
}
```

## Formatos de Data Suportados
Os mappers agora suportam múltiplos formatos de data:
- `yyyy-MM-dd'T'HH:mm:ss.SSSZ` (ISO 8601 com milissegundos)
- `yyyy-MM-dd'T'HH:mm:ssZ` (ISO 8601 sem milissegundos)  
- `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'` (ISO 8601 com Z literal)
- `yyyy-MM-dd'T'HH:mm:ss'Z'` (ISO 8601 com Z literal, sem milissegundos)
- `yyyy-MM-dd HH:mm:ss` (Formato simples)
- `yyyy-MM-dd` (Apenas data)

## Debugging de Problemas

### 1. Se ainda estiver usando fallback:
1. Execute `await APITester.runFullAPITest()`
2. Verifique os logs para ver o erro específico
3. Compare a estrutura da resposta da API com o esperado

### 2. Se erro de parsing:
1. Verifique se os nomes dos campos estão corretos
2. Confirme se os tipos de dados batem
3. Verifique se as datas estão em formato suportado

### 3. Se erro de conectividade:
1. Confirme que a URL base está correta
2. Verifique se a API está online
3. Confirme tokens de autenticação se necessário

## Rollback de Emergência
Se houver problemas, você pode temporariamente reverter para usar diretamente os modelos de domínio nos clients, removendo as referências a `APIEventResponse`, `APITicketResponse`, etc.

## Próximos Passos
1. Testar em ambiente de desenvolvimento
2. Verificar se a API retorna dados no formato esperado
3. Ajustar os modelos conforme necessário
4. Remover logs de debug quando tudo funcionar