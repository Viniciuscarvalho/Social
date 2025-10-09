# API Response Examples

Este arquivo documenta os formatos de resposta da API e como o código lida com eles.

## Estruturas de Resposta Suportadas

### 1. Arrays (Lista de Eventos, Tickets, etc.)

**Formato 1: Array Direto**
```json
[
  {
    "id": "a0000000-0000-0000-0000-000000000001",
    "name": "Festival de Verão São Paulo",
    "description": "O maior festival de verão da América Latina...",
    "imageURL": "https://example.com/festival.jpg",
    "startPrice": 120.0,
    "location": {
      "name": "Parque Ibirapuera",
      "address": "Av. Paulista, 1578",
      "city": "São Paulo",
      "state": "SP", 
      "country": "Brasil",
      "coordinate": {
        "latitude": -23.5505,
        "longitude": -46.6333
      }
    },
    "category": "music",
    "isRecommended": true
  }
]
```

**Formato 2: Wrapped Object**
```json
{
  "data": [
    {
      "id": "a0000000-0000-0000-0000-000000000001",
      "name": "Festival de Verão São Paulo",
      ...
    }
  ]
}
```

### 2. Objetos Únicos (Detalhes de Evento, Ticket, etc.)

**Formato 1: Objeto Direto**
```json
{
  "id": "b0000000-0000-0000-0000-000000000001",
  "ticketId": "b0000000-0000-0000-0000-000000000001",
  "event": {
    "id": "a0000000-0000-0000-0000-000000000001",
    "name": "Festival de Verão São Paulo",
    ...
  },
  "seller": {
    "id": "11111111-1111-1111-1111-111111111111",
    "name": "João Silva",
    ...
  },
  "price": 450.0,
  "quantity": 2
}
```

**Formato 2: Wrapped Object**
```json
{
  "data": {
    "id": "b0000000-0000-0000-0000-000000000001",
    "ticketId": "b0000000-0000-0000-0000-000000000001",
    ...
  }
}
```

## Como o Código Lida Com Essas Variações

### Para Arrays: `requestArray<T>`
1. Tenta decodificar como `[T]` (array direto)
2. Se falhar, tenta decodificar como `APIListResponse<T>` (wrapped object)
3. Usa `finalData` computed property para extrair o array final

### Para Objetos: `requestSingle<T>`
1. Tenta decodificar como `T` (objeto direto)
2. Se falhar, tenta decodificar como `APISingleResponse<T>` (wrapped object)  
3. Usa `finalData` computed property para extrair o objeto final

## Compatibilidade snake_case vs camelCase

Os modelos API suportam ambos os formatos:

```json
{
  "imageURL": "...",        // camelCase
  "image_url": "...",       // snake_case (fallback)
  "startPrice": 120.0,      // camelCase
  "start_price": 120.0      // snake_case (fallback)
}
```

As computed properties garantem a compatibilidade:
```swift
var finalImageURL: String? {
    return imageURL ?? image_url
}
```