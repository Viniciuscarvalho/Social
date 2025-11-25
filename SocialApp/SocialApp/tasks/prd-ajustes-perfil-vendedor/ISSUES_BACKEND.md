# Issues Identificadas - Backend

## 1. Erro ao criar negociação - 403 Forbidden

**Endpoint**: `POST /api/negotiations`

**Request enviado**:
```json
{
  "ticket_id": "B0000000-0000-0000-0000-000000000005"
}
```

**Erro retornado**: `403 Forbidden`

**Mensagem**: "Você não tem permissão para realizar esta ação"

### Análise

O cliente iOS está enviando o request corretamente com:
- ✅ Token JWT de autenticação no header
- ✅ Campo `ticket_id` em snake_case
- ✅ Request body formatado corretamente

```swift
public struct CreateNegotiationRequest: Codable {
    let ticketId: String
    let proposedPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
        case proposedPrice = "proposed_price"
    }
}
```

O erro `403 Forbidden` indica que o backend está **recusando a requisição por falta de permissão**, não por problema de formato.

### Possíveis causas

1. **Usuário tentando negociar próprio ingresso**: O backend pode estar validando que `buyer_id != seller_id`
2. **Verificação de usuário obrigatória**: Backend pode exigir que o usuário esteja verificado (email, telefone, documento)
3. **Status do ticket**: Backend pode validar se o ticket está disponível (status = "available")
4. **Limite de negociações ativas**: Backend pode ter limite de negociações simultâneas por usuário
5. **Seller_id inválido**: Backend pode estar validando a propriedade do ticket
6. **Business rules não atendidas**: Outras regras de negócio que impedem a negociação

### Validações implementadas no iOS

Para evitar erros desnecessários, o iOS agora valida:

1. ✅ **Usuário != Vendedor**: Não permite iniciar negociação do próprio ingresso
2. ✅ **Ticket ID válido**: Verifica se o ticket existe antes de tentar negociar
3. ✅ **Logs detalhados**: Exibe informações de debug para facilitar troubleshooting

### Recomendações para o Backend

1. **Adicionar mensagens de erro específicas**: Retornar mensagem clara do motivo da recusa
   ```json
   {
     "error": "CANNOT_NEGOTIATE_OWN_TICKET",
     "message": "Você não pode negociar seu próprio ingresso"
   }
   ```

2. **Documentar regras de negócio**: Especificar todas as validações que impedem a criação de negociação

3. **Verificar logs do backend**: Identificar qual validação está falhando especificamente

4. **Retornar 400 vs 403**: Usar `400 Bad Request` para problemas de validação de dados e `403 Forbidden` apenas para problemas reais de permissão/autorização

### Debug checklist

Para identificar a causa exata do erro 403, verificar no backend:

- [ ] O `user_id` extraído do JWT está correto?
- [ ] O ticket existe e pertence ao seller correto?
- [ ] O usuário está tentando negociar o próprio ingresso?
- [ ] O ticket está com status "available"?
- [ ] O usuário tem verificações necessárias?
- [ ] Há alguma negociação ativa bloqueando?
- [ ] As permissões do usuário estão corretas?

---

## 2. Endpoint de unread-count retorna 404

**Endpoint**: `GET /api/negotiations/unread-count`

**Erro**: `404 Not Found`

**Mensagem**: "Recurso não encontrado"

### Análise

O endpoint `/api/negotiations/unread-count` não está disponível no backend ou a rota não está configurada corretamente.

### Impacto

- O badge de notificações não pode ser atualizado
- Logs de erro aparecem constantemente no console

### Solução implementada no iOS

1. **Removido polling automático**: O contador de unread não é mais atualizado automaticamente em loop
2. **Atualização sob demanda**: O contador só é atualizado quando o usuário clica na aba de negociações
3. **Tratamento de erro silencioso**: Erros ao buscar o contador não impactam a UX

### Recomendações para o backend

1. **Implementar o endpoint**: `GET /api/negotiations/unread-count`
2. **Retornar formato**:
```json
{
  "count": 5
}
```
3. **Lógica**: Contar perguntas não respondidas em negociações onde o usuário é vendedor

---

## 3. Status das correções

### Cliente iOS (✅ Implementado)

1. ✅ Navegação do ProfileView para SellerProfile funcionando
2. ✅ Botão de "Negociar" no SellerProfileView direciona para aba de negociações
3. ✅ Otimização do polling de unread-count (removido loop infinito)
4. ⚠️ Erro ao criar negociação (requer correção no backend)

### Backend (⏳ Pendente)

1. ⏳ Corrigir endpoint `POST /api/negotiations` para aceitar o formato enviado
2. ⏳ Implementar endpoint `GET /api/negotiations/unread-count`
3. ⏳ Validar endpoints `/events/{eventId}/sellers` e `/sellers/{sellerId}/tickets`

---

## Logs relevantes

### Criar negociação (erro 403)
```
💼 Criando negociação para ticket: B0000000-0000-0000-0000-000000000005
🔐 Auth token added: eyJhbGciOiJIUzI1NiIs...
📤 Request body for /negotiations:
   Method: POST
   URL: https://ticketplace-api.onrender.com/api/negotiations
   Body: {"ticket_id":"B0000000-0000-0000-0000-000000000005"}

❌ Erro ao criar negociação: Você não tem permissão para realizar esta ação.
```

**Validação local implementada**:
```
🔍 Validando negociação:
   - Current User ID: [user-id]
   - Seller ID: [seller-id]
   - Ticket ID: B0000000-0000-0000-0000-000000000005
```

Se `Current User ID == Seller ID`, o iOS agora bloqueia localmente e exibe:
```
❌ ERRO: Usuário tentando negociar próprio ingresso
```

### Unread count (erro)
```
📤 Request for /negotiations/unread-count:
   Method: GET
   URL: https://ticketplace-api.onrender.com/api/negotiations/unread-count
   Body: None

❌ Erro ao buscar contador de badge: Recurso não encontrado
```

---

## Próximos passos

1. Verificar com o time de backend o schema esperado para criação de negociação
2. Implementar ou corrigir o endpoint de unread-count
3. Validar os endpoints de vendedores implementados
4. Testar o fluxo completo end-to-end



