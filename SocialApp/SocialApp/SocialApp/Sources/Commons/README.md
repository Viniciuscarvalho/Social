# Componentes Genéricos - Commons

Esta pasta contém componentes reutilizáveis para estados comuns em toda a aplicação.

## 📦 Componentes Disponíveis

### 1. LoadingView
View genérica para estados de carregamento.

```swift
// Uso básico
LoadingView(message: "Carregando eventos...")

// Sem spinner
LoadingView(message: "Processando...", showSpinner: false)
```

### 2. LoadingOverlay
View de loading que aparece sobre outras views.

```swift
ZStack {
    // Sua view principal
    ContentView()
    
    // Loading overlay
    if isLoading {
        LoadingOverlay(message: "Salvando dados...")
    }
}
```

### 3. ErrorView
View genérica para estados de erro.

```swift
ErrorView(
    title: "Erro ao carregar",
    message: "Não foi possível carregar os dados.",
    actionTitle: "Tentar Novamente",
    action: {
        // Ação de retry
    }
)
```

### 4. CompactErrorView
View de erro compacta para cards ou seções menores.

```swift
CompactErrorView(
    message: "Falha ao carregar",
    action: {
        // Ação de retry
    }
)
```

### 5. EmptyStateView
View para estados vazios.

```swift
EmptyStateView(
    title: "Nenhum evento encontrado",
    message: "Não há eventos disponíveis no momento.",
    icon: "calendar.badge.exclamationmark",
    actionTitle: "Atualizar",
    action: {
        // Ação de refresh
    }
)
```

### 6. StateWrapper
Wrapper que gerencia automaticamente estados de loading, erro e vazio.

```swift
StateWrapper(
    isLoading: store.isLoading,
    error: store.errorMessage,
    isEmpty: store.items.isEmpty,
    emptyMessage: "Nenhum item encontrado",
    onRetry: { store.send(.retry) },
    onRefresh: { store.send(.refresh) }
) {
    // Sua view principal
    ListView()
}
```

### 7. StateModifier (Extension)
Modifier para facilitar o uso do StateWrapper.

```swift
ContentView()
    .stateWrapper(
        isLoading: isLoading,
        error: errorMessage,
        isEmpty: items.isEmpty,
        emptyMessage: "Nenhum item encontrado",
        onRetry: { retryAction() }
    )
```

## 🚀 Exemplo Prático

### Antes (Código Duplicado)
```swift
public var body: some View {
    VStack {
        if isLoading {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Carregando...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if errorMessage != nil {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                Text("Ops! Algo deu errado")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(errorMessage!)
                    .foregroundColor(.secondary)
                Button("Tentar Novamente") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if items.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "tray")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("Nada por aqui")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Nenhum item encontrado")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // Conteúdo principal
            ListView()
        }
    }
}
```

### Depois (Usando Componentes Genéricos)
```swift
public var body: some View {
    ListView()
        .stateWrapper(
            isLoading: isLoading,
            error: errorMessage,
            isEmpty: items.isEmpty,
            emptyMessage: "Nenhum item encontrado",
            onRetry: retryAction
        )
}
```

## ✅ Benefícios

1. **Redução de Código Duplicado**: Elimina repetição de lógica de estados
2. **Consistência Visual**: Interface uniforme em toda a aplicação
3. **Manutenibilidade**: Mudanças em um local afetam toda a aplicação
4. **Facilidade de Uso**: API simples e intuitiva
5. **Flexibilidade**: Componentes customizáveis para diferentes cenários

## 🔧 Como Migrar

1. **Identifique** views com lógica de loading/erro/vazio duplicada
2. **Substitua** a lógica manual pelo `.stateWrapper()`
3. **Teste** os diferentes estados (loading, erro, vazio, sucesso)
4. **Customize** mensagens e ícones conforme necessário

## 📱 Estados Suportados

- ✅ **Loading**: Com spinner e mensagem customizável
- ❌ **Erro**: Com ícone, título, mensagem e botão de retry
- 📭 **Vazio**: Com ícone, título, mensagem e botão de ação opcional
- 🎉 **Sucesso**: Mostra o conteúdo principal normalmente

