# 🔐 Implementação de Refresh Automático de JWT Token

## 📋 Problema Identificado

Ao criar um ingresso (POST /tickets), o servidor retornava erro:
```
❌ Erro na autenticação: invalid JWT: unable to parse or verify signature, 
   token has invalid claims: token is expired
```

O token JWT estava expirado e não era refrescado antes do POST.

---

## ✅ Solução Implementada

### 1. **AuthClient - Novo Método `refreshToken`**

Arquivo: `SocialApp/Sources/Dependencies/AuthClient.swift`

```swift
var refreshToken: @Sendable () async throws -> String
```

**Implementação:**
- Chama `supabase.auth.refreshSession()` para obter novo token
- Salva o novo token em `UserDefaults` com chave `"authToken"`
- Limpa dados de auth se falhar (logout automático)
- Retorna o novo token ou lança `NetworkError.unauthorized`

### 2. **TicketsClient - Refresh Antes de Criar Ticket**

Arquivo: `SocialApp/Sources/Dependencies/TicketsClient.swift`

**Na função `createTicket`:**
```swift
// 🔄 CRÍTICO: Refrescar token antes de criar ticket
print("🎫 TicketClient: Iniciando criação de ticket - tentando refrescar token...")
do {
    let newToken = try await authClient.refreshToken()
    print("✅ TicketClient: Token refrescado com sucesso")
} catch {
    print("⚠️ TicketClient: Falha ao refrescar token, tentando com token atual")
}

// Tenta criar o ticket com o novo token
let createdTicket: CreateTicketResponse = try await NetworkService.shared.requestSingle(
    endpoint: "/tickets",
    method: .POST,
    body: request,
    requiresAuth: true
)
```

**Fluxo:**
1. ✅ Refrescar token ANTES da requisição POST
2. ✅ Se falhar, tenta com token atual
3. ✅ Se suceder, cria o ticket com novo token
4. ✅ NetworkService adiciona o novo token no header `Authorization: Bearer <token>`

### 3. **NetworkService - Tratamento de Erro 401**

Arquivo: `SocialApp/Sources/Services/NetworkService.swift` (linhas 315-319)

```swift
case 401:
    UserDefaults.standard.removeObject(forKey: "authToken")
    UserDefaults.standard.removeObject(forKey: "currentUser")
    UserDefaults.standard.removeObject(forKey: "currentUserId")
    throw NetworkError.unauthorized
```

Quando receber 401, o NetworkService:
- Limpa o token inválido
- Limpa dados de usuário
- Força novo login na próxima tentativa

---

## 🔄 Fluxo Completo

```
1. User clica "Publicar Ingresso"
   ↓
2. AddTicketFeature envia .publishTicket
   ↓
3. TicketsClient.createTicket é chamado
   ↓
4. 🔄 Refresh automático do token
   ├─ Sucesso → Novo token salvo
   └─ Falha → Tenta com token atual
   ↓
5. POST /api/tickets com token refrescado/novo
   ├─ Token válido (200) → Sucesso ✅
   └─ Token expirado (401) → Limpa e falha
```

---

## 🧪 Logs de Debug

O fluxo gera os seguintes logs:

```
🔄 AuthClient: Refrescando token JWT...
✅ AuthClient: Token refrescado com sucesso: eyJhbGciOiJIUzI1NiIs...

🎫 TicketClient: Iniciando criação de ticket - tentando refrescar token...
✅ TicketClient: Token refrescado com sucesso: eyJhbGciOiJIUzI1NiIs...

🔐 Auth token added: eyJhbGciOiJIUzI1NiIs...
📤 Request body for /tickets:
   Method: POST
   URL: https://ticketplace-api.onrender.com/api/tickets
   Body: {"originalPrice":1200,"name":"FrontStage",...}

✅ TicketClient: Ticket criado com sucesso: <ticket-id>
```

---

## 🛡️ Proteções Implementadas

1. **Refresh antes de criar** - Garante token válido
2. **Fallback gracioso** - Se refresh falhar, tenta com token atual
3. **Limpeza em 401** - Remove token inválido
4. **Logs detalhados** - Fácil debug de problemas

---

## 📱 Como Testar

1. Fazer login no app
2. Ir para "Criar Ingresso"
3. Preencher formulário
4. Clicar "Publicar"
5. Observar logs:
   - ✅ Token refrescado
   - ✅ POST enviado com novo token
   - ✅ Ticket criado com sucesso

---

## 🔗 Arquivos Modificados

- ✅ `AuthClient.swift` - Adicionado `refreshToken()`
- ✅ `TicketsClient.swift` - Refresh antes de POST
- ✅ `NetworkService.swift` - Tratamento existente de 401 (sem mudanças)


