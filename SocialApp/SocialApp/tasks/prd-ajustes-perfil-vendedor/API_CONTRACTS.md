# Contratos de API - Vendedores e Ingressos

Este documento descreve os contratos de API esperados para as funcionalidades de listagem de vendedores por evento e ingressos por vendedor.

## Base URL

```
https://ticketplace-api.onrender.com/api
```

## Autenticação

- **Método**: JWT Token via Header
- **Header**: `Authorization: Bearer {token}`
- **Nota**: Alguns endpoints são públicos e não requerem autenticação

---

## 1. Listar Vendedores por Evento

### Endpoint Otimizado (Recomendado)

**GET** `/events/{eventId}/sellers`

**Descrição**: Retorna lista agregada de vendedores que possuem ingressos disponíveis para o evento especificado. Este endpoint é otimizado e retorna informações pré-agregadas.

**Path Parameters**:
- `eventId` (String, UUID): ID do evento

**Query Parameters**: Nenhum

**Autenticação**: Não requerida (endpoint público)

**Response 200 OK**:
```json
{
  "sellers": [
    {
      "id": "seller-123",
      "name": "João Silva",
      "photo": "https://example.com/photos/seller-123.jpg",
      "profile_image_url": "https://example.com/photos/seller-123.jpg",
      "ticketsCount": 5,
      "tickets_count": 5,
      "minPrice": 50.00,
      "min_price": 50.00,
      "maxPrice": 150.00,
      "max_price": 150.00,
      "isVerified": true,
      "is_verified": true
    }
  ]
}
```

**Response 404 Not Found**:
```json
{
  "error": "Evento não encontrado",
  "message": "O evento especificado não existe"
}
```

**Response 500 Internal Server Error**:
```json
{
  "error": "Erro interno do servidor",
  "message": "Ocorreu um erro ao processar a requisição"
}
```

**Notas**:
- O endpoint retorna apenas vendedores que possuem **ingressos disponíveis** (status = available) para o evento
- Os campos `ticketsCount`, `minPrice` e `maxPrice` são calculados apenas com ingressos disponíveis
- O endpoint suporta tanto `camelCase` quanto `snake_case` nos campos de resposta
- Se o endpoint não estiver disponível, o cliente faz fallback para o método manual (buscar tickets e agrupar)

---

## 2. Listar Ingressos por Vendedor

### Endpoint

**GET** `/sellers/{sellerId}/tickets`

**Descrição**: Retorna lista de ingressos disponíveis de um vendedor específico.

**Path Parameters**:
- `sellerId` (String): ID do vendedor

**Query Parameters**: 
- `status` (String, opcional): Filtrar por status (ex: "available", "sold", "cancelled")
- `eventId` (String, opcional): Filtrar por evento específico

**Autenticação**: Não requerida (endpoint público)

**Response 200 OK**:
```json
{
  "tickets": [
    {
      "id": "ticket-123",
      "eventId": "event-456",
      "event_id": "event-456",
      "sellerId": "seller-123",
      "seller_id": "seller-123",
      "name": "Ingresso VIP",
      "description": "Ingresso VIP com acesso ao backstage",
      "price": 100.00,
      "originalPrice": 120.00,
      "original_price": 120.00,
      "ticketType": "VIP",
      "ticket_type": "VIP",
      "status": "available",
      "validUntil": "2024-12-31T23:59:59Z",
      "valid_until": "2024-12-31T23:59:59Z",
      "createdAt": "2024-01-15T10:00:00Z",
      "created_at": "2024-01-15T10:00:00Z",
      "isFavorited": false,
      "is_favorited": false,
      "quantity": 1,
      "currencyCode": "BRL",
      "currency_code": "BRL",
      "imageUrls": ["https://example.com/ticket-image.jpg"],
      "image_urls": ["https://example.com/ticket-image.jpg"]
    }
  ]
}
```

**Response 404 Not Found**:
```json
{
  "error": "Vendedor não encontrado",
  "message": "O vendedor especificado não existe"
}
```

**Notas**:
- Por padrão, o endpoint retorna apenas ingressos com `status = "available"`
- O endpoint suporta tanto `camelCase` quanto `snake_case` nos campos de resposta
- Se `eventId` for fornecido, retorna apenas ingressos daquele evento

---

## 3. Fallback - Buscar Tickets por Evento

### Endpoint Existente

**GET** `/tickets?eventId={eventId}`

**Descrição**: Endpoint existente usado como fallback quando o endpoint otimizado não está disponível.

**Query Parameters**:
- `eventId` (String, UUID): ID do evento

**Response**: Array de tickets conforme modelo `APITicketResponse`

**Notas**:
- Este endpoint é usado quando `/events/{eventId}/sellers` não está disponível
- O cliente agrupa os tickets por vendedor e busca informações dos vendedores individualmente

---

## Modelos de Dados

### APISellerSummary

```swift
public struct APISellerSummary: Codable {
    public let id: String
    public let name: String
    public let photo: String?
    public let profile_image_url: String?
    public let ticketsCount: Int?
    public let tickets_count: Int?
    public let minPrice: Double?
    public let min_price: Double?
    public let maxPrice: Double?
    public let max_price: Double?
    public let isVerified: Bool?
    public let is_verified: Bool?
}
```

### APITicketResponse

Ver modelo completo em `Domain/Sources/Models.swift` - `APITicketResponse`

---

## Estratégia de Implementação

### Cliente iOS

O cliente iOS implementa uma estratégia de fallback para ambos os endpoints:

#### Endpoint `/events/{eventId}/sellers`:

1. **Primeira tentativa**: Usa o endpoint otimizado `/events/{eventId}/sellers`
2. **Fallback**: Se o endpoint otimizado não estiver disponível ou retornar erro, usa:
   - `GET /tickets?eventId={eventId}` para buscar tickets
   - Filtra apenas tickets com `status == .available`
   - Agrupa tickets por vendedor
   - `GET /users/{sellerId}` para cada vendedor encontrado
   - Constrói `SellerWithTickets` manualmente

#### Endpoint `/sellers/{sellerId}/tickets`:

1. **Primeira tentativa**: Usa o endpoint otimizado `/sellers/{sellerId}/tickets`
2. **Fallback Nível 2**: Se falhar, tenta `GET /tickets?sellerId={sellerId}` e filtra por `status == .available`
3. **Fallback Nível 3**: Se falhar, busca todos os tickets `GET /tickets` e filtra localmente por `sellerId` e `status == .available`
4. **Fallback Nível 4**: Se tudo falhar, usa dados mock locais (JSON)

### Vantagens da Abordagem

- **Compatibilidade**: Funciona mesmo se o backend não tiver o endpoint otimizado
- **Performance**: Usa endpoint otimizado quando disponível
- **Resiliência**: Fallback garante que a funcionalidade sempre funciona

---

## Status de Implementação

- ✅ Modelos de dados criados (`APISellersByEventResponse`, `APISellerSummary`, `APITicketsBySellerResponse`)
- ✅ Método `fetchSellersByEvent` implementado no `TicketsClient` com estratégia de fallback
- ✅ Método `fetchTicketsBySeller` atualizado para usar endpoint otimizado `/sellers/{sellerId}/tickets` primeiro
- ✅ Estratégia de fallback implementada para ambos os endpoints
- ✅ `SellersListFeature` atualizado para usar método otimizado
- ✅ `SellerProfileFeature` usa `fetchTicketsBySeller` que tenta endpoint otimizado primeiro
- ⏳ Endpoint otimizado `/events/{eventId}/sellers` no backend (pendente validação)
- ⏳ Endpoint `/sellers/{sellerId}/tickets` no backend (pendente validação)

---

## Notas para Desenvolvimento Backend

### Endpoint `/events/{eventId}/sellers`

**Recomendações**:
1. Agregar dados no banco de dados para melhor performance
2. Filtrar apenas ingressos com `status = 'available'`
3. Calcular `minPrice` e `maxPrice` apenas com ingressos disponíveis
4. Incluir informações básicas do vendedor (nome, foto, verificação)
5. Suportar paginação se houver muitos vendedores

**Query SQL Sugerido** (exemplo):
```sql
SELECT 
    u.id,
    u.name,
    u.profile_image_url as photo,
    COUNT(t.id) as tickets_count,
    MIN(t.price) as min_price,
    MAX(t.price) as max_price,
    u.is_verified
FROM users u
INNER JOIN tickets t ON t.seller_id = u.id
WHERE t.event_id = :eventId
  AND t.status = 'available'
GROUP BY u.id, u.name, u.profile_image_url, u.is_verified
ORDER BY min_price ASC
```

### Endpoint `/sellers/{sellerId}/tickets`

**Recomendações**:
1. Filtrar por `status = 'available'` por padrão
2. Suportar query parameter `eventId` para filtrar por evento
3. Suportar query parameter `status` para filtrar por status
4. Retornar tickets ordenados por preço (menor primeiro)

---

## Testes

### Casos de Teste

1. **Endpoint otimizado disponível e retorna dados**
   - ✅ Deve usar endpoint otimizado
   - ✅ Deve converter `APISellerSummary` para `SellerWithTickets`
   - ✅ Deve ordenar por preço mínimo

2. **Endpoint otimizado não disponível (404)**
   - ✅ Deve fazer fallback para método manual
   - ✅ Deve buscar tickets e agrupar por vendedor
   - ✅ Deve buscar perfis dos vendedores

3. **Endpoint otimizado retorna vazio**
   - ✅ Deve fazer fallback para método manual
   - ✅ Deve tratar como "nenhum vendedor encontrado"

4. **Erro de rede**
   - ✅ Deve exibir mensagem de erro amigável
   - ✅ Deve permitir retry

---

## Changelog

- **2024-01-XX**: Documentação inicial criada
- **2024-01-XX**: Modelos de dados implementados
- **2024-01-XX**: Método `fetchSellersByEvent` implementado no cliente iOS
- **2024-01-XX**: Estratégia de fallback implementada

